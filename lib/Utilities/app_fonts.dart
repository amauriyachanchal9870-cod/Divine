import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle get appNameStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        height: 1.2,
      );

  static TextStyle get titleStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get regularText => GoogleFonts.poppins(
        fontSize: 14,
      );

  static TextStyle get semiBoldText => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get mediumText => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get hintStyle => GoogleFonts.poppins(
        fontSize: 13,
      );

  static TextStyle get smallText => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get boldLink => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get verySmallText => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );
}
