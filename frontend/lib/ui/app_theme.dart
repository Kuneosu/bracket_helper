import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

final appTheme = ThemeData(
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(),
  scaffoldBackgroundColor: CST.white,
  useMaterial3: true,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: CST.labelColor,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderSide: BorderSide(color: CST.gray4)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: CST.primaryColor,
      foregroundColor: CST.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: CST.primaryColor,
      foregroundColor: CST.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: CST.primaryColor,
      foregroundColor: CST.white,
    ),
  ),
  primaryColor: CST.primaryColor,
  primaryColorLight: CST.primary20,
  primaryColorDark: CST.primary80,
);
