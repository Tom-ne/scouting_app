import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:dartaframe/dartaframe.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';

class MatchesSetup extends StatelessWidget {
  final CSVpicker csvPicker = CSVpicker();

  MatchesSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Column(
        children: [
          AcceptButton(
              onPressed: csvPicker.pickFile, child: const Icon(Icons.upload)),
          ListView(
            scrollDirection: Axis.vertical,
            children: const [],
          )
        ],
      ),
    );
  }
}

class CSVpicker {
  PlatformFile? pickedFile;
  DataFrame? df;

  Future<DataFrame> _createDataFrameFromCsvString(String csvString) async {
    // Parse the CSV string
    final csvData = const CsvToListConverter(eol: '\n').convert(csvString);

    if (csvData.isEmpty) {
      throw Exception('CSV data is empty.');
    } else if (csvData.length == 1) {
      throw Exception(
          'CSV data is in the wrong format! use "\\n" to end lines and "," to seperate items');
    }

    // Extract column names from the first row
    final columnNames =
        csvData[0].map<String>((value) => value.toString()).toList();

    // Create a List of maps to hold the data
    final List<Map<String, dynamic>> dataList = [];
    for (int i = 1; i < csvData.length; i++) {
      final dataRow = csvData[i];
      if (dataRow.length != columnNames.length) {
        throw Exception('Inconsistent number of columns in CSV data.');
      }
      final rowMap = <String, dynamic>{};
      for (int j = 0; j < dataRow.length; j++) {
        rowMap[columnNames[j]] = dataRow[j];
      }
      dataList.add(rowMap);
    }

    // Create a DataFrame
    return DataFrame.fromRows(dataList);
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['csv']);

    // if no file is picked
    if (result == null || result.count == 0) return;

    // we get the file from result object
    pickedFile = result.files.first;
    if (kDebugMode) {
      print("File Name: ${pickedFile!.name}");
    }
    final data = pickedFile!.bytes;
    if (data!.isEmpty) return;

    String csvString = utf8.decode(data); // Convert bytes to a string
    if (kDebugMode) {
      print("Converted data bytes to csvString");
    }

    // fileToDisplay = File(pickedFile!.path.toString());
    df = await _createDataFrameFromCsvString(csvString);
    if (kDebugMode) {
      print("Converted to DataFrame");
    }
    df?.show();
  }
}
