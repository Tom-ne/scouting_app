import 'package:excel/excel.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_header.dart';

class StatisticsInheritedHeader extends StatisticsHeader {
  static const String averageName = "Average";
  static const String medianName = "Median";
  static const String maxName = "Max";
  static const String percentageName = "Percentage";
  static const String mostCommonName = "Most Common";
  final StatisticsValueHeader parent;
  const StatisticsInheritedHeader({
    required super.name,
    super.showInOverview = true,
    required this.parent,
  }) : super(showInTemplate: false);

  String get key => parent.scoutValueKey;
  Type get keyType => parent.dataType;

  String formula(Sheet targetSheet, int reocuring, int headersColumnIndex) {
    String sheetKey = "'${targetSheet.sheetName}'";
    int matches = 0;
    int rowIndex = targetSheet.rows.indexWhere((row) {
      int columnIndex = headersColumnIndex;
      while (columnIndex >= 0 && row.elementAt(columnIndex)?.value == null) {
        columnIndex--;
      }
      if (columnIndex < 0) {
        return false;
      }
      final cell = row.elementAt(columnIndex);
      bool match = cell?.value.toString() == parent.name;
      if (match) {
        matches++;
      }
      return matches >= reocuring;
    });
    if (rowIndex == -1) return "";

    String startCell =
        "$sheetKey!${CellIndex.indexByColumnRow(columnIndex: headersColumnIndex + 1, rowIndex: rowIndex).cellId}";
    String endCell =
        "$sheetKey!${CellIndex.indexByColumnRow(columnIndex: targetSheet.maxColumns - 1, rowIndex: rowIndex).cellId}";
    String range = "$startCell:$endCell";
    switch (name) {
      case averageName:
        return 'SUMIFS($range, $range, "<>") / COUNTIFS($range, "<>")'; // 'AVERAGE(IF(ISNUMBER($range), $range))';
      case medianName:
        return 'MEDIAN($range)';
      case maxName:
        return 'MAX($range)';
      case percentageName:
        return 'TEXT(COUNTIF($range, TRUE)/COUNTA($range), "0.00%")';
      case mostCommonName:
        return 'IF(COUNTA($range) = 1, $startCell, INDEX($range, MODE(MATCH($range, $range, 0))))';
      default:
        return 'TEXT(SUM(COUNTIF($range, "$name"))/COUNTA($range), "0.00%")';
    }
  }
}
