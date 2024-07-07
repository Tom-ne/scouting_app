import 'package:flutter/material.dart';
import 'package:scouting_app/views/about_page/about_page.dart';
import 'package:scouting_app/views/settings_page/settings_page.dart';
import 'package:scouting_app/db/auth/authentication.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(5),
        children: <Widget>[
          const DrawerHeader(
            child: Center(
              child: Text(
                "Options",
                style: TextStyle(fontSize: 25), //amit ben yosef
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AboutPage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              AuthManager.logout();
              Navigator.restorablePushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
