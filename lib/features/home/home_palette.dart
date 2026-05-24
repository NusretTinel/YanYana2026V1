import 'package:flutter/material.dart';

/// Warm pastel palette for the Home screen.
class HomePalette {
  HomePalette._();

  static const primary = Color(0xFF6C63FF);
  static const lavender = Color(0xFFEEE9FF);
  static const softBlue = Color(0xFFE6F4FF);
  static const softMint = Color(0xFFE8FFF5);
  static const softPink = Color(0xFFFFEAF1);
  static const softYellow = Color(0xFFFFF7D6);
  static const softCoral = Color(0xFFFF5A6A);
  static const textDark = Color(0xFF1F2937);
  static const textMuted = Color(0xFF64748B);
  static const background = Color(0xFFF8FAFC);

  static const greetingGradient = LinearGradient(
    colors: [Color(0xFFEEE9FF), Color(0xFFE6F4FF), Color(0xFFE8FFF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const emergencyGradient = LinearGradient(
    colors: [Color(0xFFFFEAF1), Color(0xFFFFF0F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
