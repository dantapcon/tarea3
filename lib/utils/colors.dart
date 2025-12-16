import 'package:flutter/material.dart';

/// Paleta de colores verde pastel para la aplicación
class AppColors {
  // Verdes pastel principales
  static const Color primary = Color(0xFFA8E6CF);
  static const Color secondary = Color(0xFF88D9B8);
  static const Color accent = Color(0xFFB8F3D8);
  static const Color light = Color(0xFFE0F9F0);
  
  // Colores complementarios
  static const Color background = Color(0xFFF5FFFA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D5F4E);
  static const Color textSecondary = Color(0xFF5A8A76);
  
  // Estados y alertas
  static const Color success = Color(0xFF7BC96F);
  static const Color warning = Color(0xFFFFD89C);
  static const Color error = Color(0xFFFF9B9B);
  static const Color info = Color(0xFF9DD9F3);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [light, background],
  );
}
