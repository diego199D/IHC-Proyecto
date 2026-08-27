import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cliente.dart';
import '../models/servicio.dart';
import '../theme/app_theme.dart';
import 'agregar_cita_horario_screen.dart';

class AgregarCitaServicioScreen extends StatefulWidget {
  final Cliente cliente;
  const AgregarCitaServicioScreen({super.key, required this.cliente});

  @override
  State<AgregarCitaServicioScreen> createState() => _AgregarCitaServicioScreenState();
}

class _AgregarCitaServicioScreenState extends State<AgregarCitaServicioScreen> {
  late Future<List<Servicio>> _serviciosFuture;
  final Set<int> _seleccionados = {}; // ids de servicios seleccionados

  @override
  void initState() {
    super.initState();
    _serviciosFuture = DatabaseHelper.instance.getServicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AGREGAR CITA')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione el servicio:',
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<Servicio>>(
                future: _serviciosFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final servicios = snapshot.data!;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: servicios.map((s) {
                      final seleccionado = _seleccionados.contains(s.id);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (seleccionado) {
                              _seleccionados.remove(s.id);
                            } else {
                              _seleccionados.add(s.id!);
                            }
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 90,
                          decoration: BoxDecoration(
                            color: seleccionado ? AppColors.tarjetaSeleccionada : AppColors.tarjeta,
                            borderRadius: BorderRadius.circular(10),
                            border: seleccionado
                                ? Border.all(color: AppColors.texto, width: 1.4)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(s.icono, size: 22, color: AppColors.texto),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  s.nombre,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, color: AppColors.texto),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _seleccionados.isEmpty
                    ? null
                    : () async {
                        final servicios = await _serviciosFuture;
                        final nombres = servicios
                            .where((s) => _seleccionados.contains(s.id))
                            .map((s) => s.nombre)
                            .join(', ');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgregarCitaHorarioScreen(
                              cliente: widget.cliente,
                              serviciosTexto: nombres,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.negroBoton,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.badgeCancelar,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                child: const Text('SIGUIENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
