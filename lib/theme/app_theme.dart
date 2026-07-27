import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFE2C55), // TikTok Red/Pink
      secondary: Color(0xFF25F4EE), // TikTok Cyan
      surface: Color(0xFF121212),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  );
}
