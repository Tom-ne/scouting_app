// ignore_for_file: camel_case_types

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:scouting_app/config/http/http_constants.dart';
import 'package:scouting_app/config/tba/tba_config.dart';
import 'package:scouting_app/utils/const_dictionary.dart';

class TBA_Event {
  final String name;
  final String key;

  const TBA_Event({required this.name, required this.key});
}

class TBA_Team extends ConstDictionary {
  @override
  Map<String, dynamic> get keysDefaultValues => {
        'address': '',
        'city': '',
        'country': '',
        'gmaps_place_id': '',
        'gmaps_url': '',
        'key': '',
        'lat': double.nan,
        'lng': double.nan,
        'location_name': '',
        'motto': '',
        'name': '',
        'nickname': '',
        'postal_code': '',
        'rookie_year': 0,
        'school_name': '',
        'state_prov': '',
        'team_number': 0,
        'website': '',
      };
}

class TBA_Manager {
  static List<Future<void> Function()> operations = [];

  static Future<http.Response> _getResponseAsync(
      Future<http.Response> Function() operation) async {
    operations.add(operation);
    while (operations.contains(operation)) {
      final operationToExecute = operations.removeAt(0);
      if (operationToExecute == operation) {
        Future.delayed(const Duration(milliseconds: 100));
        return await operation.call();
      }
    }
    throw Exception("Should have exited before");
  }

  static Future<http.Response> _getResponse(String uri) async {
    final response = await _getResponseAsync(
      () async => await http.get(
        Uri.parse(uri),
        headers: <String, String>{
          'X-TBA-Auth-Key': TBAConfig.apiKey,
        },
      ),
    );

    if (kDebugMode) {
      print("TBA --> response.statusCode: ${response.statusCode}");
    }
    return response;
  }

  static Future<List<String>> fetchTeamsFromEvent(TBA_Event event) async {
    final response = await _getResponse(
        "${TBAConfig.baseURL}/event/${event.key}/teams/keys");

    if (response.statusCode == HTTPConstants.okStatusCode) {
      List<String> teamsIdForEvent = [];
      var data = json.decode(response.body);

      for (var teamKey in data) {
        teamsIdForEvent.add(teamKey.toString().substring(3));
      }
      return teamsIdForEvent;
    } else {
      throw Exception(
          'Failed to load teams from event ${event.name}, response.statusCode: ${response.statusCode}');
    }
  }

  static Future<List<TBA_Event>> fetchEvents() async {
    DateTime now = DateTime.now();

    final response = await _getResponse(
        "${TBAConfig.baseURL}/district/${now.year}${TBAConfig.districtKey}/events");

    if (response.statusCode == HTTPConstants.okStatusCode) {
      List<TBA_Event> loadedEvents = [];

      loadedEvents.add(
        TBA_Event(
            name: "Israel off season",
            key: "${now.year}${TBAConfig.offSeasonKey}"),
      );

      List<dynamic> events = json.decode(response.body);
      for (var obj in events) {
        loadedEvents.add(TBA_Event(name: obj['name'], key: obj['key']));
      }

      return loadedEvents;
    } else {
      throw Exception(
          'Failed to load Events, response.statusCode: ${response.statusCode}');
    }
  }

  static Future<List<String>> fetchDistrictPointsRanking() async {
    DateTime now = DateTime.now();

    final response = await _getResponse(
        "${TBAConfig.baseURL}/district/${now.year}${TBAConfig.districtKey}/rankings");

    if (response.statusCode == HTTPConstants.okStatusCode) {
      var data = json.decode(response.body);
      List<String> loadedTeams = [];
      for (var obj in data) {
        loadedTeams.add(obj['team_key'].toString().substring(3));
      }
      return loadedTeams;
    } else {
      throw Exception(
          'Failed to load District Rankings, response.statusCode: ${response.statusCode}');
    }
  }

  static Future<String?> fetchTeamName(String teamKey) async {
    final response = await _getResponse("${TBAConfig.baseURL}/team/$teamKey");

    if (response.statusCode == HTTPConstants.okStatusCode) {
      final jsonDecoded = json.decode(response.body);

      String? name = jsonDecoded['name'];
      String? nickname = jsonDecoded['nickname'] ??
          name; // Use 'name' as fallback if 'nickname' is null

      // Replace spaces with dashes in the team name
      String? teamName = nickname?.replaceAll(" ", "-");

      return teamName;
    } else {
      throw Exception(
          'Failed to load team data, response.statusCode: ${response.statusCode}');
    }
  }

  static Future<String?> fetchTeamImage(String teamKey) async {
    DateTime now = DateTime.now();

    final response = await _getResponse(
        "${TBAConfig.baseURL}/team/$teamKey/media/${now.year}");

    if (response.statusCode == HTTPConstants.okStatusCode) {
      // Parse the JSON response
      List<dynamic> data = json.decode(response.body);

      // Find the entry with type 'avatar' and return its base64Image
      final avatarEntry = data.firstWhere(
        (entry) => entry['type'] == 'avatar',
        orElse: () => null,
      );

      if (avatarEntry != null &&
          avatarEntry.containsKey('details') &&
          avatarEntry['details'].containsKey('base64Image')) {
        return avatarEntry['details']['base64Image'];
      }
      // Handle errors or cases where details['base64Image'] is not available
      return null;
    } else {
      throw Exception(
          'Failed to load team data, response.statusCode: ${response.statusCode}');
    }
  }

  static Future<bool> isValidEventCode(String value) async {
    DateTime now = DateTime.now();

    final response = await _getResponse("${TBAConfig.baseURL}/events/$now");

    if (response.statusCode == HTTPConstants.okStatusCode) {
      List<dynamic> decodedJson = json.decode(response.body);

      for (var obj in decodedJson) {
        for (var division in obj["division_keys"]) {
          if (division == value) {
            return true;
          }
        }

        if (obj["event_code"] == value) {
          return true;
        }
      }
    }
    return false;
  }
}
