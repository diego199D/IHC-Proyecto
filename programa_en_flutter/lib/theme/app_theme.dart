import 'package:flutter/material.dart';

/// Paleta de colores extraída del prototipo (grises claros, negro, blanco).
class AppColors {
  static const Color fondoOscuro = Color(0xFF121212); // fondo detrás del "teléfono"
  static const Color fondoPantalla = Color(0xFFFFFFFF); // fondo de cada screen
  static const Color barraSuperior = Color(0xFFEDEDED); // header gris clarito
  static const Color tarjeta = Color(0xFFF3F3F3); // tarjetas de citas/servicios
  static const Color tarjetaSeleccionada = Color(0xFFDCDCDC);
  static const Color texto = Color(0xFF1A1A1A);
  static const Color textoSecundario = Color(0xFF6B6B6B);
  static const Color negroBoton = Color(0xFF1A1A1A);
  static const Color badgeCancelar = Color(0xFFBDBDBD);
  static const Color overlay = Color(0xB3616161); // overlay gris del diálogo
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.fondoPantalla,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.barraSuperior,
      foregroundColor: AppColors.texto,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.texto,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
}
