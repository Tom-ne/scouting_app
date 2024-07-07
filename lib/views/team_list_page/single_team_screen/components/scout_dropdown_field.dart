import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/repo/team_repo.dart';

class ScoutDropdownField extends StatefulWidget {
  final TeamRepo repo;
  final int index;
  final ChangeNotifier shiftNotifier;
  final StatisticsDropdownHeader header;

  const ScoutDropdownField({
    super.key,
    required this.repo,
    required this.index,
    required this.shiftNotifier,
    required this.header,
  });

  @override
  State<ScoutDropdownField> createState() => _ScoutDropdownFieldState();
}

class _ScoutDropdownFieldState extends State<ScoutDropdownField> {
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
    if (!widget.header.possibleValues
        .contains(scout[widget.header.scoutValueKey])) {
      scout[widget.header.scoutValueKey] = widget.header.defaultValue;
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: scout[widget.header.scoutValueKey].toString(),
              items: widget.header.possibleValues.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child:
                      widget.header.mapFunction?.call(option) ?? Text(option),
                );
              }).toList(),
              onChanged: scout.locked
                  ? null
                  : (String? newValue) {
                      if (newValue == null) return;
                      scout[widget.header.scoutValueKey] = newValue;
                    },
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(":${widget.header.name}"),
        ],
      ),
    );
  }
}
