import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/repo/team_repo.dart';

class ScoutTextField extends StatefulWidget {
  final TeamRepo repo;
  final int index;
  final ChangeNotifier shiftNotifier;
  final StatisticsTextFieldHeader header;

  const ScoutTextField({
    super.key,
    required this.repo,
    required this.index,
    required this.shiftNotifier,
    required this.header,
  });

  @override
  State<ScoutTextField> createState() => _ScoutTextFieldState();
}

class _ScoutTextFieldState extends State<ScoutTextField> {
  TextEditingController textController = TextEditingController();
  late ui.TextDirection textDirection;
  late ScoutModel scout;

  @override
  void initState() {
    scout = widget.repo.scouts.entries.elementAt(widget.index).value;
    widget.shiftNotifier.addListener(updateValue);
    scout.lockNotifier.addListener(updateValue);

    textController.text =
        scout[widget.header.scoutValueKey] ??= widget.header.defaultValue;
    textDirection = determineTextDirection(textController.text);
    textController.addListener(updateTextDirection);
    super.initState();
  }

  @override
  void dispose() {
    widget.shiftNotifier.removeListener(updateValue);
    scout.lockNotifier.removeListener(updateValue);
    textController.removeListener(updateTextDirection);
    super.dispose();
  }

  void updateValue() {
    setState(() {
      scout = widget.repo.scouts.entries.elementAt(widget.index).value;
      textController.text =
          scout[widget.header.scoutValueKey] ??= widget.header.defaultValue;
    });
  }

  void updateTextDirection() {
    String text = textController.text;
    ui.TextDirection newDirection = determineTextDirection(text);

    // Only update if the textDirection is different
    if (newDirection != textDirection) {
      setState(() {
        textDirection = newDirection;
      });
    }
  }

  ui.TextDirection determineTextDirection(String text) {
    return Bidi.hasAnyRtl(text) ? ui.TextDirection.rtl : ui.TextDirection.ltr;
  }

  bool onPopSave(
      TextEditingController textController, bool shouldAllowBackButton) {
    if (widget.header.readOnly) return shouldAllowBackButton;

    if (textController.text != scout[widget.header.scoutValueKey]) {
      scout[widget.header.scoutValueKey] = textController.text;
    }

    return shouldAllowBackButton;
  }

  @override
  Widget build(BuildContext context) {
    scout[widget.header.scoutValueKey] ??= widget.header.defaultValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: PopScope(
          onPopInvoked: (bool shouldAllowBackButton) =>
              onPopSave(textController, shouldAllowBackButton),
          child: TextFormField(
            readOnly: widget.header.readOnly,
            enabled: !scout.locked,
            controller: textController,
            textDirection: textDirection,
            maxLines: widget.header.maxLines,
            onTapOutside: (event) {
              if (widget.header.readOnly) return;
              if (textController.text != scout[widget.header.scoutValueKey]) {
                scout[widget.header.scoutValueKey] = textController.text;
              }
            },
            decoration: InputDecoration(
              labelText: widget.header.name,
              labelStyle: const TextStyle(fontSize: 14),
              hintStyle: const TextStyle(fontSize: 14),
              border: widget.header.border,
              hintText: widget.header.hintText ?? widget.header.name,
            ),
            style: const TextStyle(fontSize: 16),
          )),
    );
  }
}
