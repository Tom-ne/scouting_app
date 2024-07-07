import 'package:dartaframe/dartaframe.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/widgets/dataframe_table/reactive_checkbox_supplier.dart';
import 'package:scouting_app/widgets/dataframe_table/widget_supplier.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/model/team.dart';
import 'package:scouting_app/utils/team_stats.dart';
import 'package:scouting_app/db/repo/teams_list_repo.dart';

class StatisticsHandler with ChangeNotifier {
  final TeamsListObject teams;
  final onSelectedChangedNotifier = ChangeNotifier();
  final Set<Team> selectedBlueTeams = {};
  final Set<Team> selectedRedTeams = {};
  final List<DataFrame> _dataFrame = [DataFrame(), DataFrame()];
  int _backgroundDataFrame = 0;

  bool _loading = false;
  bool get isLoading => _loading;

  final List<void Function()> operations = [];
  bool executingOperations = false;
  void addOperationToExecute(void Function() operation) {
    operations.add(operation);
    if (executingOperations) return;
    executingOperations = true;
    executeAllOperations();
  }

  Future<void> executeAllOperations() async {
    while (operations.isNotEmpty) {
      operations.removeAt(0).call();
    }
    executingOperations = false;
  }

  StatisticsHandler({required this.teams}) {
    _dataFrame.forEach(initializeDataFrame);
    teams.removeListener(() => addOperationToExecute(teamsRepoListeners));
    teams.addListener(() => addOperationToExecute(teamsRepoListeners));
  }

  DataFrame get df => _dataFrame[1 - _backgroundDataFrame];
  DataFrame get dfBackGround => _dataFrame[_backgroundDataFrame];
  set dfBackGround(DataFrame value) => _dataFrame[_backgroundDataFrame] = value;

  void switchDataframes() => _backgroundDataFrame = 1 - _backgroundDataFrame;

  void initializeDataFrame(DataFrame df) {
    final columns = <DataFrameColumn>[];
    StatisticsConstants.dataFrameColumnsTypes.forEach((name, type) {
      final column = DataFrameColumn(name: name, type: type);
      columns.add(column);
    });

    df.setColumns(columns);
  }

  void sortDataByColumnAsync(String columnName, bool ascending) {
    addOperationToExecute(() => sortDataByColumn(columnName, ascending));
  }

  void sortDataByColumn(String columnName, bool ascending) {
    if (columnName != StatisticsConstants.teamNameKey) {
      if (StatisticsConstants.dataFrameColumnsTypes[columnName] != num) return;
    }
    _loading = true;
    notifyListeners();
    dfBackGround = df.copy_();
    dfBackGround.sort(columnName, compare: (a, b) {
      if (a == null) return b == null ? 0 : 1;
      if (b == null) return -1;
      if (columnName == StatisticsConstants.teamNameKey) {
        int aVal = int.parse((a as String).split("-").first);
        int bVal = int.parse((b as String).split("-").first);
        return (Comparable.compare(aVal, bVal) * (ascending ? 1 : -1));
      }
      return (Comparable.compare(a as double, b as double) *
          (ascending ? 1 : -1));
    });
    switchDataframes();
    _loading = false;
    notifyListeners();
  }

  Excel generateExcel() {
    final columnsToSave = df.columns.where((element) =>
        StatisticsConstants.dataFrameColumnsTypes[element.name] !=
        WidgetSupplier);
    final headers =
        columnsToSave.map((column) => TextCellValue(column.name)).toList();

    // Create a new Excel workbook and worksheet
    final excel = Excel.createExcel();
    const String sheetKey = 'Sheet1';
    excel.appendRow(sheetKey, headers); // Add headers to the worksheet
    Sheet sheet = excel[sheetKey];

    // Add data rows to the worksheet
    for (final Map row in df.rows) {
      final rowData = headers.map((column) {
        dynamic value = row[column];
        switch (value.runtimeType) {
          case int:
            return IntCellValue(value);
          case double:
            return DoubleCellValue(value);
          case bool:
            return FormulaCellValue(
                value ? 'True' : 'False'); // BoolCellValue(value);
          default:
            return TextCellValue(value.toString());
        }
      }).toList();
      sheet.appendRow(rowData);
    }
    // sheet.getColumnAutoFit(0);
    sheet.setColumnAutoFit(0); // make column width adjust to data
    return excel;
  }

  List<List<dynamic>> generateCSV() {
    List<List<dynamic>> csvData = [];
    final columnsToSave = df.columns.where((element) =>
        StatisticsConstants.dataFrameColumnsTypes[element.name] !=
        WidgetSupplier);

    // Extract column names as the first row
    csvData.add(columnsToSave.map((column) => column.name).toList());

    // Extract data rows
    for (final row in df.rows) {
      csvData.add(columnsToSave.map((column) => row[column.name]).toList());
    }
    return csvData;
  }

  bool onSelectChanged(String teamKey, {bool? newValue}) {
    Team? team = teams
        .where((team) =>
            "${team.id} - ${team.key}" == teamKey || team.id == teamKey)
        .firstOrNull;
    if (team == null) return false;
    if (newValue != null) {
      if (newValue && selectedBlueTeams.length + selectedRedTeams.length < 6) {
        if (selectedBlueTeams.length >= selectedRedTeams.length &&
            selectedBlueTeams.length < 2) {
          selectedBlueTeams.addAll(selectedRedTeams);
          selectedRedTeams.clear();
        }
        if ((selectedBlueTeams.length != 1 && selectedBlueTeams.length < 3) ||
            selectedRedTeams.length > selectedBlueTeams.length) {
          if (!selectedBlueTeams.contains(team)) {
            selectedBlueTeams.add(team);
          }
        } else {
          if (!selectedRedTeams.contains(team)) {
            selectedRedTeams.add(team);
          }
        }
        onSelectedChangedNotifier.notifyListeners();
      } else {
        selectedBlueTeams.remove(team);
        selectedRedTeams.remove(team);
        onSelectedChangedNotifier.notifyListeners();
      }
    }
    return selectedBlueTeams.contains(team) || selectedRedTeams.contains(team);
  }

  Color? checkBoxActiveColor(String teamKey) {
    Team? team = teams
        .where((team) => "${team.id} - ${team.key}" == teamKey)
        .firstOrNull;
    if (team == null) return null;
    if (selectedBlueTeams.contains(team)) return Colors.blue;
    if (selectedRedTeams.contains(team)) return Colors.red;
    return null;
  }

  bool isVsModeAvilable() {
    return selectedBlueTeams.length == selectedRedTeams.length &&
        selectedBlueTeams.isNotEmpty;
  }

  void teamsRepoListeners() {
    if (kDebugMode) {
      print("TeamsList Updated");
    }
    generateDataFrame();
    if (kDebugMode) {
      print("Table generated");
    }
    for (Team team in teams) {
      team.repo.removeListener(() => onTeamRepoUpdate(team));
      team.repo.addListener(() => onTeamRepoUpdate(team));
    }
  }

  void onTeamRepoUpdate(Team team, {bool? isChecked}) {
    addOperationToExecute(
        () => updateTeamRowInDataFrame(team, isChecked: isChecked));
  }

  void generateDataFrame() {
    _loading = true;
    notifyListeners();
    dfBackGround = DataFrame();
    initializeDataFrame(dfBackGround);
    for (Team team in teams) {
      dfBackGround.addRow(generateTeamRow(team));
    }
    dfBackGround.sort(StatisticsConstants.pointsPerGameKey, compare: (a, b) {
      if (a == null) return b == null ? 0 : 1;
      if (b == null) return -1;
      return 0;
    });
    switchDataframes();
    _loading = false;
    notifyListeners();
  }

  Map<String, Object> generateTeamRow(Team team) {
    Iterable<MatchModel> history = team.repo.matches;
    if (history.isEmpty) {
      return {StatisticsConstants.teamNameKey: "${team.id} - ${team.key}"};
    }
    TeamStats teamStats = TeamStats.fromHistory(team.repo.matches);

    Map<String, Object> averageStats = Map.fromEntries(
        StatisticsConstants.dataFrameColumnsTypes.keys.map((String columnName) {
      if (teamStats.containsKey(columnName)) {
        return MapEntry(columnName, teamStats[columnName]);
      }
      switch (columnName) {
        case StatisticsConstants.teamNameKey:
          return MapEntry(columnName, team.title);
        case StatisticsConstants.autoIntakeMostCommonNotesKey:
          {
            return MapEntry(columnName, findMostCommonNote(history));
          }
        case StatisticsConstants.robotWorkedGamesKey:
          final widgetSupplier = CheckBoxSupplier();
          widgetSupplier.addListener(() =>
              onTeamRepoUpdate(team, isChecked: widgetSupplier.isChecked));
          return MapEntry(columnName, widgetSupplier);
        default:
          throw Exception(
              "column $columnName ins't a key in TeamStats nor has special case for creating the dataframe");
      }
    }));
    return averageStats;
  }

  String findMostCommonNote(Iterable<ScoutModel> history) {
    List<String> intakeNotes = ["c1", "c2", "c3", "f1", "f2", "f3", "f4", "f5"];
    String total = history.fold(
        "",
        (value, element) =>
            value + element[StatisticsConstants.autoIntakeNotesKey]);
    Map<String, int> histogram = Map.fromEntries(
        intakeNotes.map((e) => MapEntry(e, countOccurrences(total, e))));
    int max = histogram.entries
        .reduce(
            (value, element) => value.value > element.value ? value : element)
        .value;
    if (max == 0) return "None";
    return intakeNotes
        .where((element) => (histogram[element] as int) >= max)
        .join(",");
  }

  int countOccurrences(String text, String substring) {
    if (substring.isEmpty) {
      return 0; // Empty substring can't occur
    }

    int count = 0;
    int startIndex = 0;

    while (startIndex < text.length) {
      int index = text.indexOf(substring, startIndex);
      if (index == -1) {
        break;
      }
      count++;
      startIndex = index + substring.length;
    }

    return count;
  }

  void updateTeamRowInDataFrame(Team team, {bool? isChecked}) {
    if (kDebugMode) {
      print("Update ${"${team.id} - ${team.key}"} Data Row");
    }
    _loading = true;
    notifyListeners();
    int rowIndex = df.rows.toList().indexWhere((element) =>
        element[StatisticsConstants.teamNameKey] == "${team.id} - ${team.key}");
    Iterable<MatchModel> history = team.repo.matches;
    Map<String, Object> rowToReplace = df.rows.elementAt(rowIndex);
    Map<String, Object> newRow = {};
    bool? checked = isChecked ??
        (rowToReplace[StatisticsConstants.robotWorkedGamesKey]
                as CheckBoxSupplier?)
            ?.isChecked;
    if (checked == true) {
      history = history.where((element) => element.didRobotWork);
    }
    CheckBoxSupplier? widgetSupplier =
        rowToReplace[StatisticsConstants.robotWorkedGamesKey]
            as CheckBoxSupplier?;
    if (widgetSupplier != null) {
      if (team.repo.matches.isEmpty) {
        widgetSupplier.removeListener(
            () => onTeamRepoUpdate(team, isChecked: widgetSupplier!.isChecked));
        widgetSupplier = null;
      } else if (isChecked != null) {
        widgetSupplier.isChecked = isChecked;
      }
    } else {
      if (team.repo.matches.isNotEmpty) {
        widgetSupplier = CheckBoxSupplier();
        widgetSupplier.addListener(
            () => onTeamRepoUpdate(team, isChecked: widgetSupplier!.isChecked));
      }
    }
    if (history.isEmpty) {
      newRow = {
        StatisticsConstants.teamNameKey: "${team.id} - ${team.key}",
        if (widgetSupplier != null)
          StatisticsConstants.robotWorkedGamesKey: widgetSupplier,
      };
    } else {
      TeamStats teamStats = TeamStats.fromHistory(history);
      for (String key in StatisticsConstants.dataFrameColumnsTypes.keys) {
        if (teamStats.containsKey(key)) {
          newRow[key] = teamStats[key];
        } else {
          switch (key) {
            case StatisticsConstants.teamNameKey:
              newRow[key] = "${team.id} - ${team.key}";
            case StatisticsConstants.robotWorkedGamesKey:
              if (widgetSupplier != null) {
                newRow[key] = widgetSupplier;
              }
            case StatisticsConstants.autoIntakeMostCommonNotesKey:
              {
                newRow[key] = findMostCommonNote(history);
              }
            default:
              throw Exception(
                  "column $key ins't a key in TeamStats nor has special case for creating the dataframe");
          }
        }
      }
    }
    if (rowIndex == -1) {
      df.addRow(newRow);
      _loading = false;
      notifyListeners();
      return;
    }
    dfBackGround = DataFrame();
    initializeDataFrame(dfBackGround);
    for (int index = 0; index < df.rows.length; index++) {
      if (index != rowIndex) {
        dfBackGround.addRow(df.rows.elementAt(index));
      } else {
        dfBackGround.addRow(newRow);
      }
    }
    switchDataframes();
    _loading = false;
    notifyListeners();
  }
}
