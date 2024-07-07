import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/views/games_page/match_header.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/views/statistics_page/vs_mode.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/team.dart';
import 'package:scouting_app/db/repo/teams_list_repo.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final TeamsListObject teams = HomeScreen.teams;
  final Set<String> matchesKeys = {};
  final Map<String, Set<Team>> blueAllianceMap = {};
  final Map<String, Set<Team>> redAllianceMap = {};
  Set<Team>? filteredTeams;

  @override
  void initState() {
    _mapAllMatches();
    updateSearch("");
    for (Team team in teams) {
      team.repo.addListener(onTeamRepoUpdate);
    }
    teams.addListener(onTeamsUpdate);
    super.initState();
  }

  @override
  void dispose() {
    teams.removeListener(onTeamsUpdate);
    for (Team team in teams) {
      team.repo.removeListener(onTeamRepoUpdate);
    }
    super.dispose();
  }

  void onTeamsUpdate() {
    for (Team team in teams) {
      team.repo.removeListener(onTeamRepoUpdate);
      team.repo.addListener(onTeamRepoUpdate);
    }
  }

  void onTeamRepoUpdate() {
    _mapAllMatches();
  }

  void _mapAllMatches() {
    matchesKeys.clear();
    blueAllianceMap.clear();
    redAllianceMap.clear();
    for (Team team in teams) {
      for (String key in team.repo.matchesKeys) {
        matchesKeys.add(key);
        blueAllianceMap[key] ??= {};
        redAllianceMap[key] ??= {};
        MatchModel match = team.repo.scouts[key] as MatchModel;
        if (match[StatisticsConstants.allianceColorKey] ==
            MatchModel.blueAllianceKey) {
          blueAllianceMap[key]!.add(team);
        } else {
          redAllianceMap[key]?.add(team);
        }
      }
    }
  }

  void updateSearch(String searchQuery) {
    setState(() {
      if (searchQuery.isNotEmpty) {
        RegExp regex = RegExp(r'[a-zA-z]');
        if (regex.hasMatch(searchQuery)) {
          filteredTeams = teams
              .where((team) =>
                  team.name
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
                  false)
              .toSet();
        } else {
          filteredTeams = teams
              .where((team) =>
                  team.id.toString().contains(searchQuery.toLowerCase()))
              .toSet();
        }
      } else {
        filteredTeams = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(7),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: updateSearch,
                decoration: const InputDecoration(
                  hintText: "Enter team name or number",
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Visibility(
            visible: matchesKeys.isNotEmpty,
            replacement: const Center(
              child: Text(
                "There are not matches in the system yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            child: Expanded(
              child: ListView.builder(
                itemCount: matchesKeys.length,
                itemBuilder: (_, index) {
                  List<String> sortedKeys = matchesKeys.toList()
                    ..sort((a, b) {
                      int q1 = a[0] == 'P'
                          ? int.parse(a.split('-')[0].replaceAll('P', ''))
                          : int.parse(a.split('-')[0].replaceAll('Q', ''));
                      int q2 = b[0] == 'P'
                          ? int.parse(b.split('-')[0].replaceAll('P', ''))
                          : int.parse(b.split('-')[0].replaceAll('Q', ''));
                      return q1.compareTo(q2);
                    });
                  final String matchKey = sortedKeys.elementAt(index);
                  final Set<Team> blueAlliance =
                      blueAllianceMap[matchKey] ?? {};
                  final Set<Team> redAlliance = redAllianceMap[matchKey] ?? {};
                  return Visibility(
                    visible: filteredTeams
                            ?.intersection(blueAlliance.union(redAlliance))
                            .isNotEmpty ??
                        sortedKeys.isNotEmpty,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeData.cardColor,
                      ),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) {
                            return VsMode(
                              selectedBlueTeams: blueAlliance,
                              selectedRedTeams: redAlliance,
                              matchKey: matchKey,
                            );
                          }),
                        ),
                        titleAlignment: ListTileTitleAlignment.center,
                        title: Text(matchKey.split('-')[0]),
                        subtitle: matchKey.contains("Rematch")
                            ? const Text("Rematch")
                            : null,
                        trailing: SizedBox(
                          width: MediaQuery.of(context).size.width - 145,
                          child: MatchHeader(
                            blueAlliance: blueAlliance,
                            redAlliance: redAlliance,
                            filteredTeams: filteredTeams,
                            matchKey: matchKey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
