import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/cita.dart';

class TarjetaCita extends StatelessWidget {
  final Cita cita;
  final bool mostrarCancelar;
  final VoidCallback? onCancelar;

  const TarjetaCita({
    super.key,
    required this.cita,
    this.mostrarCancelar = false,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.clienteNombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.content_cut, size: 13, color: AppColors.textoSecundario),
                    const SizedBox(width: 6),
                    Text(
                      cita.servicios,
                      style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 13, color: AppColors.textoSecundario),
                    const SizedBox(width: 6),
                    Text(
                      cita.horario,
                      style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (mostrarCancelar)
            GestureDetector(
              onTap: onCancelar,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.badgeCancelar,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 11, color: AppColors.texto, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
