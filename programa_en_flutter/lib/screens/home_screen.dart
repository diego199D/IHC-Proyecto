import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cita.dart';
import '../theme/app_theme.dart';
import '../widgets/tarjeta_cita.dart';
import 'agregar_cita_cliente_screen.dart';
import 'cancelar_cita_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Cita>> _citasFuture;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  void _cargarCitas() {
    _citasFuture = DatabaseHelper.instance.getCitasActivas();
  }

  Future<void> _recargar() async {
    setState(_cargarCitas);
    await _citasFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INICIO'),
        actions: [
          IconButton(
            tooltip: 'Cancelar cita',
            icon: const Icon(Icons.event_busy),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CancelarCitaScreen()),
              );
              _recargar();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _recargar,
            child: FutureBuilder<List<Cita>>(
              future: _citasFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final citas = snapshot.data!;
                if (citas.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No hay citas agendadas')),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: citas.length,
                  itemBuilder: (context, i) => TarjetaCita(cita: citas[i]),
                );
              },
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgregarCitaClienteScreen()),
                );
                _recargar();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.negroBoton,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('AGREGAR CITA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
