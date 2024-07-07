import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scouting_app/utils/statistics_handler.dart';
import 'package:scouting_app/db/model/team.dart';

class TeamsListObject extends ListBase<Team> with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Team> teams = [];
  late final StatisticsHandler statisticsHandler;
  late final DocumentReference docRef =
      firebaseInstance.collection('config').doc('team_info');

  TeamsListObject() {
    statisticsHandler = StatisticsHandler(teams: this);
    _fetchTeams();
  }

  FirebaseFirestore get firebaseInstance => _firestore;

  @override
  set length(int newLength) {
    teams.length = newLength;
  }

  @override
  int get length => teams.length;

  @override
  Team operator [](int index) => teams[index];

  @override
  void operator []=(int index, Team value) {
    teams[index] = value;
  }

  Iterable<String> get headers => teams.map((team) => team.header);

  @override
  bool operator ==(Object other) {
    if (other is! List<Team>) return false;
    if (teams.length != other.length) return false;
    for (Team team in other) {
      if (teams.contains(team)) continue;
      return false;
    }
    return true;
  }

  @override
  int get hashCode => teams.hashCode;

  Team? getTeamWithId(String teamId) {
    for (Team team in teams) {
      if (team.id == teamId) {
        return team;
      }
    }
    return null;
  }

  Future<bool> _fetchTeams() async {
    try {
      // Get the document snapshots and listen for changes
      docRef.snapshots().listen((docSnapshot) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          Map<String, dynamic> data =
              docSnapshot.data() as Map<String, dynamic>;

          if (data.containsKey('teams')) {
            if (kDebugMode) {
              print("-------------------------");
              print("sync firebase:");
            }
            List<dynamic> teamDataList = data['teams'];
            bool mergedSomeTeam = false;
            List<Team> loadedTeams = [];
            for (var teamData in teamDataList) {
              final loadedTeam = Team.fromJson(
                  parent: this, json: teamData as Map<String, dynamic>);
              final matchingTeam = getTeamWithId(loadedTeam.id);
              mergedSomeTeam |= matchingTeam == loadedTeam;
              loadedTeams.add(Team.merged(loadedTeam, matchingTeam));
            }
            if (this != loadedTeams) {
              teams.clear();
              teams.addAll(loadedTeams);
              if (mergedSomeTeam) {
                updateTeamInfoDocument();
              }
              // Notify listeners about the changes
              notifyListeners();
            }
          }
        }
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error loading teams: $e");
      }
      return false;
    }
  }

  Future<bool> clearTeams() async {
    for (Team team in teams) {
      team.dispose();
    }
    teams.clear();

    return await updateWidgetsAndFirestore("TeamsList cleared Successfully.");
  }

  Future<bool> removeAllTeams(List<Team> teamsToRemove) async {
    List<String> teamsRemoved = [];
    for (Team team in teamsToRemove) {
      team.dispose();
      teams.remove(team);
      teamsRemoved.add(team.id);
    }

    return await updateWidgetsAndFirestore(
        "Teams removed Successfully: ${teamsRemoved.toString()}");
  }

  Future<bool> removeTeam(Team team) async {
    if (kDebugMode) {
      print("-------------------------------------");
      print("removeTeam function:");
    }
    team.dispose();
    // team.deleteHistory();
    teams.remove(team);
    return await updateWidgetsAndFirestore(
        'Team ${team.id} removed successfully.');
  }

  Future<bool> addAllTeams(Iterable<String> teamsId) async {
    if (kDebugMode) {
      print("-------------------------------------");
      print("addAllTeams function:");
    }
    for (String newTeamId in teamsId) {
      teams.removeWhere((team) {
        bool result = team.id == newTeamId;
        if (kDebugMode) {
          print("Team $newTeamId already existed is list");
        }
        return result;
      });
      Team newTeam = Team.fromTBA(parent: this, id: newTeamId);
      teams.add(newTeam);
    }
    teams.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    return await updateWidgetsAndFirestore(
        'Added successfully Teams: ${teamsId.join(", ")}.');
  }

  Future<bool> addTeamToList(String newTeamId) async {
    if (kDebugMode) {
      print("-------------------------------------");
      print("addTeam function:");
    }
    if (getTeamWithId(newTeamId) != null) {
      if (kDebugMode) {
        print("Team already exists is list");
      }
      return false;
    }
    teams.add(Team.fromTBA(parent: this, id: newTeamId));
    teams.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    return await updateWidgetsAndFirestore('Team Added successfully.');
  }

  void updateTeamListener() {
    updateWidgetsAndFirestore("Team Has been listened Successfully.");
  }

  Future<bool> updateTeamInfoDocument() async {
    try {
      // Serialize the list of teams
      List<Map<String, dynamic>> teamDataList =
          teams.map((team) => team.toJson()).toList();

      // Update the "teams" field in the document with the new team data
      await docRef.set({'teams': teamDataList});

      if (kDebugMode) {
        print('Firestore document successfully updated.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Firestore document: $e');
      }
      return false;
    }
  }

  Future<bool> updateWidgetsAndFirestore(String successMessage) async {
    notifyListeners();
    if (kDebugMode) {
      print("Notified by updateWidgetsAndFirestore function");
    }

    bool success = await updateTeamInfoDocument();
    if (success) {
      if (kDebugMode) {
        print(successMessage);
      }
    }
    return success;
  }
}
