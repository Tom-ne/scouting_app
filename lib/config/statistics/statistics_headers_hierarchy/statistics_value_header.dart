import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_header.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_inhereted_header.dart';

// enum InputTypes { freeStyle, boolCheckbox, chooseOption, intBar, doubleRate }

// class StatisticsLockableValueHeader extends StatisticsValueHeader {
//   final dynamic lockedValue;

//   const StatisticsLockableValueHeader({
//     required super.name,
//     required super.key,
//     required super.dataType,
//     super.showInOverview = true,
//     super.inputType,
//     required this.lockedValue,
//   }) : super();
// }

class StatisticsDropdownHeader extends StatisticsValueHeader {
  final List<String> possibleValues;
  final Widget Function(String option)? mapFunction;
  final bool? showUnderline;

  const StatisticsDropdownHeader({
    required super.name,
    required super.scoutValueKey,
    super.showInOverview = true,
    this.possibleValues = const [],
    this.mapFunction,
    this.showUnderline,
    super.singleValue = false,
    String? super.defaultValue,
  }) : super(dataType: String);

  @override
  String get defaultValue => super.defaultValue ?? possibleValues.first;

  @override
  List<StatisticsHeader> get subHeaders {
    if (singleValue) return const [];
    return super.subHeaders
      ..addAll([
        for (String childName in possibleValues)
          StatisticsInheritedHeader(
            name: childName,
            parent: this,
          ),
      ]);
  }
}

class StatisticsTextFieldHeader extends StatisticsValueHeader {
  final bool readOnly;
  final int? maxLines;
  final InputBorder? border;
  final String? hintText;

  const StatisticsTextFieldHeader({
    required super.name,
    required super.scoutValueKey,
    super.showInOverview = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.border = const OutlineInputBorder(),
    this.hintText,
    super.singleValue = false,
    String? super.defaultValue,
  }) : super(dataType: String);

  @override
  String get defaultValue => super.defaultValue ?? '';
}

class StatisticsCheckboxHeader extends StatisticsValueHeader {
  const StatisticsCheckboxHeader({
    required super.name,
    required super.scoutValueKey,
    super.showInOverview = true,
    super.singleValue = false,
    bool? super.defaultValue,
    super.dataType = bool,
  });

  dynamic parseValue(bool value) {
    if (dataType == bool) return value;
    return value == true ? 1 : 0;
  }

  @override
  bool parseToHeader(dynamic value) {
    if (value is bool) return value;
    return value != 0;
  }

  @override
  dynamic get defaultValue => parseValue(super.defaultValue ?? false);
}

class StatisticsCountHeader extends StatisticsValueHeader {
  const StatisticsCountHeader({
    required super.name,
    required super.scoutValueKey,
    super.showInOverview = true,
    super.showInTemplate = true,
    super.singleValue = false,
    super.defaultValue,
  }) : super(dataType: num);

  @override
  dynamic parseToHeader(value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return value.characters.where((p0) => p0=="f").length;
    }
    return super.parseToHeader(value);
  }

  @override
  dynamic get defaultValue => super.defaultValue ?? 0;
}

class StatisticsFieldHeader extends StatisticsValueHeader {
  const StatisticsFieldHeader({
    required super.name,
    required super.scoutValueKey,
    super.showInOverview = false,
    super.singleValue = false,
    String? super.defaultValue,
  }) : super(dataType: String);

  @override
  String get defaultValue => super.defaultValue ?? "";
}

class StatisticsRateHeader extends StatisticsValueHeader {
  final double minValue;
  final double maxValue;
  final int devisions;

  const StatisticsRateHeader({
    required super.name,
    required super.scoutValueKey,
    super.showInOverview = true,
    this.minValue = 1,
    this.maxValue = 5,
    this.devisions = 4,
    super.singleValue = false,
    double? super.defaultValue,
  }) : super(dataType: num);

  @override
  int get defaultValue => super.defaultValue ?? minValue.toInt();
}

class StatisticsValueHeader extends StatisticsHeader {
  final String scoutValueKey;
  final Type dataType;
  final bool singleValue;
  final dynamic _defaultValue;

  const StatisticsValueHeader({
    required super.name,
    required this.scoutValueKey,
    required this.dataType,
    required this.singleValue,
    required dynamic defaultValue,
    super.showInTemplate = true,
    super.showInOverview = true,
  }) : _defaultValue = defaultValue, super();

  dynamic parseToHeader(value) => value;

  dynamic get defaultValue => _defaultValue;

  @override
  int get depth => 1;

  @override
  List<StatisticsHeader> get subHeaders {
    if (singleValue) return const [];
    switch (dataType) {
      case const (num):
        const List<String> subHeadersNames = [
          StatisticsInheritedHeader.averageName,
          StatisticsInheritedHeader.medianName,
          StatisticsInheritedHeader.maxName
        ];
        return [
          for (String childName in subHeadersNames)
            StatisticsInheritedHeader(
              name: childName,
              parent: this,
            ),
        ];
      case const (bool):
        return [
          StatisticsInheritedHeader(
            name: StatisticsInheritedHeader.percentageName,
            parent: this,
          ),
        ];
      case const (String):
        return [
          StatisticsInheritedHeader(
            name: StatisticsInheritedHeader.mostCommonName,
            parent: this,
          ),
        ];
      default:
        throw Exception(
            "Type $dataType is not handled at class StatisticsValueHeader");
    }
  }
}
