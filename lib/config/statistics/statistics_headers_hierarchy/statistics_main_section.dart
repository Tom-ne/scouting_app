import 'dart:math';

import 'package:excel/excel.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_header.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_inhereted_header.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_section.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/team.dart';

class StatisticsMainSection extends StatisticsSection {
  final StatisticsHeader sharedValueTop;
  final StatisticsHeader sharedValueBottom;
  final StatisticsHeader matchScoutHeader;
  final StatisticsHeader pitScoutHeader;
  StatisticsMainSection({
    required super.name,
    super.showInOverview = true,
    required this.sharedValueTop,
    required this.matchScoutHeader,
    required this.pitScoutHeader,
    required this.sharedValueBottom,
  }) : super(children: [
          sharedValueTop,
          matchScoutHeader,
          pitScoutHeader,
          sharedValueBottom
        ]);

  List<StatisticsHeader> get matchScoutProperties =>
      [sharedValueTop, matchScoutHeader, sharedValueBottom];
  List<StatisticsHeader> get pitScoutProperties =>
      [sharedValueTop, pitScoutHeader, sharedValueBottom];

  void fillTeamSheet(Sheet sheet, Iterable<MatchModel> matches,
      List<StatisticsHeader> properties,
      {int? overallDepth, List<CellValue?>? rowHeaders}) {
    overallDepth ??= StatisticsHeader.getDepth(properties);
    rowHeaders ??= [];
    for (StatisticsHeader item in properties) {
      int rowIndex = sheet.maxRows;
      if (item is StatisticsSection) {
        int columnIndex = rowHeaders.length;
        int repeat = overallDepth - (item.depth - 1);
        fillTeamSheet(sheet, matches, item.subHeaders,
            overallDepth: item.depth - 1,
            rowHeaders: [
              ...rowHeaders,
              ...List.generate(repeat, (index) => TextCellValue(item.name))
            ]);

        sheet.merge(
          CellIndex.indexByColumnRow(
              columnIndex: columnIndex, rowIndex: rowIndex),
          CellIndex.indexByColumnRow(
              columnIndex: columnIndex + repeat - 1,
              rowIndex: sheet.maxRows - 1),
        );
      } else if (item is StatisticsValueHeader) {
        final List<CellValue?> data = matches.map((matchModel) {
          final value = item.parseToHeader(matchModel[item.scoutValueKey]);
          if (value == null) {
            return null;
          }
          switch (value.runtimeType) {
            case int: return IntCellValue(value);
            case double: return DoubleCellValue(value);
            case bool: return FormulaCellValue(value ? 'True' : 'False');// BoolCellValue(value);
            default: return TextCellValue(value.toString());
          }
        }).toList();
        sheet.appendRow([
          ...rowHeaders,
          ...List.generate(overallDepth, (index) => TextCellValue(item.name)),
          ...data
        ]);
        sheet.merge(
          CellIndex.indexByColumnRow(
              columnIndex: rowHeaders.length, rowIndex: sheet.maxRows - 1),
          CellIndex.indexByColumnRow(
              columnIndex: rowHeaders.length + overallDepth - 1,
              rowIndex: sheet.maxRows - 1),
        );
      }
    }
  }

  void fillOverviewSheetHeaders(Sheet sheet, List<StatisticsHeader> properties,
      {int? maxDepth, List<bool>? mergeUp}) {
    maxDepth ??= StatisticsHeader.getMaxDepth(properties);
    if (maxDepth <= 0) return;
    mergeUp ??= [for (final _ in properties) false];
    List<StatisticsHeader> nextRowProperties = [];
    List<bool> nextMergeUp = [];
    final List<CellValue?> data = [null];
    for (StatisticsHeader item in properties) {
      data.addAll(List.generate(item.collectiveLength, (index) => TextCellValue(item.name)));
      if (maxDepth > item.maxDepth) {
        nextRowProperties.add(item);
        nextMergeUp.add(true);
      } else {
        if (maxDepth <= 1) continue;
        nextRowProperties.addAll(item.subHeaders);
        nextMergeUp
            .addAll(List.generate(item.subHeaders.length, (index) => false));
      }
    }
    sheet.appendRow(data);
    if (sheet.maxRows > 1) {
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: sheet.maxRows - 2, columnIndex: 0),
        CellIndex.indexByColumnRow(rowIndex: sheet.maxRows - 1, columnIndex: 0),
      );
    }
    int columnIndex = 1;
    for (int index = 0; index < properties.length; index++) {
      final item = properties[index];
      sheet.merge(
        CellIndex.indexByColumnRow(
          rowIndex: sheet.maxRows - 1,
          columnIndex: columnIndex,
        ),
        CellIndex.indexByColumnRow(
            rowIndex: sheet.maxRows - 1,
            columnIndex: columnIndex + item.collectiveLength - 1),
      );
      if (mergeUp[index]) {
        sheet.merge(
          CellIndex.indexByColumnRow(
              rowIndex: sheet.maxRows - 2, columnIndex: columnIndex),
          CellIndex.indexByColumnRow(
              rowIndex: sheet.maxRows - 1, columnIndex: columnIndex),
        );
      }
      sheet
          .cell(CellIndex.indexByColumnRow(
            rowIndex: sheet.maxRows - 1,
            columnIndex: columnIndex,
          ))
          .cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        bold: item is StatisticsSection,
      );
      columnIndex += item.collectiveLength;
    }
    fillOverviewSheetHeaders(sheet, nextRowProperties,
        maxDepth: maxDepth - 1, mergeUp: nextMergeUp);
  }

  void fillOverviewSheetData(Excel excel, Sheet overview,
      List<StatisticsHeader> properties, int headersColumnIndex) {
    for (MapEntry entry in excel.sheets.entries) {
      if (entry.value == overview) continue;
      overview.appendRow([TextCellValue(entry.key)]);
      int columnIndex = 0;
      final Map<String, int> reocuring = {};
      final Set<StatisticsHeader> checked = {};
      for (StatisticsHeader header in properties) {
        columnIndex++;
        if (header is! StatisticsInheritedHeader) continue;
        String key = header.parent.name;
        reocuring[key] = (reocuring[key] ?? 0) + 1;
        if (checked.contains(header.parent)) {
          reocuring[key] = (reocuring[key] ?? 1) - 1;
        } else {
          checked.add(header.parent);
        }
        String formula = header.formula(
            entry.value, reocuring[key] as int, headersColumnIndex);
        overview
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: columnIndex,
                rowIndex: overview.maxRows - 1,
              ),
            )
            .setFormula(formula);
      }
    }
  }

  Excel generateExclusiveExcel(List<Team> teams) {
    // Create a new Excel workbook and worksheet
    final excel = Excel.createExcel();
    final List<StatisticsHeader> properties =
        StatisticsConstants.scoutProperties.matchScoutProperties;
    int singleTeamHeaderColumns = StatisticsHeader.getDepth(properties);
    for (Team team in teams) {
      Iterable<MatchModel> matches = team.repo.matches;
      if (matches.isEmpty) continue;
      String sheetKey = team.header;
      sheetKey = sheetKey.substring(
          0,
          min(31,
              sheetKey.length)); // sheet name must not extend 31 characters!
      // new special cases for team CAN://Bus
      sheetKey = sheetKey.replaceAll(':', '#');
      sheetKey = sheetKey.replaceAll('/', '@');
      sheetKey = sheetKey.replaceAll('*', '!');
      Sheet sheet = excel[sheetKey];
      sheet.appendRow([
        ...List.generate(singleTeamHeaderColumns, (index) => null),
        ...team.repo.matchesKeys.map((e) => TextCellValue(e))
      ]);

      sheet.merge(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: sheet.maxRows - 1,
          ),
          CellIndex.indexByColumnRow(
            columnIndex: singleTeamHeaderColumns - 1,
            rowIndex: sheet.maxRows - 1,
          ));

      // Add data rows to the worksheet
      fillTeamSheet(sheet, matches, properties);
      for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
        for (int columnIndex = 0;
            columnIndex < singleTeamHeaderColumns;
            columnIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: columnIndex,
              rowIndex: rowIndex,
            ),
          );
          cell.cellStyle = CellStyle(
            rotation: 0,
            verticalAlign: VerticalAlign.Center,
            horizontalAlign: HorizontalAlign.Center,
          );
        }
      }
      for (int columnIndex = 0; columnIndex < sheet.maxColumns; columnIndex++) {
        sheet.setColumnAutoFit(columnIndex); // make column width adjust to data
      }
    }

    String mainSheet = "Overview";
    excel.rename(excel.getDefaultSheet() ?? 'Sheet1', mainSheet);
    excel.setDefaultSheet(mainSheet);
    Sheet sheet = excel[mainSheet];
    final overviewProperties =
        StatisticsConstants.scoutProperties.clearForOverview;
    fillOverviewSheetHeaders(sheet, overviewProperties.children);
    fillOverviewSheetData(excel, sheet, overviewProperties.bottomHeaders,
        singleTeamHeaderColumns - 1);
    for (int index = 0; index < sheet.maxColumns; index++) {
      sheet.setColumnAutoFit(index); // make column width adjust to data
    }
    return excel;
  }
}
