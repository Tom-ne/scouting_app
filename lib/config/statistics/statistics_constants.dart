import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_main_section.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_section.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/widgets/dataframe_table/widget_supplier.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/pit_model.dart';

class StatisticsConstants {
  static const String password = "PASSWORD";
  static const String pitScoutingDocId = "PitScouting";
  static const String teamNameKey = 'Team Name';
  static const String pointsPerGameKey = 'Points per-Game';
  static const String autoPointsPerGameKey = 'AutoPoints per-Game';
  static const String teleopPointsPerGameKey = 'TeleopPoints per-Game';
  static const String robotWorkedGamesKey = 'Robot worked games';

  static const String createdAtKey = 'createdAt';
  static const String lastModifiedKey = 'lastModified';
  static const String scoutTypeKey = 'Scout Type';
  static const String scouterNameKey = 'Scouter Name';

  static const String allianceColorKey = "Alliance Color";
  static const String autoStartingPosKey = 'Auto Starting Position';

  static const String autoSpeakerNoteKey = 'Auto Speaker Note';
  static const String autoIntakeNotesKey = 'Auto Intake Notes';
  static const String autoIntakeMostCommonNotesKey = 'Auto Intake Most Common';
  static const String autoAmpNoteKey = 'Auto AMP Note';
  static const String autoCrossedLineKey = 'Auto Crossed Line';
  static const String autoClimbedKey = 'Auto Climbed';

  static const String teleopSpeakerNoteKey = 'Teleop Speaker Note';
  static const String teleopAmpNoteKey = 'Teleop AMP Note';
  static const String teleopNotesPerGame = 'Teleop-Notes Per-Game';
  static const String teleopClimbedKey = 'Teleop Climbed';
  static const String teleopTrapKey = 'Scored Trap Note';

  static const String defenseRateKey = 'Defense Rate';
  static const String stoppableRateKey = 'Got Defended Rate';
  static const String didRobotWorkKey = "Did Robot Work";

  static const String scouterNotesKey = 'Scouter Notes';

  static const String drivingTypeKey = 'driving';
  static const String drivingWheelsCountKey = 'numberOfWheelPerSide';
  static const String drivingWheelsTypeKey = 'Wheel Type';
  static const String drivingEngineCountPerSideKey = 'numberOfEnginePerSide';
  static const String drivingEngineTypeKey = 'engine';
  static const String drivingShifterKey = 'shifter';
  static const String ableToScoreInAMPKey = 'canPutInAmp';
  static const String ableToScoreInSpeakerKey = 'canPutInSpeaker';
  static const String canPutInTrapKey = 'canPutInTrap';
  static const String grabsFromFloorKey = 'grabsFromFloor';
  static const String grabsFromSource = 'grabsFromSource';
  static const String ableToClimbKey = 'canClimb';
  static const String favoriteShootingPositionKey =
      'Favorite Shooter Position Key';
  static const String shootingHeightKey = "shootingHeight";
  static const String robotWeightKey = "robotWeight";
  static const String ableToDoubleClimbKey = "ableToDoubleClimb";

  static const Map<String, Type> dataFrameColumnsTypes = {
    teamNameKey: String,
    pointsPerGameKey: num,
    autoPointsPerGameKey: num,
    teleopPointsPerGameKey: num,
    teleopNotesPerGame: num,
    robotWorkedGamesKey: WidgetSupplier,
    autoSpeakerNoteKey: num,
    autoIntakeNotesKey: num,
    autoIntakeMostCommonNotesKey: String,
    teleopSpeakerNoteKey: num,
    teleopAmpNoteKey: num,
    teleopClimbedKey: num,
    teleopTrapKey: num,
    defenseRateKey: num,
    stoppableRateKey: num,
  };

  static const List<String> teamStatsKeys = [
    pointsPerGameKey,
    autoPointsPerGameKey,
    teleopPointsPerGameKey,
    autoSpeakerNoteKey,
    teleopNotesPerGame,
    autoIntakeNotesKey,
    teleopSpeakerNoteKey,
    teleopAmpNoteKey,
    teleopClimbedKey,
    teleopTrapKey,
    defenseRateKey,
    stoppableRateKey,
  ];

  static StatisticsMainSection scoutProperties = StatisticsMainSection(
    name: "Statistics",
    sharedValueTop: const StatisticsTextFieldHeader(
      name: "שם הסקאוטר",
      scoutValueKey: StatisticsConstants.scouterNameKey,
      showInOverview: false,
      readOnly: true,
      border: UnderlineInputBorder(),
    ),
    matchScoutHeader: StatisticsSection(name: "Match-Scout", children: [
      StatisticsSection(
        name: "לפני המשחק",
        children: [
          StatisticsDropdownHeader(
            name: "צבע הברית",
            scoutValueKey: StatisticsConstants.allianceColorKey,
            possibleValues: MatchModel.allianceColors,
            mapFunction: (option) => Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: 10,
                  height: 10,
                  color: MatchModel.allianceColorsMap[option],
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(option),
              ],
            ),
          ),
          const StatisticsDropdownHeader(
            name: "עמדת פתיחה",
            scoutValueKey: StatisticsConstants.autoStartingPosKey,
            possibleValues: MatchModel.startingPosOptions,
          ),
        ],
      ),
      const StatisticsSection(
        name: "אוטונומי",
        children: [
          StatisticsCheckboxHeader(
            name: "חצה קו אוטונומי",
            scoutValueKey: StatisticsConstants.autoCrossedLineKey,
          ),
          StatisticsSection(
            name: "טבעות",
            children: [
              StatisticsCountHeader(
                name: "Speaker",
                scoutValueKey: StatisticsConstants.autoSpeakerNoteKey,
              ),
              StatisticsFieldHeader(
                name: "Intake During Auto",
                scoutValueKey: autoIntakeNotesKey,
                defaultValue: "",
              ),
              StatisticsCountHeader(
                name: "Middle Notes Intake During Auto",
                scoutValueKey: autoIntakeNotesKey,
                showInTemplate: false,
                defaultValue: "",
              ),
            ],
          ),
        ],
      ),
      const StatisticsSection(
        name: "טלאופ",
        children: [
          StatisticsSection(
            name: "טבעות",
            children: [
              StatisticsCountHeader(
                name: "Speaker",
                scoutValueKey: StatisticsConstants.teleopSpeakerNoteKey,
              ),
              StatisticsCountHeader(
                name: "AMP",
                scoutValueKey: StatisticsConstants.teleopAmpNoteKey,
              ),
            ],
          ),
          StatisticsSection(
            name: "טיפוס",
            children: [
              StatisticsDropdownHeader(
                name: "טיפוס",
                scoutValueKey: StatisticsConstants.teleopClimbedKey,
                possibleValues: MatchModel.climbingOptions,
              ),
              StatisticsDropdownHeader(
                name: "טבעת מלכודת",
                scoutValueKey: StatisticsConstants.teleopTrapKey,
                possibleValues: MatchModel.trapOptions,
              ),
            ],
          ),
        ],
      ),
      const StatisticsSection(
        name: "אחרי המשחק",
        children: [
          StatisticsSection(name: "הגנה", children: [
            StatisticsRateHeader(
              name: "עשה הגנה",
              scoutValueKey: StatisticsConstants.defenseRateKey,
              minValue: 0,
              maxValue: 3,
              devisions: 3,
            ),
            StatisticsRateHeader(
              name: "ספג הגנה",
              scoutValueKey: StatisticsConstants.stoppableRateKey,
              minValue: 0,
              maxValue: 3,
              devisions: 3,
            ),
            StatisticsCheckboxHeader(
              name: "האם הרובוט עבד?",
              scoutValueKey: StatisticsConstants.didRobotWorkKey,
              defaultValue: true,
            ),
          ]),
        ],
      ),
    ]),
    pitScoutHeader: const StatisticsSection(
      name: "Pit-Scout",
      showInOverview: false,
      children: [
        StatisticsSection(
          name: "הנעה",
          children: [
            StatisticsDropdownHeader(
              name: "מערכת הנעה",
              scoutValueKey: StatisticsConstants.drivingTypeKey,
              possibleValues: PitModel.driveTypes,
              singleValue: true,
            ),
            StatisticsRateHeader(
              name: "מספר מנועים בצד",
              scoutValueKey: StatisticsConstants.drivingEngineCountPerSideKey,
              minValue: 2,
              maxValue: 8,
              devisions: 6,
              singleValue: true,
            ),
            StatisticsDropdownHeader(
              name: "סוג מנועים",
              scoutValueKey: StatisticsConstants.drivingEngineTypeKey,
              possibleValues: PitModel.engineTypes,
              singleValue: true,
            ),
            StatisticsDropdownHeader(
              name: "סוג גלגל",
              scoutValueKey: StatisticsConstants.drivingWheelsTypeKey,
              possibleValues: PitModel.wheelTypes,
              singleValue: true,
            ),
            StatisticsCheckboxHeader(
              name: "שיפטר",
              scoutValueKey: StatisticsConstants.drivingShifterKey,
              singleValue: true,
            ),
          ],
        ),
        StatisticsSection(
          name: "יכולות",
          children: [
            StatisticsCheckboxHeader(
              name: "AMPיכול להכניס ל",
              scoutValueKey: StatisticsConstants.ableToScoreInAMPKey,
              singleValue: true,
            ),
            StatisticsCheckboxHeader(
              name: "SPEAKERיכול להכניס ל",
              scoutValueKey: StatisticsConstants.ableToScoreInSpeakerKey,
              singleValue: true,
            ),
            StatisticsCheckboxHeader(
              name: "TRAPיכול להכניס ל",
              scoutValueKey: StatisticsConstants.canPutInTrapKey,
              singleValue: true,
            ),
            StatisticsCheckboxHeader(
              name: "יכול לטפס",
              scoutValueKey: StatisticsConstants.ableToClimbKey,
              singleValue: true,
            ),
            StatisticsCheckboxHeader(
              name: "יכול לאסוף מהרצפה",
              scoutValueKey: StatisticsConstants.grabsFromFloorKey,
              singleValue: true,
            ),
            StatisticsCheckboxHeader(
              name: "SOURCEלאסוף מה",
              scoutValueKey: StatisticsConstants.grabsFromSource,
              singleValue: true,
            ),
            StatisticsDropdownHeader(
              name: "מיקום ירי מועדף",
              scoutValueKey: favoriteShootingPositionKey,
              possibleValues: PitModel.favoriteShootingPositions,
              singleValue: true,
            ),
            StatisticsTextFieldHeader(
              name: "גובה ירי (cm)",
              scoutValueKey: StatisticsConstants.shootingHeightKey,
            ),
            StatisticsTextFieldHeader(
              name: "משקל רובוט (kg)",
              scoutValueKey: StatisticsConstants.robotWeightKey,
            ),
            StatisticsCheckboxHeader(
              name: "יכול לטפס עם רובוט נוסף על השרשרת",
              scoutValueKey: StatisticsConstants.ableToDoubleClimbKey,
            ),
          ],
        ),
      ],
    ),
    sharedValueBottom: const StatisticsTextFieldHeader(
      name: "הערות נוספות:",
      scoutValueKey: StatisticsConstants.scouterNotesKey,
      showInOverview: false,
      maxLines: null,
    ),
  );
}
