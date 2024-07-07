import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_header.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_section.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/scout_auto_inake_field.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/scout_checkbox_field.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/scout_count_field.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/scout_dropdown_field.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/scout_rate_field.dart';
import 'package:scouting_app/views/team_list_page/single_team_screen/components/scout_text_field.dart';
import 'package:scouting_app/db/model/scout_model.dart';

import 'package:scouting_app/db/repo/team_repo.dart';

class Template extends StatefulWidget {
  final TeamRepo repo;
  final int index;
  final ChangeNotifier shiftNotifier;

  const Template(
      {super.key,
      required this.repo,
      required this.index,
      required this.shiftNotifier});

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  late ScoutModel scout;
  List<Widget> _buildScoutWidgetTree(
      BuildContext context, List<StatisticsHeader> properties,
      {int? depth}) {
    depth ??= 0;
    List<Widget> result = [];
    for (StatisticsHeader item in properties) {
      if (item is StatisticsValueHeader) {
        if (!item.showInTemplate) {
          continue;
        }
        Widget? innerWidget; // = const Placeholder();
        if (item is StatisticsTextFieldHeader) {
          innerWidget = ScoutTextField(
              index: widget.index,
              repo: widget.repo,
              shiftNotifier: widget.shiftNotifier,
              header: item);
        } else if (item is StatisticsDropdownHeader) {
          innerWidget = ScoutDropdownField(
              index: widget.index,
              repo: widget.repo,
              shiftNotifier: widget.shiftNotifier,
              header: item);
        } else if (item is StatisticsCountHeader) {
          innerWidget = ScoutCountField(
              index: widget.index, repo: widget.repo, header: item);
        } else if (item is StatisticsCheckboxHeader) {
          innerWidget = ScoutCheckboxField(
              index: widget.index,
              repo: widget.repo,
              shiftNotifier: widget.shiftNotifier,
              header: item);
        } else if (item is StatisticsRateHeader) {
          innerWidget = ScoutRateField(
              index: widget.index,
              repo: widget.repo,
              shiftNotifier: widget.shiftNotifier,
              header: item);
        } else if (item is StatisticsFieldHeader) {
          innerWidget = ScoutAutoInakeField(
              index: widget.index,
              repo: widget.repo,
              shiftNotifier: widget.shiftNotifier,
              header: item);
        }
        if (innerWidget != null) result.add(Container(child: innerWidget));
        continue;
      }
      if (item is StatisticsSection) {
        if (depth <= 1) {
          result.add(
            Divider(
              thickness: 1,
              color: depth == 1 ? null : Colors.transparent,
            ),
          );
        }
        final theme = Theme.of(context);
        final List<Widget> widgetsList =
            _buildScoutWidgetTree(context, item.subHeaders, depth: depth + 1);
        final Set<WidgetState> states = <WidgetState>{
          if (depth % 2 == 0 && depth != 2) WidgetState.selected,
        };
        final WidgetStateProperty<Color?> defaultSectionColor =
            WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return theme.colorScheme.primary.withOpacity(0.08);
            }
            return null;
          },
        );
        final Color? resolvedSectionColor = defaultSectionColor.resolve(states);
        result.add(
          Material(
            elevation: depth == 2 ? 0 : depth * 2,
            color: resolvedSectionColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 20 - 2 * depth.toDouble(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ...widgetsList,
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        );
        result.add(
          const Divider(
            thickness: 1,
            color: Colors.transparent,
          ),
        );
        continue;
      }
      throw Exception(
          "Code should not reach here! $item is not StatisticsValueHeader nor StatisticsSection");
    }
    return result;
  }

  @override
  void initState() {
    scout = widget.repo.scouts.entries.elementAt(widget.index).value;
    widget.shiftNotifier.addListener(setIndex);
    super.initState();
  }

  @override
  void dispose() {
    widget.shiftNotifier.removeListener(setIndex);
    super.dispose();
  }

  void setIndex() {
    setState(() {
      scout = widget.repo.scouts.entries.elementAt(widget.index).value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: _buildScoutWidgetTree(context, scout.properties),
          ),
        ),
      ),
    );
  }
}
