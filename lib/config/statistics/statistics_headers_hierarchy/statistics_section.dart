import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_header.dart';

class StatisticsSection extends StatisticsHeader {
  final List<StatisticsHeader> children;

  const StatisticsSection({
    required super.name,
    super.showInOverview = true,
    required this.children,
  }) : super(showInTemplate: false);

  StatisticsSection get clearForOverview {
    List<StatisticsHeader> resultChildren = [];
    for (StatisticsHeader child in subHeaders) {
      if (child is StatisticsSection && child.showInOverview) {
        resultChildren.add(child.clearForOverview);
      } else if (child.showInOverview) {
        resultChildren.add(child);
      }
    }

    return StatisticsSection(name: name, children: resultChildren);
  }

  @override
  List<StatisticsHeader> get subHeaders => children;
}
