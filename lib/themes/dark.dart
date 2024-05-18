import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Style definitions for dark theme.
ThemeData darkTheme = ThemeData.dark(
  useMaterial3: true,
).copyWith(
  cardColor: const Color(0xff2a313d),
  dividerColor: Colors.white,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xff191D24),
    primary: Color(0xFF006D9C),
  ),
  textTheme: GoogleFonts.montserratTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 20.0),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        const Color(0xFF009fe3),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        Colors.white,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(
        Colors.white,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
    filled: true,
    fillColor: const Color(0xff191D24),
    focusedBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(0.0),
      borderSide: const BorderSide(
        width: 2,
        color: Color(0xff009fe3),
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(
        width: 2,
        color: Color(0xff2a313d),
      ),
    ),
  ),
);
