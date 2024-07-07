import 'package:flutter/material.dart';
import 'package:scouting_app/config/teams/teams_constants.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/views/team_list_page/teams_list.dart';

class TeamsListPage extends StatelessWidget {
  const TeamsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final teamNumberIdController = TextEditingController();

    return Scaffold(
      body: TeamsList(
        teams: HomeScreen.teams,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add Team'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: teamNumberIdController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter team id';
                    }
                    if (value.characters
                        .any((e) => !RegExp(r'[0-9]').hasMatch(e))) {
                      return 'Team id must be a number';
                    }
                    int teamNum = int.tryParse(value)!;
                    if (teamNum < TeamConstants.minTeamNumber ||
                        teamNum > TeamConstants.maxTeamNumber) {
                      return 'Team number must be between ${TeamConstants.minTeamNumber} and ${TeamConstants.maxTeamNumber}';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Team id',
                    focusColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    HomeScreen.teams.addTeamToList(teamNumberIdController.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
        tooltip: 'Add Team', // Add a tooltip for the button
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
