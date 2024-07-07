import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PreferencesDBHelper {
  static const String tableName = 'preferences';
  static const String tableKeyName = 'key';
  static const String tableValueName = 'value';
  static Future<Database?> database() async {
    // if (kIsWeb) return null;
    return openDatabase(
      join(await getDatabasesPath(), 'preferences_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName($tableKeyName TEXT PRIMARY KEY, $tableValueName TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<int?> clear() async {
    // clear the existing data before recreating the database.
    final Database? db = await PreferencesDBHelper.database();
    return db?.delete(tableName);
  }

  static Future<dynamic> get(String key) async {
    final Database? db = await PreferencesDBHelper.database();
    final List<Map<String, dynamic>>? maps = await db?.query(
      tableName,
      where: '$tableKeyName = ?',
      whereArgs: [key]
    );

    if (maps == null || maps.isEmpty) return null;

    final value = maps.first[tableValueName];
    return _parseValue(value);
  }

  static Future<int?> set(String key, dynamic value) async {
    final Database? db = await PreferencesDBHelper.database();
    int? result = await db?.insert(
      tableName,
      {tableKeyName: key, tableValueName: value.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  static dynamic _parseValue(String value) {
    if (value == 'true' || value == 'false') {
      return value == 'true';
    } else if (int.tryParse(value) != null) {
      return int.parse(value);
    } else if (double.tryParse(value) != null) {
      return double.parse(value);
    } else {
      return value;
    }
  }
}
