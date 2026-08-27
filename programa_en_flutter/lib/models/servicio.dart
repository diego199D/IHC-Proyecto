import 'package:flutter/material.dart';

class Servicio {
  final int? id;
  final String nombre;
  final double precio;

  Servicio({this.id, required this.nombre, this.precio = 0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'precio': precio};
  }

  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      precio: (map['precio'] as num).toDouble(),
    );
  }

  // Ícono representativo según el nombre del servicio (igual que el prototipo).
  IconData get icono {
    final n = nombre.toLowerCase();
    if (n.contains('afeitado')) return Icons.face_retouching_natural;
    return Icons.content_cut;
  }
}
