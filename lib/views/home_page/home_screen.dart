import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scouting_app/config/match/match_constants.dart';
import 'package:scouting_app/views/home_bottom_navigation.dart';
import 'package:scouting_app/views/home_page/drawer_side_bar.dart';
import 'package:scouting_app/views/home_page/home_page.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/utils/statistics_handler.dart';
import 'package:scouting_app/db/repo/teams_list_repo.dart';

class HomeScreen extends StatefulWidget {
  static final TeamsListObject teams = TeamsListObject();
  static StatisticsHandler get statisticsHandler => teams.statisticsHandler;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static int currentPageIndex = 0;
  late final PageController _pageController;

  List<HomePage> get _pages =>
      HomePage.pages.where((page) => page.permissionGranted).toList();

  set _index(int newValue) =>
      currentPageIndex = min(newValue, _pages.length - 1);
  int get _index => min(currentPageIndex, _pages.length - 1);

  bool? hadAccess;

  void checkLoginStatus() {
    if (!AuthManager.loggedIn) {
      Navigator.restorablePushReplacementNamed(context, "/login");
    }
    if (hadAccess != AuthManager.isUserAllowed()) {
      setState(() {
        hadAccess = AuthManager.isUserAllowed();
      });
    }
  }

  @override
  void initState() {
    checkLoginStatus();
    AuthManager.currentUserNotifier.addListener(checkLoginStatus);
    AuthManager.allowedUsersNotifier.addListener(checkLoginStatus);
    _pageController = PageController(initialPage: _index);
    super.initState();
  }

  @override
  void dispose() {
    AuthManager.currentUserNotifier.removeListener(checkLoginStatus);
    AuthManager.allowedUsersNotifier.removeListener(checkLoginStatus);
    _pageController.dispose();
    super.dispose();
  }

  void setIndex(int index) {
    _index = index;
  }

  void onItemTapped(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    precacheImage(MatchConstants.fieldImage, context);
    precacheImage(MatchConstants.fieldImage, context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.primaryColor,
        title: const Text(
          'Poro Scouting',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: setIndex,
        children: [
          for (HomePage page in _pages) page.content,
        ],
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        items: [
          for (HomePage page in _pages) page.bottomNavigationBarItem,
        ],
        pageController: _pageController,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        selectedItemColor: Colors.blue,
        onTap: onItemTapped,
      ),
      drawer: const SideBar(),
    );
  }
}
