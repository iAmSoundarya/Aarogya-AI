import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenMid = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF388E3C);
  static const Color accentGold = Color(0xFFF9A825);
  static const Color accentGoldLight = Color(0xFFFFD54F);
  static const Color surfaceLight = Color(0xFFF1F8F1);
  static const Color urgencyLowColor = Color(0xFF4CAF50);
  static const Color urgencyMedColor = Color(0xFFFF9800);
  static const Color urgencyHighColor = Color(0xFFF44336);
  static const Color urgencyCriticalColor = Color(0xFF9C27B0);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: accentGold,
          surface: Colors.white,
          background: const Color(0xFFF9FBF9),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceLight,
          selectedColor: primaryGreen.withOpacity(0.15),
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        fontFamily: 'NotoSansDevanagari',
        extensions: const [AarogyaColors()],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreenLight,
          secondary: accentGold,
          surface: const Color(0xFF1A2E1A),
          background: const Color(0xFF0D1A0D),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2E1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        fontFamily: 'NotoSansDevanagari',
      );
}

// Custom theme extension for urgency colors
class AarogyaColors extends ThemeExtension<AarogyaColors> {
  const AarogyaColors({
    this.urgencyLow = AppTheme.urgencyLowColor,
    this.urgencyMedium = AppTheme.urgencyMedColor,
    this.urgencyHigh = AppTheme.urgencyHighColor,
    this.urgencyCritical = AppTheme.urgencyCriticalColor,
  });

  final Color urgencyLow;
  final Color urgencyMedium;
  final Color urgencyHigh;
  final Color urgencyCritical;

  Color forLevel(int level) => switch (level) {
        1 => urgencyLow,
        2 => urgencyMedium,
        3 => urgencyHigh,
        _ => urgencyCritical,
      };

  @override
  AarogyaColors copyWith({
    Color? urgencyLow,
    Color? urgencyMedium,
    Color? urgencyHigh,
    Color? urgencyCritical,
  }) =>
      AarogyaColors(
        urgencyLow: urgencyLow ?? this.urgencyLow,
        urgencyMedium: urgencyMedium ?? this.urgencyMedium,
        urgencyHigh: urgencyHigh ?? this.urgencyHigh,
        urgencyCritical: urgencyCritical ?? this.urgencyCritical,
      );

  @override
  AarogyaColors lerp(AarogyaColors? other, double t) => this;
}
