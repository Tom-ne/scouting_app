import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/utils/const_dictionary.dart';
import 'package:scouting_app/db/model/match_model.dart';

enum CompareType { avg, median, best, worst, total }

class TeamStats extends ConstDictionary {
  @override
  Map<String, dynamic> get keysDefaultValues =>
      {for (String element in StatisticsConstants.teamStatsKeys) element: 0};

  TeamStats() : super();
  TeamStats.fromHistory(Iterable<MatchModel> matches,
      {CompareType compareType = CompareType.avg})
      : super() {
    Map<String, List<dynamic>> data = {
      for (String key in keysDefaultValues.keys) key: []
    };
    for (MatchModel match in matches) {
      for (String key in keysDefaultValues.keys) {
        if (match.containsKey(key) && match[key] is num) {
          data[key]!.add(match[key]);
          continue;
        }
        switch (key) {
          case StatisticsConstants.pointsPerGameKey:
            {
              data[key]!.add(match.totalPoints);
            }
          case StatisticsConstants.autoPointsPerGameKey:
            {
              data[key]!.add(match.autoPoints);
            }
          case StatisticsConstants.autoIntakeNotesKey:
            {
              data[key]!.add(match[key]
                  .toString()
                  .characters
                  .where((p0) => p0 == "f")
                  .length);
            }
          case StatisticsConstants.teleopNotesPerGame:
            {
              data[key]!.add(
                  (match[StatisticsConstants.teleopSpeakerNoteKey] ?? 0) +
                      (match[StatisticsConstants.teleopAmpNoteKey] ?? 0));
            }
          case StatisticsConstants.teleopPointsPerGameKey:
            {
              data[key]!.add(match.teleopPoints);
            }
          case StatisticsConstants.teleopClimbedKey:
            {
              data[key]!.add(match.climbScore);
            }
          case StatisticsConstants.teleopTrapKey:
            {
              data[key]!.add(match.trapScore);
            }
          default:
            throw Exception(
                "MatchModel does not have any attribute named $key");
        }
      }
    }
    if (matches.isEmpty) return;
    for (String key in data.keys) {
      List values = data[key]!;
      if (compareType == CompareType.median) {
        values.sort();
        int maxIndex = values.length - 1;
        int index = ((maxIndex - maxIndex % 2) / 2).round();
        this[key] = values.length % 2 == 1
            ? values[index]
            : (values[index] + values[index + 1]) / 2;
        continue;
      }
      dynamic Function(dynamic, dynamic) combine =
          (value, element) => (value ?? 0) + (element ?? 0);
      switch (compareType) {
        case CompareType.best:
          combine = (value, element) => value >= element ? value : element;
        case CompareType.worst:
          combine = (value, element) => value <= element ? value : element;
        default:
          null;
      }
      this[key] = values.reduce(combine);
      if (compareType == CompareType.avg) {
        this[key] /= values.length;
        this[key] = _round(this[key], 3);
      }
    }
  }

  factory TeamStats.fromCombination(Iterable<TeamStats> combination) {
    TeamStats sum = TeamStats();
    for (TeamStats stats in combination) {
      sum += stats;
    }
    return sum;
  }

  TeamStats operator +(TeamStats other) {
    TeamStats result = TeamStats();
    for (String key in keysDefaultValues.keys) {
      result[key] = this[key] + other[key];
    }
    return result;
  }

  static dynamic _round(dynamic val, int places) {
    num mod = pow(10.0, places);
    return (val * mod).round() / mod;
  }
}
