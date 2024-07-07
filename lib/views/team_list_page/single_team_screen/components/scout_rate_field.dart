import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/repo/team_repo.dart';

class ScoutRateField extends StatefulWidget {
  final TeamRepo repo;
  final int index;
  final ChangeNotifier shiftNotifier;
  final StatisticsRateHeader header;

  const ScoutRateField({
    super.key,
    required this.repo,
    required this.index,
    required this.shiftNotifier,
    required this.header,
  });

  @override
  State<ScoutRateField> createState() => _ScoutRateFieldState();
}

class _ScoutRateFieldState extends State<ScoutRateField> {
  late ScoutModel scout;

  @override
  void initState() {
    scout = widget.repo.scouts.entries.elementAt(widget.index).value;
    widget.shiftNotifier.addListener(updateValue);
    scout.lockNotifier.addListener(updateValue);
    super.initState();
  }

  @override
  void dispose() {
    widget.shiftNotifier.removeListener(updateValue);
    scout.lockNotifier.removeListener(updateValue);
    super.dispose();
  }

  void updateValue() {
    setState(() {
      scout = widget.repo.scouts.entries.elementAt(widget.index).value;
    });
  }

  @override
  Widget build(BuildContext context) {
    scout[widget.header.scoutValueKey] ??= widget.header.defaultValue;
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: max<double>(
                min<double>(widget.header.maxValue,
                    (scout[widget.header.scoutValueKey] as int).toDouble()),
                widget.header.minValue),
            min: widget.header.minValue,
            max: widget.header.maxValue,
            divisions: widget
                .header.devisions, // Number of divisions between min and max
            label:
                '${scout[widget.header.scoutValueKey]}', // Display the current value as a label
            onChanged: scout.locked
                ? null
                : (value) {
                    setState(() {
                      scout[widget.header.scoutValueKey] = value.round();
                    });
                  },
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(":${widget.header.name}"),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
