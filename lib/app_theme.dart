import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color accentCyan = Color(0xFF0891B2);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color errorColor = Color(0xFFDC2626);

  static const Color statusPendiente = Color(0xFFF59E0B);
  static const Color statusCompletada = Color(0xFF3B82F6);
  static const Color statusAprobada = Color(0xFF22C55E);
  static const Color statusRechazada = Color(0xFFEF4444);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          secondary: primaryBlue,
          surface: surfaceColor,
          error: errorColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: surfaceColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryTeal, width: 2),
          ),
        ),
      );

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryTeal, primaryBlue],
      );

  static Color statusColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return statusPendiente;
      case 'COMPLETADA':
        return statusCompletada;
      case 'APROBADA':
        return statusAprobada;
      case 'RECHAZADA':
        return statusRechazada;
      default:
        return Colors.grey;
    }
  }
}
