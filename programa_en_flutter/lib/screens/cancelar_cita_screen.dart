import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cita.dart';
import '../theme/app_theme.dart';
import '../widgets/tarjeta_cita.dart';

class CancelarCitaScreen extends StatefulWidget {
  const CancelarCitaScreen({super.key});

  @override
  State<CancelarCitaScreen> createState() => _CancelarCitaScreenState();
}

class _CancelarCitaScreenState extends State<CancelarCitaScreen> {
  late Future<List<Cita>> _citasFuture;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  void _cargarCitas() {
    _citasFuture = DatabaseHelper.instance.getCitasActivas();
  }

  // Diálogo "Desea Cancelar esta Cita?" (iPhone 17-6), con overlay gris.
  Future<void> _confirmarCancelacion(Cita cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.fondoPantalla,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Desea Cancelar\nesta Cita?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.texto),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BotonDialogo(
                      texto: 'SI',
                      onTap: () => Navigator.pop(context, true),
                    ),
                    const SizedBox(width: 16),
                    _BotonDialogo(
                      texto: 'NO',
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmar == true && cita.id != null) {
      await DatabaseHelper.instance.cancelarCita(cita.id!);
      setState(_cargarCitas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancelar cita')),
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
              child: FutureBuilder<List<Cita>>(
                future: _citasFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final citas = snapshot.data!;
                  if (citas.isEmpty) {
                    return const Center(child: Text('No hay citas para cancelar'));
                  }
                  return ListView.builder(
                    itemCount: citas.length,
                    itemBuilder: (context, i) {
                      final cita = citas[i];
                      return TarjetaCita(
                        cita: cita,
                        mostrarCancelar: true,
                        onCancelar: () => _confirmarCancelacion(cita),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonDialogo extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _BotonDialogo({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tarjeta,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          width: 70,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            texto,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.texto),
          ),
        ),
      ),
    );
  }
}
