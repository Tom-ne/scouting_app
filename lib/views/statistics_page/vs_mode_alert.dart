import 'package:flutter/material.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/views/statistics_page/vs_mode.dart';
import 'package:scouting_app/widgets/vs_mode_alert_background.dart';

class VsModeAlert extends StatefulWidget {
  static const double diagonalWidth = 80;
  static const double height = 80;
  static const double iconRadius = height / 3;
  static const Text text = Text(
    'Vs',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
  final ChangeNotifier notifier;

  const VsModeAlert({super.key, required this.notifier});

  @override
  State<VsModeAlert> createState() => _VsModeAlertState();
}

class _VsModeAlertState extends State<VsModeAlert> {
  late bool visible;

  @override
  void initState() {
    super.initState();
    visible = HomeScreen.statisticsHandler.isVsModeAvilable();
    widget.notifier.addListener(update);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(update);
    super.dispose();
  }

  void update() {
    bool newValue = HomeScreen.statisticsHandler.isVsModeAvilable();
    if (newValue != visible) {
      setState(() {
        visible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
      height: HomeScreen.statisticsHandler.isVsModeAvilable()
          ? VsModeAlert.height
          : 0.0, // Slide down or up
      child: SizedBox(
        height: VsModeAlert.height,
        child: VsModeAlertBackground(
          color1: Colors.blue,
          color2: Colors.red,
          diagonalDirection: false,
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return VsMode(
                    selectedBlueTeams:
                        HomeScreen.statisticsHandler.selectedBlueTeams,
                    selectedRedTeams:
                        HomeScreen.statisticsHandler.selectedRedTeams,
                  );
                }),
              ),
              child: const CircleAvatar(
                radius: VsModeAlert.iconRadius,
                backgroundColor: Colors.grey,
                child: VsModeAlert.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
