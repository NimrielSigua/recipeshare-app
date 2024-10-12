import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Colors.black;
  static const Color accentColor = Colors.white;
  static const Color backgroundColor = Colors.black;
  static const Color textColor = Colors.white;

  static final ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: accentColor),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryColor,
        backgroundColor: accentColor,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: accentColor,
      hintStyle: TextStyle(color: primaryColor.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      color: accentColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
  );

  static TextStyle get logoStyle => GoogleFonts.pacifico(
    fontSize: 48,
    color: accentColor,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: primaryColor.withOpacity(0.3),
        offset: Offset(2, 2),
      ),
    ],
  );

  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static TextStyle get bodyTextStyle => GoogleFonts.poppins(
    fontSize: 16,
    color: textColor,
  );
}
