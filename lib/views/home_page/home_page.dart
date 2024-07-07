import 'package:flutter/material.dart';
import 'package:scouting_app/views/games_page/games_page.dart';
import 'package:scouting_app/views/statistics_page/statistics_page.dart';
import 'package:scouting_app/views/team_list_page/teams_list_page.dart';
import 'package:scouting_app/db/auth/authentication.dart';

class HomePage {
  static const List<HomePage> pages = [
    HomePage(
      icon: Icon(Icons.list),
      label: 'Teams',
      content: TeamsListPage(),
    ),
    HomePage(
      icon: Icon(Icons.content_paste),
      label: 'Statistics',
      content: StatisticsPage(),
      permissionLevel: 2,
    ),
    HomePage(
      icon: Icon(Icons.bookmark),
      label: 'Games',
      content: GamesPage(),
    ),
  ];
  final Icon icon;
  final String label;
  final Widget content;
  final int permissionLevel;

  const HomePage({
    required this.icon,
    required this.label,
    required this.content,
    this.permissionLevel = 1,
  });

  bool get permissionGranted {
    switch (permissionLevel) {
      case 0:
        return true;
      case 1:
        return AuthManager.loggedIn;
      case 2:
        return AuthManager.isUserAllowed();
      default:
        return false;
    }
  }

  BottomNavigationBarItem get bottomNavigationBarItem {
    return BottomNavigationBarItem(
      icon: icon,
      label: label,
    );
  }
}
