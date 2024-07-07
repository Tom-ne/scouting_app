import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/widgets/dataframe_table/reactive_checkbox_supplier.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/team.dart';
import 'package:scouting_app/utils/team_stats.dart';

class VsMode extends StatefulWidget {
  final Set<Team> selectedBlueTeams;
  final Set<Team> selectedRedTeams;
  final String? matchKey;

  const VsMode({
    super.key,
    required this.selectedBlueTeams,
    required this.selectedRedTeams,
    this.matchKey,
  });

  @override
  State<VsMode> createState() => _VsModeState();
}

class _VsModeState extends State<VsMode> {
  late TeamStats blueAlliance;
  late TeamStats redAlliance;

  int _tabIconIndexSelected = 0;

  TextStyle titleTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  TextStyle subtitleTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  void initState() {
    initAlliancesStats();
    for (Team team in widget.selectedBlueTeams.union(widget.selectedRedTeams)) {
      team.repo.addListener(updateStats);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (Team team in widget.selectedBlueTeams.union(widget.selectedRedTeams)) {
      team.repo.removeListener(updateStats);
    }
    super.dispose();
  }

  void initAlliancesStats() {
    blueAlliance = TeamStats.fromCombination(
      widget.selectedBlueTeams.map((team) {
        if (widget.matchKey != null) {
          return TeamStats.fromHistory(
              {team.repo.scouts[widget.matchKey] as MatchModel});
        }
        Iterable<MatchModel> history = team.repo.matches;
        bool? checked = (HomeScreen.statisticsHandler.df.rows.firstWhere(
          (element) => element[StatisticsConstants.teamNameKey] == team.title,
          orElse: () => <String, Object>{},
        )[StatisticsConstants.robotWorkedGamesKey] as CheckBoxSupplier?)
            ?.isChecked;
        if (checked == true) {
          history = history.where((element) => element.didRobotWork);
        }
        return TeamStats.fromHistory(history,
            compareType: CompareType.values[_tabIconIndexSelected]);
      }),
    );
    redAlliance = TeamStats.fromCombination(
      widget.selectedRedTeams.map((team) {
        if (widget.matchKey != null) {
          return TeamStats.fromHistory(
              {team.repo.scouts[widget.matchKey] as MatchModel});
        }
        Iterable<MatchModel> history = team.repo.matches;
        bool? checked = (HomeScreen.statisticsHandler.df.rows.firstWhere(
          (element) => element[StatisticsConstants.teamNameKey] == team.title,
          orElse: () => <String, Object>{},
        )[StatisticsConstants.robotWorkedGamesKey] as CheckBoxSupplier?)
            ?.isChecked;
        if (checked == true) {
          history = history.where((element) => element.didRobotWork);
        }
        return TeamStats.fromHistory(history,
            compareType: CompareType.values[_tabIconIndexSelected]);
      }),
    );
  }

  void updateStats() {
    setState(initAlliancesStats);
  }

  double getPercent(String key) {
    num blueValue = blueAlliance[key] ?? 0;
    num redValue = redAlliance[key] ?? 0;

    if (redValue + blueValue == 0.0) {
      return 2.0;
    } else {
      return blueValue / (1.0 * (blueValue + redValue));
    }
  }

  List<Widget> createDataSegmentFixed(String statKey,
      {String? segmentTitle, bool isTitle = false}) {
    num blueValue = (blueAlliance[statKey] ?? 0) as num;
    num redValue = (redAlliance[statKey] ?? 0) as num;
    return [
      Center(
        child: Text(
          segmentTitle ?? statKey,
          style: isTitle ? titleTextStyle : subtitleTextStyle,
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              blueValue.toStringAsFixed(1),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, isTitle ? 25 : 15),
              painter: MyRectanglePainter(getPercent(statKey)),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              redValue.toStringAsFixed(1),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 5,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VsMode"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Blue alliance:\n${widget.selectedBlueTeams.map((team) => team.key).join(', ')}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.red,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Red alliance:\n${widget.selectedRedTeams.map((team) => team.key).join(', ')}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: widget.matchKey == null,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  FlutterToggleTab(
                    width: 90,
                    borderRadius: 15,
                    selectedIndex: _tabIconIndexSelected,
                    labels: CompareType.values
                        .map((e) => e.name.toUpperCase())
                        .toList(),
                    // icons: const [],
                    selectedLabelIndex: (index) {
                      if (_tabIconIndexSelected == index) return;
                      _tabIconIndexSelected = index;
                      updateStats();
                    },
                    marginSelected:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                ],
              ),
            ),
            const Divider(),
            ...createDataSegmentFixed(StatisticsConstants.pointsPerGameKey,
                isTitle: true),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: createDataSegmentFixed(
                        StatisticsConstants.autoPointsPerGameKey,
                        segmentTitle: "Auto-Points",
                        isTitle: true),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: createDataSegmentFixed(
                        StatisticsConstants.teleopPointsPerGameKey,
                        segmentTitle: "Teleop-Points",
                        isTitle: true),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      'Autonomous data',
                      style: titleTextStyle,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "Notes",
                                style: titleTextStyle,
                              ),
                            ),
                            ...createDataSegmentFixed(
                                StatisticsConstants.autoSpeakerNoteKey,
                                segmentTitle: "Speaker Notes"),
                            ...createDataSegmentFixed(
                                StatisticsConstants.autoAmpNoteKey,
                                segmentTitle: "AMP Notes"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Teleop data",
                      style: titleTextStyle,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "Notes",
                                style: titleTextStyle,
                              ),
                            ),
                            ...createDataSegmentFixed(
                                StatisticsConstants.teleopSpeakerNoteKey,
                                segmentTitle: "Speaker Notes"),
                            ...createDataSegmentFixed(
                                StatisticsConstants.teleopAmpNoteKey,
                                segmentTitle: "AMP Notes"),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "Climb",
                                style: titleTextStyle,
                              ),
                            ),
                            ...createDataSegmentFixed(
                                StatisticsConstants.teleopClimbedKey,
                                segmentTitle: "Climb"),
                            ...createDataSegmentFixed(
                                StatisticsConstants.teleopTrapKey,
                                segmentTitle: "Trap"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyRectanglePainter extends CustomPainter {
  final double blueTeamPercent;

  MyRectanglePainter(this.blueTeamPercent);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (blueTeamPercent != 2.0) {
      double blueWidth = (size.width * blueTeamPercent);

      paint.color = Colors.blue;
      final blueRect =
          Rect.fromPoints(const Offset(0, 0), Offset(blueWidth, size.height));
      canvas.drawRect(blueRect, paint);

      paint.color = Colors.red;
      final redRect = Rect.fromPoints(
          Offset(blueWidth, 0), Offset(size.width, size.height));
      canvas.drawRect(redRect, paint);

      paint.color = Colors.black;
      final middleRect = Rect.fromPoints(Offset((size.width - 1) / 2, 0),
          Offset((size.width + 1) / 2 + 1, size.height));
      canvas.drawRect(middleRect, paint);
    } else {
      paint.color = Colors.grey.shade600;
      final blankRect =
          Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
      canvas.drawRect(blankRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
