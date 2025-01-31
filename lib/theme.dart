import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: false,
  primaryColor: Colors.blue[800],
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
    titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: false,
    labelStyle: TextStyle(color: Colors.grey),
    floatingLabelStyle: TextStyle(color: Colors.blue, fontSize: 18),
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent, width: 3),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[800],
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  ),
);
