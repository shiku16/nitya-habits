import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // 🌱 Primary colors
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50), // calm green
      primary: const Color(0xFF4CAF50),
      secondary: const Color(0xFF4FC3F7), // soft blue
      background: const Color(0xFFF5FDF7), // light green-white
      brightness: Brightness.light,
    ),

    // 🌱 Background
    scaffoldBackgroundColor: const Color(0xFFF5FDF7),

    // 🌱 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5FDF7),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF1B5E20),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
    ),

    // 🌱 Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
    ),

    // 🌱 Text
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Color(0xFF2E7D32),
      ),
    ),
  );
}
