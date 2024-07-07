import 'package:flutter/material.dart';
import 'package:scouting_app/db/model/team.dart';

class MatchHeader extends StatelessWidget {
  final Set<Team> blueAlliance;
  final Set<Team> redAlliance;
  final Set<Team>? filteredTeams;
  final String? matchKey;

  const MatchHeader({
    super.key,
    required this.blueAlliance,
    required this.redAlliance,
    this.filteredTeams,
    required this.matchKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Row(
          children: [
            for (Team team in blueAlliance)
              Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(width: 3.0, color: Colors.blue),
                      color: Colors.blue,
                    ),
                    child: Text(
                      team.id,
                      style: (filteredTeams?.contains(team) ?? false)
                          ? const TextStyle(
                              backgroundColor: Colors.yellow,
                            )
                          : null,
                    ),
                  )),
          ],
        ),
        const Row(
          children: [
            SizedBox(width: 5),
            Text("VS", style: TextStyle(fontSize: 12)),
            SizedBox(width: 5),
          ],
        ),
        Row(
          children: [
            for (Team team in redAlliance)
              Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(width: 3.0, color: Colors.red),
                      color: Colors.red,
                    ),
                    child: Text(
                      team.id,
                      style: (filteredTeams?.contains(team) ?? false)
                          ? const TextStyle(
                              backgroundColor: Colors.yellow,
                            )
                          : null,
                    ),
                  )),
          ],
        ),
      ],
    );
  }
}
