import 'package:flutter/material.dart';

class AppThemeOptions {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.indigoAccent),
    primaryColor: Colors.indigoAccent,
    secondaryHeaderColor: Colors.indigoAccent.shade100,
    appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 83, 108, 245), titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),),
    tabBarTheme: TabBarTheme(labelColor: Colors.black, unselectedLabelColor: Colors.indigo[800]),
    cardColor: const Color(0xFFC4EAFB),
    textButtonTheme: const TextButtonThemeData(style: ButtonStyle(textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)))),
    iconTheme: const IconThemeData(color: Colors.black),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[850],
    canvasColor: Colors.grey[850],
    appBarTheme: const AppBarTheme(color: Colors.black, titleTextStyle: TextStyle(color: Colors.white, fontSize: 18)),
    tabBarTheme: const TabBarTheme(labelColor: Colors.white, unselectedLabelColor: Colors.blue),
    drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[850]),
    dividerTheme: const DividerThemeData(color: Colors.transparent),
    textTheme: Typography.whiteCupertino,
    primaryColor: Colors.indigo[900],
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.indigo[900]),
    secondaryHeaderColor: Colors.indigo.shade700,
    colorScheme: ColorScheme.dark(
        secondary: Colors.indigo.shade700, primary: Colors.indigo.shade200),
    cardColor: const Color(0xFF1B1B1B),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
/*
theme: ThemeData(
        primaryColor: Colors.indigoAccent,
        brightness: Brightness.light,
        textTheme: Typography.blackCupertino,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.indigo[900],
        brightness: Brightness.dark,
        textTheme: Typography.whiteCupertino,
      ),
*/