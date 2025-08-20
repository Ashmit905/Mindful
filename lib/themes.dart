import 'package:flutter/material.dart';

// Light Theme
final lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(color: Colors.lightBlue[200]), // Set appBar color here
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.lightBlue[200],
  ),
  textTheme: Typography.blackCupertino.apply(
      bodyColor: Colors.black,
      displayColor: Colors.black
  ),
);

// Dark Theme
final darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(color: Colors.deepPurple), // Set appBar color here
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple, // Button Color
  ),
  textTheme: Typography.blackCupertino.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white
  ),
  iconTheme: IconThemeData(
    color: Colors.lightBlue[200], // Icon color for dark theme
  ),
);