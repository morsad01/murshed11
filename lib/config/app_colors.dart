import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF007BFF);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFADB5BD);

  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2C);

  static const Color border = Color(0xFFDEE2E6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF0056B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF1E7B34)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
