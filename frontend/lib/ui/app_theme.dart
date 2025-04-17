import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final appTheme = ThemeData(
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(),
  scaffoldBackgroundColor: CST.white,
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    backgroundColor: CST.primary100,
    foregroundColor: CST.white,
    elevation: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TST.normalTextRegular
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
