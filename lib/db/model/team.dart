import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/config/teams/teams_constants.dart';
import 'package:scouting_app/utils/tba_manager.dart';
import 'package:scouting_app/db/repo/team_repo.dart';
import 'package:scouting_app/db/repo/teams_list_repo.dart';

class Team with ChangeNotifier {
  final TeamsListObject parent;
  final String id;
  late final TeamRepo repo;

  String? encodedImage;
  String? name;
  Image? _image;

  ImageProvider<Object> get image =>
      (_image ?? TeamConstants.defaultImage).image;
  String get key => name ?? 'Team-$id';
  String get header => "${name ?? TeamConstants.defaultName} | $id";
  String get title => "${name ?? TeamConstants.defaultName} - $id";

  Team({
    required this.parent,
    required this.id,
    this.name,
    this.encodedImage,
  }) {
    _image =
        encodedImage != null ? Image.memory(base64Decode(encodedImage!)) : null;
    addListener(parent
        .updateTeamListener); // when team done being feched- update parent
    repo = TeamRepo(name: id, firebaseInstance: parent.firebaseInstance);
  }

  factory Team.fromJson(
      {required TeamsListObject parent, required Map<String, dynamic> json}) {
    return Team(
      parent: parent,
      id: json['id'] ?? '',
      name: json['name'],
      encodedImage: json['encoded_image'],
    );
  }

  factory Team.merged(Team loadedTeam, Team? matchingTeam) {
    if (matchingTeam == null) return loadedTeam;
    return Team(
      parent: loadedTeam.parent,
      id: loadedTeam.id,
      name: loadedTeam.name ?? matchingTeam.name,
      encodedImage: loadedTeam.encodedImage ?? matchingTeam.encodedImage,
    );
  }

  factory Team.fromTBA({required TeamsListObject parent, required String id}) {
    Team newTeam = Team(
      parent: parent,
      id: id,
    );
    newTeam._fetch();
    return newTeam;
  }

  Future<void> _fetch() async {
    bool fetched = false;
    do {
      fetched = await _fetchTeamFromTBA();
    } while (!fetched);
  }

  Future<bool> _fetchTeamFromTBA() async {
    if (id.isEmpty) return false;
    String teamKey = "frc$id";
    try {
      name ??= await TBA_Manager.fetchTeamName(teamKey);
      bool triedToFetchImage = encodedImage == null;
      encodedImage ??= await TBA_Manager.fetchTeamImage(teamKey);
      if (triedToFetchImage && encodedImage != null) {
        _image = Image.memory(base64Decode(encodedImage!));
      }
      if (kDebugMode) {
        print("fetched team info from TBA");
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("failed to load team from TBA: $e");
      }
      return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! Team) return false;
    if (runtimeType != other.runtimeType) return false;
    if (int.parse(id) != int.parse(other.id)) return false;
    if (name != other.name) return false;
    return encodedImage == other.encodedImage;
  }

  @override
  int get hashCode => Object.hash(id, name, encodedImage);

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'encoded_image': encodedImage};
  }
}
