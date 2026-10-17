import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Brand & Titles
  static TextStyle brand = GoogleFonts.cinzel(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    letterSpacing: 0.6,
    color: AppColors.primaryNavy,
  );

  static TextStyle headingLarge = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w800,
    fontSize: 26,
    color: AppColors.textPrimary,
  );

  static TextStyle headingMedium = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.mutedText,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    letterSpacing: 0.3,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 11.5,
    color: AppColors.mutedText,
  );
}
