import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';
import 'package:scouting_app/db/model/scout_model.dart';
import 'package:scouting_app/db/repo/team_repo.dart';

class ScoutCountField extends StatelessWidget {
  final TeamRepo repo;
  final int index;
  final StatisticsCountHeader header;

  const ScoutCountField({
    super.key,
    required this.repo,
    required this.index,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    ScoutModel scout = repo.scouts.entries.elementAt(index).value;
    scout[header.scoutValueKey] ??= header.defaultValue;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Container(
            width: 160,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: Colors.indigo.shade700,
                width: 2,
              ),
            ),
            child: StatefulBuilder(
              builder: (context, setState) => Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (scout.locked) return;
                      if (scout[header.scoutValueKey] > 0) {
                        setState(() => scout[header.scoutValueKey]--);
                      }
                    },
                    child: Icon(
                      Icons.remove,
                      color: Colors.indigo.shade200,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 25), // Add some spacing here
                  Text(
                    scout[header.scoutValueKey].toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 25), // Add some spacing here
                  GestureDetector(
                    onTap: () {
                      if (scout.locked) return;
                      setState(() => scout[header.scoutValueKey]++);
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.indigo.shade200,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          header.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }
}
