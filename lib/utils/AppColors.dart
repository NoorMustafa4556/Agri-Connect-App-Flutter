import 'package:flutter/material.dart';

class AppColors {
  // Primary Green Color for Agriculture Theme
  static const Color primary = Color(0xFF2E7D32); // Deep Green
  static const Color primaryLight = Color(0xFF60AD5E); // Light Green
  static const Color primaryDark = Color(0xFF005005); // Dark Green

  static const Color secondary = Color(0xFFFF9800); // Orange (for highlights/pending)
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color backgroundDark = Color(0xFF121212); // Dark Background
  
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark Surface/Card
  
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // For Dark mode specific texts
  static const Color textOnDark = Color(0xFFE0E0E0);
  static const Color textGrey = Color(0xFFB0B0B0);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Helper method to get card/surface color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? surfaceDark 
        : white;
  }

  // Helper method to get main text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textOnDark 
        : textDark;
  }
}
