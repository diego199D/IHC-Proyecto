import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cliente.dart';
import '../models/cita.dart';
import '../theme/app_theme.dart';

class AgregarCitaHorarioScreen extends StatefulWidget {
  final Cliente cliente;
  final String serviciosTexto;

  const AgregarCitaHorarioScreen({
    super.key,
    required this.cliente,
    required this.serviciosTexto,
  });

  @override
  State<AgregarCitaHorarioScreen> createState() => _AgregarCitaHorarioScreenState();
}

class _AgregarCitaHorarioScreenState extends State<AgregarCitaHorarioScreen> {
  // Franjas horarias disponibles, igual que en el prototipo.
  final List<String> _horarios = const [
    '9:00 AM - 10:00 AM',
    '12:00 PM - 1:00 PM',
    '2:00 PM - 3:00 PM',
  ];

  String? _horarioSeleccionado;
  bool _guardando = false;

  Future<void> _guardarCita() async {
    if (_horarioSeleccionado == null) return;
    setState(() => _guardando = true);

    final cita = Cita(
      clienteId: widget.cliente.id!,
      clienteNombre: widget.cliente.nombre,
      servicios: widget.serviciosTexto,
      horario: _horarioSeleccionado!,
    );
    await DatabaseHelper.instance.insertCita(cita);

    if (!mounted) return;
    // Vuelve directo a Inicio (saca todas las pantallas del flujo Agregar Cita).
    Navigator.popUntil(context, (route) => route.isFirst);
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
              'Seleccione el horario:',
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _horarios.length,
                itemBuilder: (context, i) {
                  final h = _horarios[i];
                  final seleccionado = h == _horarioSeleccionado;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: seleccionado ? AppColors.tarjetaSeleccionada : AppColors.tarjeta,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _horarioSeleccionado = h),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              h,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.texto,
                                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: (_horarioSeleccionado == null || _guardando) ? null : _guardarCita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.negroBoton,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.badgeCancelar,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                icon: _guardando
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 18),
                label: const Text('GUARDAR CITA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
