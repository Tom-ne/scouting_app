import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/config/match/match_constants.dart';
import 'package:scouting_app/theme/theme_provider.dart';
import 'package:scouting_app/utils/preferences.dart';
import 'package:scouting_app/widgets/dataframe_table/reactive_checkbox_supplier.dart';
import 'package:scouting_app/widgets/flippable_image.dart';

class ViewSettings extends StatefulWidget {
  const ViewSettings({super.key});

  @override
  State<ViewSettings> createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {
  late CheckBoxSupplier flipHorizontal = CheckBoxSupplier();
  late CheckBoxSupplier flipVertical = CheckBoxSupplier();
  @override
  void initState() {
    super.initState();
    initCheckboxes();
    flipHorizontal.addListener(() => UserPreferences.set(
        UserPreferences.flipFieldHorizontaly, flipHorizontal.isChecked));
    flipVertical.addListener(() => UserPreferences.set(
        UserPreferences.flipFieldVerticaly, flipVertical.isChecked));
    UserPreferences.preferencesNotifier.addListener(update);
  }

  void initCheckboxes() {
    flipHorizontal.isChecked =
        UserPreferences.instantGet(UserPreferences.flipFieldHorizontaly)
            as bool;
    flipVertical.isChecked =
        UserPreferences.instantGet(UserPreferences.flipFieldVerticaly) as bool;
  }

  void update() {
    setState(() {
      
    });
  }

  @override
  void dispose() {
    flipHorizontal.removeListener(() => UserPreferences.set(
        UserPreferences.flipFieldHorizontaly, flipHorizontal.isChecked));
    flipVertical.removeListener(() => UserPreferences.set(
        UserPreferences.flipFieldVerticaly, flipVertical.isChecked));
    UserPreferences.preferencesNotifier.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fieldWidth = min<double>(screenWidth * 0.8, screenHeight * 0.6);
    double fieldHeight = fieldWidth / 2;

    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Field Orientation",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Stack(
              children: [
                Container(
                  color: Colors.black87,
                  child: FlippableWidget(
                    invertHorizontally: flipHorizontal.isChecked,
                    invertVertically: flipVertical.isChecked,
                    child: Image(
                      image: MatchConstants.fieldImage,
                      width: fieldWidth,
                      height: fieldHeight,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/Buttons/FlipButtonHorizontal.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: 30,
                        height: 30,
                        child: flipHorizontal.clearWidget,
                      ),
                      SizedBox(width: fieldWidth - (2 * 30)),
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/Buttons/FlipButtonVertical.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: 30,
                        height: 30,
                        child: flipVertical.clearWidget,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Toggle Theme-Mode",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 40.0,
                ),
                FloatingActionButton(
                  heroTag: "ToggleThemeMode",
                  onPressed: () => themeProvider.toggleMode(),
                  tooltip: 'Change theme',
                  foregroundColor: Colors.white,
                  child: themeProvider.icon,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
