import 'package:scouting_app/db/model/scout_model.dart';

class PitModel extends ScoutModel {
  static const List<String> driveTypes = ["טנק", "סוורב", "מכאנום"];
  static const List<String> wheelTypes = [
    "קיט",
    "קולסון",
    "חיכוך",
    "אומני",
    "פנאומטי"
  ];
  static const List<String> engineTypes = [
    "Falcon",
    "Kraken",
    "Cim",
    "Mini cim",
    "Neo 550",
    "RS775"
  ];
  static const List<String> favoriteShootingPositions = [
    "Subwoofer",
    "Podium",
    "Amp"
  ];

  PitModel({required super.teamId}) : super();
  PitModel.fromJson(super.json, {required super.teamId}) : super.fromJson();

  @override
  String get scoutTypeValue => ScoutModel.pitScoutingKey;
}
