import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_header.dart';
import 'package:scouting_app/utils/const_dictionary.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/pit_model.dart';

abstract class ScoutModel extends ConstDictionary with ChangeNotifier {
  static const String matchScoutingKey = "Match Scouting";
  static const String pitScoutingKey = "Pit Scouting";
  static const Map<String, Type> scoutTypes = {
    matchScoutingKey: MatchModel,
    pitScoutingKey: PitModel
  };
  final String teamId;
  final ChangeNotifier lockNotifier = ChangeNotifier();
  final ChangeNotifier allianceColorNotifier = ChangeNotifier();

  void notifyColor() {
    allianceColorNotifier.notifyListeners();
  }

  bool _isLocked = true;

  bool get locked => _isLocked;
  set locked(bool newValue) {
    _isLocked = newValue;
    lockNotifier.notifyListeners();
  }

  ScoutModel({required this.teamId, bool? locked})
      : _isLocked = locked ?? false,
        super();
  ScoutModel.fromJson(super.json, {required this.teamId}) : super.fromJson();

  String get scoutTypeValue => '';

  int get createdAt => this[StatisticsConstants.createdAtKey] ?? 0;

  int get lastModified => this[StatisticsConstants.lastModifiedKey] ?? '0';
  set lastModified(int newValue) =>
      super[StatisticsConstants.lastModifiedKey] = newValue;

  String get scouterName => this[StatisticsConstants.scouterNameKey] ?? '';
  set scouterName(String? newValue) =>
      this[StatisticsConstants.scouterNameKey] = newValue;

  List<StatisticsHeader> get properties {
    switch (scoutTypeValue) {
      case matchScoutingKey:
        return StatisticsConstants.scoutProperties.matchScoutProperties;
      case pitScoutingKey:
        return StatisticsConstants.scoutProperties.pitScoutProperties;
    }
    return const [];
  }

  @override
  Map<String, dynamic> get keysDefaultValues {
    Map<String, dynamic> result = {
      StatisticsConstants.createdAtKey:
          DateTime.now().toUtc().millisecondsSinceEpoch,
      StatisticsConstants.lastModifiedKey:
          DateTime.now().toUtc().millisecondsSinceEpoch,
      StatisticsConstants.scoutTypeKey: scoutTypeValue,
    };
    result.addAll({
      for (StatisticsHeader header in properties)
        for (final entry in header.reducedBottomDefaults.entries)
          entry.key: entry.value
    });
    return result;
  }

  static ScoutModel loadedFromJson(Map<String, dynamic> json,
      {required String teamId}) {
    String? loadedScoutType = json[StatisticsConstants.scoutTypeKey];
    if (loadedScoutType == null) {
      throw Exception("Json is not a Scout");
    }
    Type? scoutType = scoutTypes[loadedScoutType];
    switch (scoutType) {
      case const (MatchModel):
        return MatchModel.fromJson(json, teamId: teamId);
      case const (PitModel):
        return PitModel.fromJson(json, teamId: teamId);
      default:
        throw Exception("ScoutType $loadedScoutType is not in $scoutTypes");
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! ScoutModel) return false;
    if (other.scoutTypeValue != scoutTypeValue) return false;
    if (other.teamId != teamId) return false;

    return !keysDefaultValues.keys.any((key) => this[key] != other[key]);
  }

  @override
  void operator []=(String key, dynamic value) {
    if (this[key] == value) return;
    super[key] = value;
    if (key == StatisticsConstants.allianceColorKey) {
      allianceColorNotifier.notifyListeners();
    }
    lastModified = DateTime.now().toUtc().millisecondsSinceEpoch;
    notifyListeners();
  }

  @override
  int get hashCode => Object.hash(teamId, super.toJson());
}
