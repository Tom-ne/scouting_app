import 'package:flutter/material.dart';
import 'package:scouting_app/views/settings_page/admin_settings/edit_allowed_users.dart';
import 'package:scouting_app/views/settings_page/admin_settings/import_teams.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 40.0,
            ),
            AcceptButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TeamsImport())),
              text: "Load teams for event",
            ),
            const SizedBox(
              height: 5,
            ),
            AcceptButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditAllowedUsers())),
              text: "Edit allowed users",
            ),
          ],
        ),
      ),
    );
  }
}
