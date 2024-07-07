import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/theme/theme_provider.dart';
import 'package:scouting_app/views/settings_page/admin_settings/admin_settings.dart';
import 'package:scouting_app/views/settings_page/user_settings.dart';
import 'package:scouting_app/views/settings_page/view_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 15.0,
                ),
                // AcceptButton(
                //   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchesSetup())),
                //   child: const Icon(Icons.upload),
                // ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ViewSettings()));
                      },
                      icon: const Icon(
                        Icons.settings,
                      ),
                      label: const Text(
                        "View Settings",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const UserSettings()));
                      },
                      icon: const Icon(
                        Icons.person,
                      ),
                      label: const Text(
                        "User Settings",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: AuthManager.isUserAllowed(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminSettings(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.admin_panel_settings,
                        ),
                        label: const Text(
                          "Admin Settings",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
