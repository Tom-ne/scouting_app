import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/match_model.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/repo/team_repo.dart';
import 'package:scouting_app/widgets/dataframe_table/reactive_checkbox_supplier.dart';
import 'package:scouting_app/widgets/half_field.dart';

class ScoutAutoInakeField extends StatefulWidget {
  final TeamRepo repo;
  final int index;
  final ChangeNotifier shiftNotifier;
  final StatisticsFieldHeader header;

  const ScoutAutoInakeField({
    super.key,
    required this.repo,
    required this.index,
    required this.shiftNotifier,
    required this.header,
  });

  @override
  State<ScoutAutoInakeField> createState() => _ScoutAutoInakeFieldState();
}

class _ScoutAutoInakeFieldState extends State<ScoutAutoInakeField> {
  late ScoutModel scout;
  late CheckBoxSupplier close1;
  late CheckBoxSupplier close2;
  late CheckBoxSupplier close3;
  late CheckBoxSupplier far1;
  late CheckBoxSupplier far2;
  late CheckBoxSupplier far3;
  late CheckBoxSupplier far4;
  late CheckBoxSupplier far5;

  bool isIntakeNote(String noteKey) {
    String intakeNote = scout[widget.header.scoutValueKey] ?? "";
    return intakeNote.contains(noteKey);
  }

  void initCheckboxes() {
    close1 =
        CheckBoxSupplier(checked: isIntakeNote("c1"), enabled: !scout.locked);
    close2 =
        CheckBoxSupplier(checked: isIntakeNote("c2"), enabled: !scout.locked);
    close3 =
        CheckBoxSupplier(checked: isIntakeNote("c3"), enabled: !scout.locked);
    far1 =
        CheckBoxSupplier(checked: isIntakeNote("f1"), enabled: !scout.locked);
    far2 =
        CheckBoxSupplier(checked: isIntakeNote("f2"), enabled: !scout.locked);
    far3 =
        CheckBoxSupplier(checked: isIntakeNote("f3"), enabled: !scout.locked);
    far4 =
        CheckBoxSupplier(checked: isIntakeNote("f4"), enabled: !scout.locked);
    far5 =
        CheckBoxSupplier(checked: isIntakeNote("f5"), enabled: !scout.locked);
  }

  @override
  void initState() {
    scout = widget.repo.scouts.entries.elementAt(widget.index).value;
    initCheckboxes();
    widget.shiftNotifier.addListener(updateValue);
    scout.lockNotifier.addListener(updateValue);
    close1.addListener(() => updateCheckNote("c1", close1.isChecked));
    close2.addListener(() => updateCheckNote("c2", close2.isChecked));
    close3.addListener(() => updateCheckNote("c3", close3.isChecked));
    far1.addListener(() => updateCheckNote("f1", far1.isChecked));
    far2.addListener(() => updateCheckNote("f2", far2.isChecked));
    far3.addListener(() => updateCheckNote("f3", far3.isChecked));
    far4.addListener(() => updateCheckNote("f4", far4.isChecked));
    far5.addListener(() => updateCheckNote("f5", far5.isChecked));
    super.initState();
  }

  @override
  void dispose() {
    widget.shiftNotifier.removeListener(updateValue);
    scout.lockNotifier.removeListener(updateValue);
    close1
        .dispose(); // removeListener(() => updateCheckNote("c1", close1.isChecked));
    close2
        .dispose(); // removeListener(() => updateCheckNote("c2", close2.isChecked));
    close3
        .dispose(); // removeListener(() => updateCheckNote("c3", close3.isChecked));
    far1.dispose(); // removeListener(() => updateCheckNote("f1", far1.isChecked));
    far2.dispose(); // removeListener(() => updateCheckNote("f2", far2.isChecked));
    far3.dispose(); // removeListener(() => updateCheckNote("f3", far3.isChecked));
    far4.dispose(); // removeListener(() => updateCheckNote("f4", far4.isChecked));
    far5.dispose(); // removeListener(() => updateCheckNote("f5", far5.isChecked));
    super.dispose();
  }

  void updateValue() {
    setState(() {
      scout = widget.repo.scouts.entries.elementAt(widget.index).value;
      initCheckboxes();
      scout.notifyColor();
    });
  }

  void updateCheckNote(String noteKey, bool isChecked) {
    String previousValue = scout[widget.header.scoutValueKey] ?? "";
    previousValue = previousValue.replaceAll(noteKey, "");
    if (isChecked) {
      previousValue = previousValue + noteKey;
    }
    scout[widget.header.scoutValueKey] = previousValue;
  }

  @override
  Widget build(BuildContext context) {
    scout[widget.header.scoutValueKey] ??= widget.header.defaultValue;
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    double width = screenWidth * 0.85; // min(screenWidth, screenHeight * 4/3);
    double height = width * 7 / 8;
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Center(
          child: HalfField(
            enabled: !scout.locked,
            close1: close1,
            close2: close2,
            close3: close3,
            far1: far1,
            far2: far2,
            far3: far3,
            far4: far4,
            far5: far5,
            update: scout.allianceColorNotifier,
            colorBlue: () =>
                scout[StatisticsConstants.allianceColorKey] ==
                MatchModel.blueAllianceKey,
            width: width,
            height: height,
          ),
        )
      ],
    );
  }
}
