import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/repo/team_repo.dart';

class ScoutCheckboxField extends StatefulWidget {
  final TeamRepo repo;
  final int index;
  final ChangeNotifier shiftNotifier;
  final StatisticsCheckboxHeader header;

  const ScoutCheckboxField({
    super.key,
    required this.repo,
    required this.index,
    required this.shiftNotifier,
    required this.header,
  });

  @override
  State<ScoutCheckboxField> createState() => _ScoutCheckboxFieldState();
}

class _ScoutCheckboxFieldState extends State<ScoutCheckboxField> {
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
    return CheckboxListTile.adaptive(
      title: Text(widget.header.name),
      value: widget.header.parseToHeader(scout[widget.header.scoutValueKey]),
      enabled: !scout.locked,
      onChanged: (newValue) {
        if (newValue == null) return;
        setState(() {
          scout[widget.header.scoutValueKey] =
              widget.header.parseValue(newValue) as bool;
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Theme.of(context).canvasColor,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
