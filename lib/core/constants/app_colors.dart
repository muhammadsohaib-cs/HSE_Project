import 'package:flutter/material.dart';

class AppColors {
  // Brand & Industrial Base
  static const Color primary = Color(0xFF1E3A8A); // Industrial Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF0F172A); // Dark Slate

  // HSE Status & Risk Colors
  static const Color riskLow = Color(0xFF10B981); // Green (1-4)
  static const Color riskMedium = Color(0xFFF59E0B); // Amber / Yellow (5-9)
  static const Color riskHigh = Color(0xFFF97316); // Orange (10-14)
  static const Color riskCritical = Color(0xFFEF4444); // Red (15-25)

  // Emergency & Siren Colors
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyGaze = Color(0xFFFF4D4F);

  // Surface & Neutral Colors
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color cardDark = Color(0xFF161F30);
  static const Color borderDark = Color(0xFF2A364F);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Helper for dynamic score coloring
  static Color getRiskColor(int score) {
    if (score <= 4) return riskLow;
    if (score <= 9) return riskMedium;
    if (score <= 14) return riskHigh;
    return riskCritical;
  }

  static String getRiskBandLabel(int score) {
    if (score <= 4) return 'Low Risk';
    if (score <= 9) return 'Medium Risk';
    if (score <= 14) return 'High Risk';
    return 'Critical / Extreme';
  }
}

