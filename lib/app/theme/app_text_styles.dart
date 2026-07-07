import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 40, fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 32, fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      );

  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );
}
