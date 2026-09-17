import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F8085);
  static const Color secondary = Color.fromARGB(255, 219, 241, 243);
  static const Color button = Color.fromARGB(255, 104, 167, 173);
  static const Color thirdly = Color.fromARGB(255, 53, 53, 100);
  static const Color details = Color.fromARGB(255, 231, 196, 138);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1A1A1A);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    buttonTheme: ButtonThemeData(buttonColor: button),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: button,
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
    ),
    buttonTheme: ButtonThemeData(buttonColor: button),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: button,
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
  );
}
