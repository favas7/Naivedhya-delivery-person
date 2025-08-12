import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B35); // Vibrant Orange
  static const Color secondary = Color(0xFF2E86AB); // Deep Blue
  static const Color accent = Color(0xFFF7931E); // Golden Orange
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF28A745); // Green
  static const Color warning = Color(0xFFFFC107); // Yellow
  static const Color error = Color(0xFFDC3545); // Red
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color border = Color(0xFFE0E0E0);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF2E86AB), Color(0xFF54A0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}