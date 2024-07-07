import 'dart:io';
import 'dart:ui';

import 'package:csv/csv.dart';
import 'package:download/download.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
// import 'package:protect/protect.dart';
import 'package:share_plus/share_plus.dart';

class FilesHandler {
  static Future<String> get _externalStoragePath async {
    final externalDirectories = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    final directory = externalDirectories!.first;
    return directory.path;
  }

  static String get password => StatisticsConstants.password;

  static Future<String> localFilePath(String filename) async {
    if (kIsWeb) return filename;
    final path = await _externalStoragePath;
    return '$path/$filename';
  }

  static Future<void> export(String filename, {Excel? excel, List<List<dynamic>>? csvData}) async {
    assert((excel != null) ^ (csvData != null)); // require only one of them.
    bool permissionGranted;
    if (kIsWeb) {
      permissionGranted = true;
    } else {
      permissionGranted = await requestStoragePermissions();
    }
    if (permissionGranted) {
      // Permission Granted!
      if (excel != null) {
        await exportExcel(excel, filename);
      }
      else if (csvData != null) {
        await exportCSV(csvData, filename);
      }
      else {
        throw Exception("Code should never reach here");
      }
    }
    else {
      // Permission NOT Granted!
    }
  }

  static Future<bool> requestStoragePermissions() {
    List<Permission> requests = [
      Permission.storage,
      Permission.photos,
    ];
    return requestPermissions(requests);
  }

  static Future<bool> requestPermissions(List<Permission> requests) async {
    final requestsStatuses = (await requests.request()).values;
    return requestsStatuses.any((element) => element.isGranted);
  }
  
  static Future<void> share(String filename, {Excel? excel, List<List<dynamic>>? csvData}) async {
    assert((excel != null) ^ (csvData != null)); // require only one of them.
    if (kIsWeb) return; // irelevant, supported only for devices.

    if (excel != null) {
      await shareExcel(excel, filename);
    }
    else if (csvData != null) {
      await shareCSV(csvData, filename);
    }
    else {
      throw Exception("Code should never reach here");
    }
  }

  static List<int> encryptExcelData(Excel excel) {
    List<int> excelData = excel.encode()!;

    // TODO: upgrade "protect" package to match latest "http" package

    // // Encrypt the file:
    // ProtectResponse encryptedResponse = Protect.encryptBytes(excelData, password);
    // if (kDebugMode) {
    //   print("Encrypted file data");
    // }
    // if (!encryptedResponse.isDataValid) {
    //   throw Exception("Corrupted file");
    // }
    // return encryptedResponse.processedBytes!.toList();

    return excelData;
  }

  static Future<void> shareCSV(List<List<dynamic>> csvData, String filename, {String? subject, String? text, Rect? sharePositionOrigin}) async {
    String csv = const ListToCsvConverter().convert(csvData);
    await shareFileInMemory(csv.codeUnits, "$filename.csv", subject: subject, text: text, sharePositionOrigin: sharePositionOrigin);
  }

  static Future<void> shareExcel(Excel excel, String filename, {String? subject, String? text, Rect? sharePositionOrigin}) async {
    List<int> excelData = encryptExcelData(excel);
    await shareFileInMemory(excelData, "$filename.xlsx", subject: subject, text: text, sharePositionOrigin: sharePositionOrigin);
  }

  static Future<void> shareFileInMemory(List<int> fileData, String filename, {String? subject, String? text, Rect? sharePositionOrigin}) async {
    if (kIsWeb) return;

    // Save the data to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/$filename';
    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(fileData);

    // Share the saved file using the share package
    await Share.shareXFiles([XFile(tempFilePath)], subject: subject, text: text, sharePositionOrigin: sharePositionOrigin);
  }

  static Future<void> exportCSV(List<List<dynamic>> csvData, String filename) async {
    String csv = const ListToCsvConverter().convert(csvData);
    await exportFile(csv.codeUnits, "$filename.csv");
  }

  static Future<void> exportExcel(Excel excel, String filename) async {
    List<int> excelData = encryptExcelData(excel);
    await exportFile(excelData, "$filename.xlsx");
  }

  static Future<void> exportFile(List<int> fileData, String filename) async {
    // Generate a file path
    final filePath = await localFilePath(filename);
    if (kDebugMode) {
      print("Path to save file: $filePath");
    }
    
    // Save the data to the file
    download(Stream.fromIterable(fileData), filePath);

    // Optional: Open the file with a viewer
    OpenFilex.open(filePath);
  }
}