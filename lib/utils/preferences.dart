import 'package:flutter/foundation.dart';
import 'package:scouting_app/utils/in_memory/db_helper.dart';
import 'package:scouting_app/utils/in_memory/preference.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

final class UserPreferences with ChangeNotifier {
  static const themeModeKey = "Theme_Mode";
  static const flipFieldHorizontaly = "horizontal_flip";
  static const flipFieldVerticaly = "vertical_flip";
  static const preferences = PreferencesList(
    preferences: [
      Preference<bool>(key: themeModeKey, defaultValue: false),
      Preference<bool>(key: flipFieldHorizontaly, defaultValue: false),
      Preference<bool>(key: flipFieldVerticaly, defaultValue: false),
    ]
  );
  static final Map<String, dynamic> _values = {};
  static final Map<String, bool> _valuesUpdated = {
    for (Preference preference in preferences) preference.key : false
  };

  static final preferencesNotifier = ChangeNotifier();

  static Future<void> init() async {
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
    }
    
    // Fetch initial data from the database
    final Map<String, dynamic> valuesOrDefaults = {};
    for (Preference preference in preferences.preferences) {
      dynamic value = await UserPreferences.get(preference.key);
      valuesOrDefaults[preference.key] = value ?? preference.defaultValue;
    }

    // Clear the existing database (optional)
    await PreferencesDBHelper.clear();

    // Recreate the database with the fetched initial data
    Future.wait(preferences.keys.map((key) => UserPreferences.set(key, valuesOrDefaults[key])));
  }

  static Future<void> set(String key, dynamic value) async {
    Preference preference = preferences[key];
    if (value.runtimeType != preference.targetType) return;
    _valuesUpdated[key] = false;
    if (kDebugMode) {
      print("set(Key: $key, Value: $value)");
    }
    await PreferencesDBHelper.set(key, value);
    _values[key] = value;
    _valuesUpdated[key] = true;
    if (kDebugMode) {
      dynamic result = await get(key);
      print("compare(set: $value, get: $result) = ${value == result}");
    }
    preferencesNotifier.notifyListeners();
  }

  static Future<dynamic> get(String key) async {
    Preference preference = preferences[key];
    if (_valuesUpdated[key] == true) return _values[key];
    dynamic result = await PreferencesDBHelper.get(key);
    if (kDebugMode) {
      print("get(Key: $key) = Value: $result");
    }
    if (result.runtimeType != preference.targetType) return null;
    _values[key] = result;
    _valuesUpdated[key] = true;
    return result;
  }

  static dynamic instantGet(String key) {
    return _values[key] ?? preferences[key].defaultValue;
  }
}
