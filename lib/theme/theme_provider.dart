import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/utils/preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool get _darkMode => UserPreferences.instantGet(UserPreferences.themeModeKey);
  late ThemeMode _themeMode;
  late Icon _icon;

  bool get isDarkMode => _darkMode;
  ThemeMode get themeMode => _themeMode;
  Icon get icon => _icon;

  ThemeProvider() {
    isDarkMode = isDarkMode;
  }

  //Switching the themes
  set isDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    _icon = value ? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode);
    UserPreferences.set(UserPreferences.themeModeKey, value);
    notifyListeners();
  }

  void toggleMode() {
    isDarkMode = !isDarkMode;
    if (kDebugMode) {
      print("ThemeProvider.isDarkMode: $isDarkMode");
    }
  }
}
