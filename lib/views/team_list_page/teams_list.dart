import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/config/teams/teams_constants.dart';
import 'package:scouting_app/widgets/buttons/deny_button.dart';
import 'package:scouting_app/db/model/team.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/team_screen.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/db/repo/teams_list_repo.dart';

class TeamsList extends StatefulWidget {
  final TeamsListObject teams;

  const TeamsList({super.key, required this.teams});

  @override
  State<TeamsList> createState() => _TeamsListState();
}

class _TeamsListState extends State<TeamsList> {
  late List<Team> filteredTeams;

  @override
  void initState() {
    widget.teams.addListener(teamsListListener);
    filteredTeams = widget.teams;
    super.initState();
  }

  @override
  void dispose() {
    widget.teams.removeListener(teamsListListener);
    super.dispose();
  }

  void teamsListListener() {
    if (kDebugMode) {
      print("TeamsList setState has been called");
    }
    setState(() {});
  }

  void updateSearch(String searchQuery) {
    setState(() {
      if (searchQuery.isNotEmpty) {
        RegExp regex = RegExp(r'[a-zA-z]');
        if (regex.hasMatch(searchQuery)) {
          filteredTeams = widget.teams
              .where((team) =>
                  team.name
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
                  false)
              .toList();
        } else {
          filteredTeams = widget.teams
              .where((team) =>
                  team.id.toString().contains(searchQuery.toLowerCase()))
              .toList();
        }
      } else {
        filteredTeams = widget.teams;
      }
    });
  }

  void removeTeamDialog(Team team) {
    if (!AuthManager.isUserAllowed()) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Remove Team"),
        ),
        actions: [
          Center(
            child: DenyButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.teams.removeTeam(team);
              },
              text: "Remove Team",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.0),
        ),
      ),
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
          Expanded(
            child: ListView.builder(
              itemCount: filteredTeams.length,
              itemBuilder: (BuildContext context, int index) {
                final team = filteredTeams[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TeamScreen(team: team)),
                  ),
                  onLongPress: () => removeTeamDialog(team),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: themeData.cardColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35.0,
                          backgroundImage: team.image,
                        ),
                        const SizedBox(width: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              team.id,
                              style: const TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            Text(team.name ?? TeamConstants.defaultName),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
