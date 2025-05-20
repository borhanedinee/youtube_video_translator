import 'package:flutter/material.dart';

class AppThemes {
  static const Color primaryColor = Color(0xFF6F83F0); // Clair indigo

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 16, 30, 107), // Light gradient start
        Color.fromARGB(255, 121, 131, 208), // Light gradient end
      ],
    ),
  );

  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
