import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFFF6F2EB);
  static const ink = Color(0xFF282321);
  static const accent = Color(0xFF793D48);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      surface: background,
      onSurface: ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
