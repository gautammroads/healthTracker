import 'package:flutter/material.dart';

/// Curated color palette for the HabitSync app.
class AppColors {
  AppColors._();

  // ── Brand colors ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color primaryDark = Color(0xFF651FFF);

  // ── Surface / Background ──────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color cardDarkAlt = Color(0xFF1E2A45);

  static const Color backgroundLight = Color(0xFFF5F5FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF0F0FF);
  static const Color textSecondaryDark = Color(0xFF9E9EB8);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B6B80);

  // ── Accent / Habit colors ─────────────────────────────────────────────
  static const List<Color> habitColors = [
    Color(0xFF7C4DFF), // Purple
    Color(0xFF00BFA5), // Teal
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFB74D), // Amber
    Color(0xFF4FC3F7), // Sky Blue
    Color(0xFFFF4081), // Pink
    Color(0xFF69F0AE), // Mint
    Color(0xFFFF8A65), // Peach
    Color(0xFF40C4FF), // Cyan
    Color(0xFFE040FB), // Magenta
  ];

  // ── Status ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFD54F);
  static const Color error = Color(0xFFFF5252);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF69F0AE), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
