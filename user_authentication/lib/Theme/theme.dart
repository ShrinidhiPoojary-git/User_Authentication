import 'package:flutter/material.dart';
import 'package:flutter_application/Theme/app_pallete.dart';

class AppTheme {
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppPallete.borderColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}