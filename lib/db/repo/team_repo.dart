import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/pit_model.dart';
import 'package:scouting_app/db/model/scout_model.dart';

class TeamRepo with ChangeNotifier {
  final FirebaseFirestore firebaseInstance;
  final String name;
  final Set<String> pitScoutsKeys = {};
  final Set<String> matchesKeys = {};
  final Map<String, ScoutModel> scouts = {};
  late final CollectionReference teamCollection =
      firebaseInstance.collection(name);

  TeamRepo({required this.name, required this.firebaseInstance}) {
    _fetchScouts();
  }

  Iterable<MatchModel> get matches =>
      matchesKeys.map((e) => scouts[e] as MatchModel);

  bool didNotChanged(Map<String, ScoutModel> loadedScouts) {
    if (scouts.length != loadedScouts.length) return false;

    for (String scoutKey in scouts.keys) {
      if (scouts[scoutKey] != loadedScouts[scoutKey]) return false;
    }

    return true;
  }

  Future<void> _fetchScouts() async {
    try {
      // TODO: change 'createdAt' to StatisticsConstants.createdAtKey
      teamCollection
          .orderBy('createdAt', descending: false)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        Map<String, ScoutModel> loadedScouts = {};
        Set<String> loadedMatchesKey = {};
        Set<String> loadedPitScoutsKeys = {};
        for (final doc in snapshot.docs) {
          final dataMap = doc.data() as Map<String, dynamic>;
          final scout = ScoutModel.loadedFromJson(dataMap, teamId: name);
          final scoutKey = doc.id;
          if (scout[StatisticsConstants.teleopClimbedKey] is String) {
            if (kDebugMode) {
              print("Team: $name, doc: $scoutKey, wrong");
            }
          }
          if (scout[StatisticsConstants.teleopTrapKey] is String) {
            if (kDebugMode) {
              print("Team: $name, doc: $scoutKey, wrong");
            }
          }
          switch (scout.scoutTypeValue) {
            case ScoutModel.matchScoutingKey:
              loadedMatchesKey.add(scoutKey);
            case ScoutModel.pitScoutingKey:
              loadedPitScoutsKeys.add(scoutKey);
            default:
              throw Exception(
                  "The name ${scout.scoutTypeValue} is not a scout-type");
          }
          if (scouts.containsKey(scoutKey) &&
              scouts[scoutKey]!.lastModified >= scout.lastModified) {
            final currentScout = scouts[scoutKey]!;
            loadedScouts[scoutKey] = currentScout;
            continue;
          }
          scout.addListener(() => updateScoutParameters(scoutKey));
          loadedScouts[scoutKey] = scout;
        }
        if (didNotChanged(loadedScouts)) return;
        if (kDebugMode) {
          print(
              "Team $name repository updated! match-names: $loadedMatchesKey}");
          print(
              "Team $name repository updated! pit-scouts-names: $loadedPitScoutsKeys}");
        }
        scouts.clear();
        matchesKeys.clear();
        pitScoutsKeys.clear();
        scouts.addAll(loadedScouts);
        matchesKeys.addAll(loadedMatchesKey);
        pitScoutsKeys.addAll(loadedPitScoutsKeys);
        sortScoutsByDocId();
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching matches: $e');
      }
    }
  }

  Future<bool> addNewScouting(String scoutKey, String scoutTypeKey) async {
    if (scouts.containsKey(scoutKey)) return false;
    String? scouterName = AuthManager.userName ?? AuthManager.userEmail;
    try {
      late ScoutModel emptyScout;
      switch (scoutTypeKey) {
        case ScoutModel.matchScoutingKey:
          {
            emptyScout = MatchModel(teamId: name);
            matchesKeys.add(scoutKey);
          }
        case ScoutModel.pitScoutingKey:
          {
            emptyScout = PitModel(teamId: name);
            pitScoutsKeys.add(scoutKey);
          }
        default:
          throw Exception("$scoutTypeKey is not a type of scout");
      }
      emptyScout.scouterName = scouterName;
      emptyScout.addListener(() => updateScoutParameters(scoutKey));
      Map<String, dynamic> emptyMatchData = emptyScout.toJson();
      scouts.addEntries({MapEntry(scoutKey, emptyScout)});
      sortScoutsByDocId();
      notifyListeners();
      await teamCollection.doc(scoutKey).set(emptyMatchData);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding new match: $e');
      }
      return false;
    }
  }

  Future<void> removeScout(String scoutKey) async {
    if (scouts.containsKey(scoutKey)) {
      try {
        scouts[scoutKey]?.lockNotifier.dispose();
        scouts[scoutKey]?.dispose();
        scouts.remove(scoutKey);
        matchesKeys.remove(scoutKey);
        pitScoutsKeys.remove(scoutKey);
        notifyListeners();
        await teamCollection.doc(scoutKey).delete();
      } catch (e) {
        if (kDebugMode) {
          print('Error removing match: $e');
        }
      }
    }
  }

  void sortScoutsByDate() {
    List<MapEntry<String, ScoutModel>> sortedScouts = scouts.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    scouts.clear();
    scouts.addEntries(sortedScouts);
  }

  void sortScoutsByDocId() {
    List<String> sortedPitScoutsKeys = pitScoutsKeys.toList()
      ..sort((a, b) {
        return a.compareTo(b);
      });
    List<String> sortedMatchScoutsKeys = matchesKeys.toList()
      ..sort((a, b) {
        int q1 = a[0] == 'P'
            ? int.parse(a.split('-')[0].replaceAll('P', ''))
            : int.parse(a.split('-')[0].replaceAll('Q', ''));
        int q2 = b[0] == 'P'
            ? int.parse(b.split('-')[0].replaceAll('P', ''))
            : int.parse(b.split('-')[0].replaceAll('Q', ''));
        if (q1 != q2) return q1.compareTo(q2);
        return a.compareTo(b);
      });
    Set<MapEntry<String, ScoutModel>> sortedScouts = {};
    for (String pitScoutKey in sortedPitScoutsKeys) {
      sortedScouts.add(MapEntry(pitScoutKey, scouts[pitScoutKey]!));
    }
    for (String matchScoutKey in sortedMatchScoutsKeys) {
      sortedScouts.add(MapEntry(matchScoutKey, scouts[matchScoutKey]!));
    }
    scouts.clear();
    scouts.addEntries(sortedScouts);
    pitScoutsKeys.clear();
    pitScoutsKeys.addAll(sortedPitScoutsKeys);
    matchesKeys.clear();
    matchesKeys.addAll(sortedMatchScoutsKeys);
  }

  Future<void> updateScoutName(String oldScoutName, String newScoutName) async {
    if (scouts.containsKey(newScoutName)) return;
    if (scouts.containsKey(oldScoutName) && oldScoutName != newScoutName) {
      try {
        final scout = scouts[oldScoutName]!;
        scouts.remove(oldScoutName);
        matchesKeys.remove(oldScoutName);
        pitScoutsKeys.remove(oldScoutName);
        await teamCollection.doc(oldScoutName).delete();
        scouts.addEntries({MapEntry(newScoutName, scout)});
        switch (scout.scoutTypeValue) {
          case ScoutModel.matchScoutingKey:
            matchesKeys.add(newScoutName);
          case ScoutModel.pitScoutingKey:
            pitScoutsKeys.add(newScoutName);
          default:
            throw Exception(
                "The name ${scout.scoutTypeValue} is not a scout-type");
        }
        // sortScoutsByDate();
        sortScoutsByDocId();
        scout.removeListener(() => updateScoutParameters(oldScoutName));
        scout.addListener(() => updateScoutParameters(newScoutName));
        notifyListeners();

        Map<String, dynamic> matchData = scout.toJson();
        await teamCollection.doc(newScoutName).set(matchData);
      } catch (e) {
        if (kDebugMode) {
          print('Error updating match name: $e');
        }
      }
    }
  }

  Future<void> deleteHistory() async {
    // Delete the collection with the team name
    await teamCollection.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> updateScoutParameters(String scoutKey) async {
    final scout = scouts[scoutKey];
    if (scout == null) return;
    notifyListeners();
    try {
      await teamCollection
          .doc(scoutKey)
          .set(scout.toJson(), SetOptions(merge: true));
      if (kDebugMode) {
        print('Parameters uploaded successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading parameters: $e');
      }
    }
  }
}
