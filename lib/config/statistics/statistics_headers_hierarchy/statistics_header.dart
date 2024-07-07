import 'dart:math';

import 'package:scouting_app/config/statistics/statistics_headers_hierarchy/statistics_value_header.dart';

abstract class StatisticsHeader {
  final String name;
  final bool showInTemplate;
  final bool showInOverview;
  
  const StatisticsHeader({required this.name, required this.showInOverview, required this.showInTemplate});

  List<StatisticsHeader> get subHeaders => const [];

  int get depth {
    if (subHeaders.isEmpty) return 1;
    return 1 + subHeaders.fold(1, (previousValue, header) => max(previousValue, header.depth));
  }

  int get maxDepth {
    if (subHeaders.isEmpty) return 1;
    return 1 + subHeaders.fold(1, (previousValue, header) => max(previousValue, header.maxDepth));
  }
  
  int get collectiveLength {
    if (maxDepth <= 1) return 1;
    return subHeaders.fold(0, (previousValue, element) => previousValue + element.collectiveLength);
  }

  int get reducedCollectiveLength {
    if (depth <= 1) return 1;
    return subHeaders.fold(0, (previousValue, element) => previousValue + element.reducedCollectiveLength);
  }

  List<StatisticsHeader> get bottomHeaders {
    if (maxDepth <= 1) return [this];
    List<StatisticsHeader> result = [];
    for (StatisticsHeader header in subHeaders) {
      if (header.maxDepth <= 1) {
        result.add(header);
      } else {
        for (StatisticsHeader subHeader in header.subHeaders) {
          result.addAll(subHeader.bottomHeaders);
        }
      }
    }
    return result;
  }

  List<StatisticsHeader> get reducedBottomHeaders {
    if (depth <= 1) return [this];
    List<StatisticsHeader> result = [];
    for (StatisticsHeader header in subHeaders) {
      if (header.depth <= 1) {
        result.add(header);
      } else {
        for (StatisticsHeader subHeader in header.subHeaders) {
          result.addAll(subHeader.reducedBottomHeaders);
        }
      }
    }
    return result;
  }

  Map<String, dynamic> get reducedBottomDefaults {
    if (depth <= 1) {
      if (this is StatisticsValueHeader) {
        return {(this as StatisticsValueHeader).scoutValueKey: (this as StatisticsValueHeader).defaultValue};
      }
      return {};
    }
    Map<String, dynamic> result = {};
    for (StatisticsHeader header in subHeaders) {
      result.addAll(header.reducedBottomDefaults);
    }
    return result;
  }

  static String get sepertor => "/";

  static String keyFromParentName(String parentName, String childName) {
    return "$parentName$sepertor$childName";
  }

  static int getMaxDepth(List<StatisticsHeader> properties) {
    if (properties.isEmpty) return 0;
    int totalMaxDepth = 1;
    for (final section in properties) {
      totalMaxDepth = max(totalMaxDepth, section.maxDepth);
    }
    return totalMaxDepth;
  }

  static int getDepth(List<StatisticsHeader> properties) {
    if (properties.isEmpty) return 0;
    int totalDepth = 1;
    for (final section in properties) {
      totalDepth = max(totalDepth, section.depth);
    }
    return totalDepth;
  }
}