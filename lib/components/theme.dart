import 'package:flutter/material.dart';

final bytebankTheme = ThemeData(
  primaryColor: Colors.green[900],
  colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.green
  ).copyWith(
      secondary: Colors.blueAccent[700]), // cor secundaria do tema
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blueAccent[700],
    textTheme: ButtonTextTheme.primary,
  ),
);