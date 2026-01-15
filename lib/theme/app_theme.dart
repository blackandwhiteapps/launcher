import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color background = Colors.black;
  static const Color foreground = Colors.white;
  static const Color foregroundMuted = Colors.white54;

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: background,
          primary: foreground,
          onPrimary: background,
          secondary: foreground,
          onSecondary: background,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: foreground,
            fontSize: 72,
            fontWeight: FontWeight.w200,
            letterSpacing: -2,
          ),
          displayMedium: TextStyle(
            color: foreground,
            fontSize: 48,
            fontWeight: FontWeight.w300,
          ),
          headlineLarge: TextStyle(
            color: foreground,
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
          headlineMedium: TextStyle(
            color: foreground,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
          bodyLarge: TextStyle(
            color: foreground,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: foreground,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          labelMedium: TextStyle(
            color: foregroundMuted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );

  static void setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}
