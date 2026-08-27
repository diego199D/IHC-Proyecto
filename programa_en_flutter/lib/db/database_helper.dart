import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/cliente.dart';
import '../models/servicio.dart';
import '../models/cita.dart';

/// Acceso centralizado a la base de datos local SQLite (patrón Singleton).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gestor_citas.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE servicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE citas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clienteId INTEGER NOT NULL,
        clienteNombre TEXT NOT NULL,
        servicios TEXT NOT NULL,
        horario TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'activa',
        FOREIGN KEY (clienteId) REFERENCES clientes (id)
      )
    ''');

    await _seed(db);
  }

  /// Datos iniciales para que la app se vea igual al prototipo desde el primer run.
  Future<void> _seed(Database db) async {
    final clientesSeed = ['Mario Perez', 'Mariano Garcia', 'Mario Lopez', 'Diego Toledo', 'Josue Lorens'];
    final idsClientes = <String, int>{};
    for (final nombre in clientesSeed) {
      final id = await db.insert('clientes', {'nombre': nombre});
      idsClientes[nombre] = id;
    }

    final serviciosSeed = [
      {'nombre': 'Corte Clasico', 'precio': 40.0},
      {'nombre': 'Corte + Barba', 'precio': 60.0},
      {'nombre': 'Afeitado', 'precio': 30.0},
    ];
    for (final s in serviciosSeed) {
      await db.insert('servicios', s);
    }

    // Citas de ejemplo iguales a la pantalla "INICIO" del prototipo.
    await db.insert('citas', {
      'clienteId': idsClientes['Mario Perez'],
      'clienteNombre': 'Mario Perez',
      'servicios': 'Afeitado',
      'horario': '9:00 AM',
      'estado': 'activa',
    });
    await db.insert('citas', {
      'clienteId': idsClientes['Mariano Garcia'],
      'clienteNombre': 'Mariano Garcia',
      'servicios': 'Corte clasico',
      'horario': '11:00 AM',
      'estado': 'activa',
    });
  }

  // ---------- CLIENTES ----------
  Future<List<Cliente>> getClientes() async {
    final db = await database;
    final maps = await db.query('clientes', orderBy: 'nombre');
    return maps.map((m) => Cliente.fromMap(m)).toList();
  }

  // ---------- SERVICIOS ----------
  Future<List<Servicio>> getServicios() async {
    final db = await database;
    final maps = await db.query('servicios', orderBy: 'id');
    return maps.map((m) => Servicio.fromMap(m)).toList();
  }

  // ---------- CITAS ----------
  Future<List<Cita>> getCitasActivas() async {
    final db = await database;
    final maps = await db.query(
      'citas',
      where: 'estado = ?',
      whereArgs: ['activa'],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Cita.fromMap(m)).toList();
  }

  Future<int> insertCita(Cita cita) async {
    final db = await database;
    return db.insert('citas', cita.toMap()..remove('id'));
  }

  Future<int> cancelarCita(int id) async {
    final db = await database;
    return db.update(
      'citas',
      {'estado': 'cancelada'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
