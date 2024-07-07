import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/config/statistics/statistics_constants.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/views/statistics_page/vs_mode_alert.dart';
import 'package:scouting_app/widgets/dataframe_table/dataframe_table.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/utils/files_handler.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    HomeScreen.statisticsHandler.addListener(update);
  }

  @override
  void dispose() {
    HomeScreen.statisticsHandler.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {
      isLoading = HomeScreen.statisticsHandler.isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthManager.isUserAllowed()) {
      return const NotAllowedPage();
    }
    ThemeData themeData = Theme.of(context);
    return Stack(
      children: [
        Scaffold(
          body: DataFrameTable(
            dataFrame: HomeScreen.statisticsHandler.df,
            fixedFirstRowHeight: 70.0,
            fixedDataCellWidth: 100,
            checkboxHorizontalMargin: 50,
            headingRowColor:
                WidgetStatePropertyAll(themeData.secondaryHeaderColor),
            onDataSort: HomeScreen.statisticsHandler.sortDataByColumnAsync,
            isSelected: HomeScreen.statisticsHandler.onSelectChanged,
            onSelectedChangedNotifier:
                HomeScreen.statisticsHandler.onSelectedChangedNotifier,
            checkBoxActiveColor:
                HomeScreen.statisticsHandler.checkBoxActiveColor,
            decorationFromHeadersToData: VsModeAlert(
              notifier: HomeScreen.statisticsHandler.onSelectedChangedNotifier,
            ),
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: kIsWeb
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => FilesHandler.export(
                  "Statistics",
                  excel: StatisticsConstants.scoutProperties
                      .generateExclusiveExcel(HomeScreen.teams),
                ),
                icon: const Icon(Icons.download),
              ),
              Visibility(
                visible: !kIsWeb,
                child: IconButton(
                  onPressed: () => FilesHandler.share(
                    "Statistics",
                    excel: StatisticsConstants.scoutProperties
                        .generateExclusiveExcel(HomeScreen.teams),
                  ),
                  icon: const Icon(Icons.share),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: isLoading,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class NotAllowedPage extends Center {
  const NotAllowedPage({super.key})
      : super(
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "You don't have permission to view this page!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
}
