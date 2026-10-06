import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Design tokens — mirror the variables in bani.pen
// ─────────────────────────────────────────────────────────────────────────────

/// Palette "Sogan" (bani.pen → Riset Warna, option A): sogan batik brown
/// with a blue-teal accent on warm grey. `gold`/`goldSoft` are the accent
/// slots (kept by name so the widgets stay unchanged).
class AppColors {
  AppColors._();

  static const bg = Color(0xFFF2EFEB);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFE8E2DB);
  static const ink = Color(0xFF211B17);
  static const ink2 = Color(0xFF62574F);
  static const ink3 = Color(0xFF978B82);
  static const line = Color(0xFFE3DBD3);
  static const primary = Color(0xFF8A4B2A);
  static const primarySoft = Color(0xFFF3E3D7);
  static const onPrimarySoft = Color(0xFFF1DCCD);
  static const gold = Color(0xFF2F5E66);
  static const goldSoft = Color(0xFFDDEBEC);
  static const branch = Color(0xFFC49A76);
  static const deceasedCard = Color(0xFFF7F4F1);
  static const danger = Color(0xFFB3261E);
  static const dangerSoft = Color(0xFFF7DEDB);
}

class AppText {
  AppText._();

  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      GoogleFonts.fraunces(
          fontSize: size, fontWeight: FontWeight.w600, color: color, height: 1.15);

  static TextStyle body(double size,
          {FontWeight weight = FontWeight.w400,
          Color color = AppColors.ink,
          double? height}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: weight, color: color, height: height);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.bg,
    );
    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      textTheme: text,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
        titleTextStyle: AppText.body(17, weight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppText.body(16, color: AppColors.ink3),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.primary, 1.5),
        errorBorder: border(AppColors.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppText.body(16, weight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppText.body(16, weight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppText.body(15, weight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.body(14, color: Colors.white),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        showDragHandle: true,
      ),
    );
  }
}
