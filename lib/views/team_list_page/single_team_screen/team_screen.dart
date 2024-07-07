import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scouting_app/config/match/match_constants.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/template.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/tab_content.dart';
import 'package:scouting_app/widgets/overriden_flutter_widgets/custom_tab_bar.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';
import 'package:scouting_app/widgets/buttons/deny_button.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/model/team.dart';
import 'package:scouting_app/db/repo/team_repo.dart';

class TeamScreen extends StatefulWidget {
  final Team team;

  const TeamScreen({super.key, required this.team});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  final ChangeNotifier tabsIndexNotifier = ChangeNotifier();
  late final TeamRepo teamRepo = widget.team.repo;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController newMatchNameController = TextEditingController();
  late TabController _tabController;
  List<String> currentTabsNames = [];
  String _destinationTabKey = "";
  String _activeTabKey = "";

  set activeTabKey(String tabKey) {
    _activeTabKey = tabKey;
    _destinationTabKey = tabKey;
  }

  @override
  void initState() {
    teamRepo.addListener(updateByTeamRepo);
    _tabController = TabController(length: teamRepo.scouts.length, vsync: this);
    _tabController.addListener(updateTabKey);
    if (_tabController.index >= 0 && teamRepo.scouts.isNotEmpty) {
      activeTabKey = teamRepo.scouts.keys.elementAt(_tabController.index);
    }
    super.initState();
  }

  @override
  void dispose() {
    lockActiveTab();
    teamRepo.removeListener(updateByTeamRepo);
    newMatchNameController.dispose();
    _tabController.removeListener(updateTabKey);
    _tabController.dispose();
    super.dispose();
  }

  void lockActiveTab({String? tab}) {
    teamRepo.scouts[tab ?? _activeTabKey]?.locked = true;
  }

  void updateTabKey() {
    String previousTabKey = _activeTabKey;
    activeTabKey = teamRepo.scouts.keys.elementAt(_tabController.index);
    if (previousTabKey != _activeTabKey) {
      setState(() {
        lockActiveTab(tab: previousTabKey);
      });
    }
  }

  void updateByTeamRepo() {
    bool notify = false;
    if (currentTabsNames
            .any((element) => !teamRepo.scouts.keys.contains(element)) ||
        teamRepo.scouts.keys
            .any((element) => !currentTabsNames.contains(element))) {
      notify = true;
      bool hasDestination = _activeTabKey != _destinationTabKey;
      bool deletion =
          (!hasDestination) && (!teamRepo.scouts.keys.contains(_activeTabKey));
      bool replacement =
          hasDestination && (!teamRepo.scouts.keys.contains(_activeTabKey));
      int destinationIndex = 0;
      if (teamRepo.scouts.isNotEmpty) {
        if (deletion) {
          destinationIndex = max<int>(
              0, min<int>(teamRepo.scouts.length - 1, _tabController.index));
          _destinationTabKey = teamRepo.scouts.keys.elementAt(destinationIndex);
        } else if (replacement || (!hasDestination)) {
          destinationIndex =
              teamRepo.scouts.keys.toList().indexOf(_destinationTabKey);
        }
      }
      setState(() {
        _tabController.removeListener(updateTabKey);
        _tabController.dispose();
        _tabController = TabController(
            initialIndex: destinationIndex,
            length: teamRepo.scouts.length,
            vsync: this);
        _tabController.addListener(updateTabKey);
      });
    }
    int index = teamRepo.scouts.keys.toList().indexOf(_destinationTabKey);
    if (_destinationTabKey != _activeTabKey) {
      _tabController.animateTo(index);
    }
    updateTabKey();
    // activeTabKey = _destinationTabKey;
    if (notify) {
      tabsIndexNotifier.notifyListeners();
    }
  }

  void showAddMatchDialog({String? suffix, String? matchType}) {
    String newMatchName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New ${matchType ?? 'match'} id'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: newMatchNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter ${matchType ?? 'match'} id';
              }
              if (!value.toUpperCase().contains("P") &&
                  value.characters.any((e) => !RegExp(r'[0-9]').hasMatch(e))) {
                return 'Id must be a number';
              }
              int matchNumber =
                  int.tryParse(value.toUpperCase().replaceAll('P', ''))!;
              if (matchNumber < MatchConstants.minMatchNumber ||
                  matchNumber > MatchConstants.maxMatchNumber) {
                return 'Enter a valid match number!';
              }
              if (value.toUpperCase().contains("P")) {
                newMatchName = 'P$matchNumber${suffix ?? ''}';
              } else {
                newMatchName = 'Q$matchNumber${suffix ?? ''}';
              }

              if (widget.team.repo.matchesKeys.contains(newMatchName)) {
                return 'Match with that name already exists';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'New id',
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
        actions: [
          AcceptButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              newMatchNameController.clear();
              Navigator.of(context).pop();
              lockActiveTab();
              _destinationTabKey = newMatchName;
              teamRepo.addNewScouting(
                  newMatchName, ScoutModel.matchScoutingKey);
            },
            text: "Create",
          ),
        ],
      ),
    );
  }

  void showDeleteMatchDialog(BuildContext context, String matchName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Match $matchName",
          maxLines: 4,
        ),
        content: const Text("Are you sure you want to remove this match?"),
        actions: [
          DenyButton(
            text: "Delete",
            onPressed: () {
              Navigator.of(context).pop();
              lockActiveTab();
              teamRepo.removeScout(matchName);
            },
          ),
          AcceptButton(
            text: "Cancel",
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  bool isPitScouting(String scoutName) {
    return teamRepo.scouts[scoutName]?.scoutTypeValue ==
        ScoutModel.pitScoutingKey;
  }

  void showChangeMatchNameDialog(BuildContext context, String matchName) {
    if (isPitScouting(matchName)) return;
    String newMatchName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change match id'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: newMatchNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new match id';
              }
              if (value.characters.any((e) => !RegExp(r'[0-9]').hasMatch(e))) {
                return 'Match id must be a number';
              }
              int matchNumber = int.tryParse(value)!;
              if (matchNumber < MatchConstants.minMatchNumber ||
                  matchNumber > MatchConstants.maxMatchNumber) {
                return 'Enter a valid match number!';
              }
              newMatchName =
                  'Q$matchNumber${matchName.split(RegExp(r'[0-9]')).last}';
              if (widget.team.repo.matchesKeys.contains(newMatchName)) {
                return 'Match with that name already exists';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'New match id',
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
        actions: [
          AcceptButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              newMatchNameController.clear();
              Navigator.of(context).pop();
              _destinationTabKey = newMatchName;
              teamRepo.updateScoutName(matchName, newMatchName);
            },
            text: 'Change',
          ),
        ],
      ),
    );
  }

  void showDynamicTabDialog(BuildContext context, String matchName) {
    if (matchName != _activeTabKey) return;
    bool scoutLocked = (teamRepo.scouts[matchName]?.locked ?? false);
    bool availableActions = !(isPitScouting(matchName) || scoutLocked);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text("Edit: "),
            SizedBox(
              width: 150,
              child: Text(
                matchName,
                style: const TextStyle(color: Colors.blue),
                maxLines: 4,
              ),
            ),
            const Spacer(),
            Visibility(
              visible: scoutLocked,
              replacement: IconButton(
                  onPressed: () {
                    teamRepo.scouts[matchName]?.locked = true;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.lock)),
              child: IconButton(
                  onPressed: () {
                    teamRepo.scouts[matchName]?.locked = false;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.lock_open)),
            ),
          ],
        ),
        content: availableActions
            ? const Text("Please select the desired action")
            : null,
        actions: !availableActions
            ? null
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AcceptButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showChangeMatchNameDialog(context, matchName);
                      },
                      text: "Rename",
                    ),
                    DenyButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDeleteMatchDialog(context, matchName);
                      },
                      text: "Delete",
                    ),
                  ],
                ),
              ],
      ),
    );
  }

  bool anyTabLocked() {
    return teamRepo.scouts.values.any((element) => element.locked == false);
  }

  @override
  Widget build(BuildContext context) {
    currentTabsNames.clear();
    currentTabsNames.addAll(teamRepo.scouts.keys);
    bool scrollable = !anyTabLocked();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.header),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Center(
                    child: Text("Add new scout"),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AcceptButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showAddMatchDialog();
                          },
                          text: "Match",
                        ),
                        DenyButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showAddMatchDialog(
                                matchType: "rematch", suffix: "-Rematch");
                          },
                          text: "Re-match",
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: AcceptButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          lockActiveTab();
                          _destinationTabKey =
                              StatisticsConstants.pitScoutingDocId;
                          teamRepo.addNewScouting(
                              StatisticsConstants.pitScoutingDocId,
                              ScoutModel.pitScoutingKey);
                        },
                        text: "Pit-scouting",
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
          ),
        ],
        bottom: CustomTabBar(
          controller: _tabController,
          isScrollable: true,
          onLongPress: (index) {
            String matchName = teamRepo.scouts.keys.elementAt(index);
            showDynamicTabDialog(context, matchName);
          },
          indicator: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.blue, width: 3),
            ),
          ),
          tabs: [
            for (final scout in teamRepo.scouts.entries)
              Tab(
                key: GlobalKey(debugLabel: scout.key),
                child: TabScoutContent(
                  tabKey: scout.key,
                  textStyle: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  changeNotifier: scout.value.lockNotifier,
                  icon: const Icon(Icons.lock),
                  hideIcon: () => !scout.value.locked,
                  onUpdate: () {
                    bool locked = anyTabLocked();
                    if (scrollable == locked) {
                      setState(() {});
                    }
                  },
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: TabBarView(
        controller: _tabController,
        physics: scrollable ? null : const NeverScrollableScrollPhysics(),
        children: [
          for (int tabIndex = 0; tabIndex < teamRepo.scouts.length; tabIndex++)
            Template(
              index: tabIndex,
              repo: teamRepo,
              shiftNotifier: tabsIndexNotifier,
            )
        ],
      ),
    );
  }
}
