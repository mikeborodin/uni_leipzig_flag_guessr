import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true, // Enable Material 3 design
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple, // Base color for the theme
    brightness: Brightness.light, // Light theme
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.deepPurple[400], // AppBar background color
    foregroundColor: Colors.white, // AppBar text and icon color
  ),
  inputDecorationTheme: InputDecorationTheme(
    // Theme for TextField
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple[600]!, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    filled: true,
    fillColor: Colors.deepPurple[50]?.withValues(alpha: 100),
  ),
  cardTheme: CardTheme(
    // Theme for Cards
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
  ),
);
