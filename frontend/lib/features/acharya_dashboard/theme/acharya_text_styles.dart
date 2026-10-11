import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'acharya_colors.dart';

class AcharyaTextStyles {
  static TextStyle brand = GoogleFonts.cinzel(
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    letterSpacing: 0.6,
    color: AcharyaColors.navy,
  );

  static TextStyle greeting = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w800,
    fontSize: 24,
    height: 1.15,
    color: AcharyaColors.goldLight,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Colors.white,
  );

  static TextStyle cardTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 14.5,
    color: AcharyaColors.textPrimary,
  );

  static TextStyle cardBody = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AcharyaColors.textSecondary,
  );

  static TextStyle cardLink = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    color: AcharyaColors.textPrimary,
  );

  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 15,
    letterSpacing: 0.8,
    color: AcharyaColors.textPrimary,
  );

  static TextStyle eventDateNumber = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AcharyaColors.textPrimary,
  );

  static TextStyle eventDateMonth = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AcharyaColors.textSecondary,
  );

  static TextStyle eventTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: AcharyaColors.textPrimary,
  );

  static TextStyle pillLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 11.5,
    letterSpacing: 0.5,
    color: AcharyaColors.gold,
  );

  static TextStyle bottomNavLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  static TextStyle avatarInitials = GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: Colors.white,
  );

  static TextStyle avatarCaption = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 8,
    color: AcharyaColors.navy,
  );
}
