import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_tokens.dart';

class BrandTheme {
  const BrandTheme._();

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: BrandTokens.primary,
      secondary: BrandTokens.primaryDark,
      surface: BrandTokens.lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: BrandTokens.lightText,
      outline: BrandTokens.lightBorder,
    );

    final baseTextTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BrandTokens.lightBg,
      cardColor: BrandTokens.lightCard,
      textTheme: baseTextTheme.apply(
        bodyColor: BrandTokens.lightText,
        displayColor: BrandTokens.lightText,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: BrandTokens.lightCard,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandTokens.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandTokens.primary),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandTokens.lightBg,
        foregroundColor: BrandTokens.lightText,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: BrandTokens.lightBorder,
        space: 1,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: BrandTokens.primary,
      secondary: BrandTokens.primaryDark,
      surface: BrandTokens.darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: BrandTokens.darkText,
      outline: BrandTokens.darkBorder,
    );

    final baseTextTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BrandTokens.darkBg,
      cardColor: BrandTokens.darkCard,
      textTheme: baseTextTheme.apply(
        bodyColor: BrandTokens.darkText,
        displayColor: BrandTokens.darkText,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: BrandTokens.darkCard,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandTokens.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandTokens.primary),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandTokens.darkBg,
        foregroundColor: BrandTokens.darkText,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: BrandTokens.darkBorder,
        space: 1,
      ),
    );
  }
}
