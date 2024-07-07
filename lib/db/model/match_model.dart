import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/db/model/scout_model.dart';

class MatchModel extends ScoutModel {
  static const String didntClimb = "Didn't climb";
  static const String triedClimb = "Tried to climb and didn't succeed";
  static const String climbed = "Climbed";
  static const String didntScoreTrap = "Didn't Score a note in the trap";
  static const String triedTrap =
      "Tried to score a note in the trap and didn't succeed";
  static const String scoredTrap = "Scored a note in the trap";
  static const String blueAllianceKey = "Blue";
  static const String redAllianceKey = "Red";
  static const List<String> allianceColors = [blueAllianceKey, redAllianceKey];
  static const List<String> startingPosOptions = [
    "Amp",
    "Source",
    "Subwooferׁ"
  ];
  static const List<String> climbingOptions = [didntClimb, triedClimb, climbed];
  static const List<String> trapOptions = [
    didntScoreTrap,
    triedTrap,
    scoredTrap
  ];

  static const Map<String, Color> allianceColorsMap = {
    blueAllianceKey: Colors.blue,
    redAllianceKey: Colors.red
  };
  static const Map<String, num> teleopClimbRankMap = {
    didntClimb: 0,
    triedClimb: 0,
    climbed: 3,
  };
  static const Map<String, num> teleopTrapRankMap = {
    didntScoreTrap: 0,
    triedTrap: 0,
    scoredTrap: 5,
  };

  MatchModel({required super.teamId}) : super();
  MatchModel.fromJson(super.json, {required super.teamId}) : super.fromJson();

  @override
  String get scoutTypeValue => ScoutModel.matchScoutingKey;

  bool get didRobotWork => this[StatisticsConstants.didRobotWorkKey] == true;

  num get autoPoints =>
      (this[StatisticsConstants.autoCrossedLineKey] == true ? 2 : 0) +
      ((this[StatisticsConstants.autoSpeakerNoteKey] ?? 0) * 5) +
      ((this[StatisticsConstants.autoAmpNoteKey] ?? 0) * 2);

  num get teleopPoints =>
      ((this[StatisticsConstants.teleopSpeakerNoteKey] ?? 0) * 2) +
      ((this[StatisticsConstants.teleopAmpNoteKey] ?? 0) * 1) +
      climbScore * 3 +
      trapScore * 5;

  num get totalPoints => autoPoints + teleopPoints;

  num get climbScore =>
      (MatchModel.teleopClimbRankMap[
              this[StatisticsConstants.teleopClimbedKey] ??
                  MatchModel.didntClimb] ??
          0) /
      3;

  num get trapScore =>
      (MatchModel.teleopTrapRankMap[this[StatisticsConstants.teleopTrapKey] ??
              MatchModel.didntScoreTrap] ??
          0) /
      5;
}
