import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_tokens.dart';

class BrandTheme {
  const BrandTheme._();

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: BrandTokens.primary,
      primaryContainer: BrandTokens.primarySoft,
      secondary: BrandTokens.accent,
      secondaryContainer: BrandTokens.accentSoft,
      tertiary: BrandTokens.accent,
      tertiaryContainer: BrandTokens.accentSoft,
      surface: BrandTokens.lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: BrandTokens.lightText,
      outline: BrandTokens.lightBorder,
    );

    final baseTextTheme = GoogleFonts.manropeTextTheme();
    final textTheme = baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium:
          baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BrandTokens.lightBg,
      cardColor: BrandTokens.lightCard,
      textTheme: textTheme.apply(
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BrandTokens.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandTokens.inkStrong,
          side: const BorderSide(color: BrandTokens.lightBorder),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrandTokens.primaryDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BrandTokens.primarySoft,
        labelStyle: const TextStyle(
          color: BrandTokens.primaryDark,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: BrandTokens.primarySoft),
        ),
      ),
      cardTheme: CardThemeData(
        color: BrandTokens.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
      primaryContainer: BrandTokens.primary,
      secondary: BrandTokens.accent,
      secondaryContainer: BrandTokens.darkAccentSoft,
      tertiary: BrandTokens.accent,
      tertiaryContainer: BrandTokens.darkAccentSoft,
      surface: BrandTokens.darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: BrandTokens.darkText,
      outline: BrandTokens.darkBorder,
    );

    final baseTextTheme = GoogleFonts.manropeTextTheme();
    final textTheme = baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium:
          baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BrandTokens.darkBg,
      cardColor: BrandTokens.darkCard,
      textTheme: textTheme.apply(
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BrandTokens.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandTokens.darkText,
          side: const BorderSide(color: BrandTokens.darkTextMuted),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrandTokens.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BrandTokens.darkCard,
        labelStyle: const TextStyle(
          color: BrandTokens.darkText,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: BrandTokens.darkBorder),
        ),
      ),
      cardTheme: CardThemeData(
        color: BrandTokens.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: const DividerThemeData(
        color: BrandTokens.darkBorder,
        space: 1,
      ),
    );
  }
}
