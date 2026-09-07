import 'package:flutter/material.dart';

class AppColors {
  static const primaryNavy = Color(0xFF142448);
  static const deepNavy = Color(0xFF0E1A35);
  static const primaryGold = Color(0xFFF5C542);
  static const lightGold = Color(0xFFFFD968);
  static const warmCream = Color(0xFFFFF8E8);
  
  static const textPrimary = Color(0xFF26334A);
  static const mutedText = Color(0xFF667085);
  
  static const success = Color(0xFF2E8B57);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFC2413B);

  static const gradientNavy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryNavy, deepNavy],
  );
}
