import 'package:dartaframe/dartaframe.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scouting_app/widgets/reactive_check_box.dart';
import 'package:scouting_app/widgets/dataframe_table/widget_supplier.dart';

class DataFrameTable extends StatefulWidget {
  final DataFrame dataFrame;
  final DataFrameColumn? mainIdColumn;
  final List<DataFrameColumn>? dataColumns;
  final Widget? nullDataWidget;
  final LinkedScrollControllerGroup? horizontalController;
  final ScrollPhysics? horizontalPhysics;
  final LinkedScrollControllerGroup? verticalController;
  final ScrollPhysics? verticalPhysics;
  final bool isCheckBoxTogglable;
  final Color? Function(String)? checkBoxActiveColor;
  final bool Function(String, {bool? newValue})? isSelected;
  final ChangeNotifier? onSelectedChangedNotifier;
  final void Function(String, bool)? onDataSort;
  final double fixedFirstRowHeight;
  final double fixedFirstRowMargin;
  final double fixedFirstColumnWidth;
  final double fixedDataCellHeight;
  final double fixedDataCellWidth;
  final double checkboxHorizontalMargin;
  final WidgetStateProperty<Color?>? headingRowColor;
  final WidgetStateProperty<Color?>? dataRowColor;
  final double? dividerThickness;
  final bool showBottomBorder;
  final Widget decorationFromHeadersToData;

  const DataFrameTable({
    super.key,
    required this.dataFrame,
    this.mainIdColumn,
    this.dataColumns,
    this.nullDataWidget,
    this.horizontalController,
    this.horizontalPhysics,
    this.verticalController,
    this.verticalPhysics,
    this.isCheckBoxTogglable = true,
    this.checkBoxActiveColor,
    this.isSelected,
    this.onSelectedChangedNotifier,
    this.onDataSort,
    this.fixedFirstRowHeight = 70.0,
    this.fixedFirstRowMargin = 5,
    this.fixedFirstColumnWidth = 160.0,
    this.fixedDataCellHeight = 50.0,
    this.fixedDataCellWidth = 100.0,
    this.checkboxHorizontalMargin = 50.0,
    this.headingRowColor,
    this.dataRowColor,
    this.dividerThickness,
    this.showBottomBorder = false,
    this.decorationFromHeadersToData = const SizedBox.shrink(),
  });

  @override
  State<DataFrameTable> createState() => _DataFrameTableState();
}

class _DataFrameTableState extends State<DataFrameTable> {
  static const double _dividerThickness = 1.0;

  late LinkedScrollControllerGroup verticalScrollGroup;
  late LinkedScrollControllerGroup horizontalScrollGroup;
  late ScrollController columnIdController;
  late ScrollController headersController;
  late ScrollController dataHorizontalController;
  late List<ScrollController> dataVerticalControllers;
  late bool checkBoxColumnEnabled;
  late int checkedRows;
  String? _lastSortedindex;

  void _initCheckBoxes() {
    checkedRows = 0;
    checkBoxColumnEnabled = false;
    if (widget.isSelected == null) return;
    final DataFrameColumn tableIdColumn =
        widget.mainIdColumn ?? widget.dataFrame.columns.first;
    for (Map<String, Object> row in widget.dataFrame.rows) {
      checkedRows += (_selected(row[tableIdColumn.name].toString()) ? 1 : 0);
    }
  }

  bool _selected(String rowName, {bool? newValue}) {
    if (widget.isSelected == null) return false;
    bool wasEnabled = checkBoxColumnEnabled;
    bool wasSelected = widget.isSelected!(rowName.toString(), newValue: null);
    bool newSelected =
        widget.isSelected!(rowName.toString(), newValue: newValue);
    checkedRows += (wasSelected == newSelected ? 0 : (newSelected ? 1 : -1));
    checkBoxColumnEnabled = (checkedRows > 0) || (!widget.isCheckBoxTogglable);
    if (newValue != null && wasEnabled != checkBoxColumnEnabled) {
      setState(() {});
    }
    return newSelected;
  }

  @override
  void initState() {
    verticalScrollGroup =
        widget.verticalController ?? LinkedScrollControllerGroup();
    horizontalScrollGroup =
        widget.horizontalController ?? LinkedScrollControllerGroup();
    columnIdController = verticalScrollGroup.addAndGet();
    headersController = horizontalScrollGroup.addAndGet();
    dataHorizontalController = horizontalScrollGroup.addAndGet();
    dataVerticalControllers = widget.dataFrame.columns
        .map((column) => verticalScrollGroup.addAndGet())
        .toList();
    _initCheckBoxes();
    super.initState();
  }

  @override
  void dispose() {
    columnIdController.dispose();
    headersController.dispose();
    dataHorizontalController.dispose();
    for (ScrollController element in dataVerticalControllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DataFrameColumn tableIdColumn =
        widget.mainIdColumn ?? widget.dataFrame.columns.first;
    final List<DataFrameColumn> tableDataColumns = widget.dataColumns ??
        widget.dataFrame.columns
            .where((element) => element != tableIdColumn)
            .toList();

    final List<String> columnNames =
        tableDataColumns.map((column) => column.name).toList();

    final ThemeData theme = Theme.of(context);
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);
    final WidgetStateProperty<Color?>? effectiveHeadingRowColor =
        widget.headingRowColor ??
            dataTableTheme.headingRowColor ??
            theme.dataTableTheme.headingRowColor;
    final WidgetStateProperty<Color?>? effectiveDataRowColor =
        widget.dataRowColor ??
            dataTableTheme.dataRowColor ??
            theme.dataTableTheme.dataRowColor;
    final WidgetStateProperty<Color?> defaultRowColor =
        WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.primary.withOpacity(0.08);
        }
        return null;
      },
    );
    final Color? resolvedHeadingRowColor =
        effectiveHeadingRowColor?.resolve(<WidgetState>{});

    final BorderSide borderSide = Divider.createBorderSide(
      context,
      width: widget.dividerThickness ??
          dataTableTheme.dividerThickness ??
          theme.dataTableTheme.dividerThickness ??
          _dividerThickness,
    );

    final idColumnHeader = SizedBox(
      height: widget.fixedFirstRowHeight,
      width: widget.fixedFirstColumnWidth,
      child: GestureDetector(
        onTap: () {
          if (widget.onDataSort == null) return;
          bool ascending = _lastSortedindex != null &&
              tableIdColumn.name == _lastSortedindex;
          _lastSortedindex = !ascending ? tableIdColumn.name : null;
          widget.onDataSort!(tableIdColumn.name, ascending);
        },
        child: Material(
          elevation: 5,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: resolvedHeadingRowColor ?? defaultRowColor.resolve({}),
              border:
                  (widget.showBottomBorder ? Border(bottom: borderSide) : null),
            ),
            child: Text(
              tableIdColumn.name,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    final tableHeaders = Material(
      elevation: 3,
      child: Container(
        width: double.infinity,
        height: widget.fixedFirstRowHeight,
        decoration: BoxDecoration(
          color: resolvedHeadingRowColor ?? defaultRowColor.resolve({}),
          border: Border(
            bottom: (widget.showBottomBorder ? borderSide : BorderSide.none),
          ),
        ),
        child: ListView.builder(
          controller: headersController,
          scrollDirection: Axis.horizontal,
          physics: widget.horizontalPhysics,
          itemCount: columnNames.length,
          itemBuilder: (context, columnIndex) {
            String colName = columnNames.elementAt(columnIndex);
            return GestureDetector(
              onTap: () {
                if (widget.onDataSort == null) return;
                bool ascending =
                    _lastSortedindex != null && colName == _lastSortedindex;
                _lastSortedindex = !ascending ? colName : null;
                widget.onDataSort!(colName, ascending);
              },
              child: Container(
                height: widget.fixedFirstRowHeight,
                width: widget.fixedDataCellWidth,
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.fixedFirstRowMargin),
                  child: Text(
                    colName,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    final idColumnValues = Scrollbar(
      controller: columnIdController,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: ListView.builder(
            controller: columnIdController,
            scrollDirection: Axis.vertical,
            itemCount: widget.dataFrame.rows.length,
            itemBuilder: (context, rowIndex) {
              final itemRow = widget.dataFrame.rows.elementAt(rowIndex);
              final item = itemRow[tableIdColumn.name];
              final String itemName =
                  item is WidgetSupplier ? item.name : item.toString();
              final Set<WidgetState> states = <WidgetState>{
                if (rowIndex % 2 == 0) WidgetState.selected,
              };
              final Color? resolvedDataRowColor =
                  effectiveDataRowColor?.resolve(states) ??
                      defaultRowColor.resolve(states);
              return Container(
                height: widget.fixedDataCellHeight,
                width: widget.fixedFirstColumnWidth,
                decoration: BoxDecoration(
                  color: resolvedDataRowColor,
                  border: (widget.showBottomBorder
                      ? Border(bottom: borderSide)
                      : Border(top: borderSide)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: checkBoxColumnEnabled,
                      replacement: Container(
                        width: 2 * widget.fixedFirstRowMargin,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: widget.checkboxHorizontalMargin,
                        child: ReactiveCheckBox(
                          alignment: Alignment.centerRight,
                          width: widget.checkboxHorizontalMargin -
                              2 * widget.fixedFirstRowMargin,
                          setStateNotifier: widget.onSelectedChangedNotifier,
                          onSelected: (newValue) =>
                              _selected(itemName, newValue: newValue),
                          activeColor: () =>
                              widget.checkBoxActiveColor?.call(itemName),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onDoubleTap: () {
                        if (widget.isSelected == null || checkBoxColumnEnabled) {
                          return;
                        }
                        _selected(itemName, newValue: true);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Visibility(
                        visible: item is WidgetSupplier,
                        replacement: Container(
                          alignment: Alignment.center,
                          width: widget.fixedFirstColumnWidth -
                              4 * widget.fixedFirstRowMargin -
                              (checkBoxColumnEnabled
                                  ? widget.checkboxHorizontalMargin
                                  : 0),
                          child: Text(
                            itemName,
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        child:
                            item is WidgetSupplier ? item.widget : Container(),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );

    final dataTable = Scrollbar(
      controller: dataHorizontalController,
      scrollbarOrientation: ScrollbarOrientation.top,
      child: ListView.builder(
        controller: dataHorizontalController,
        scrollDirection: Axis.horizontal,
        itemCount: columnNames.length,
        itemBuilder: (context, columnIndex) {
          final colName = columnNames.elementAt(columnIndex);

          return SizedBox(
            height: double.infinity,
            width: widget.fixedDataCellWidth,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false, overscroll: false),
              child: ListView.builder(
                controller: dataVerticalControllers[columnIndex],
                scrollDirection: Axis.vertical,
                itemCount: widget.dataFrame.rows.length,
                itemBuilder: (_, rowIndex) {
                  final itemRow = widget.dataFrame.rows.elementAt(rowIndex);
                  final cell = itemRow[colName];
                  final Set<WidgetState> states = <WidgetState>{
                    if (rowIndex % 2 == 0) WidgetState.selected,
                  };
                  final Color? resolvedDataRowColor =
                      effectiveDataRowColor?.resolve(states) ??
                          defaultRowColor.resolve(states);
                  return Container(
                    height: widget.fixedDataCellHeight,
                    width: widget.fixedDataCellWidth,
                    decoration: BoxDecoration(
                      color: resolvedDataRowColor,
                      border: (widget.showBottomBorder
                          ? Border(bottom: borderSide)
                          : Border(top: borderSide)),
                    ),
                    child: Center(
                      child: Visibility(
                        visible: (cell == null || cell is WidgetSupplier),
                        replacement: Text(
                          cell.toString(),
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                        ),
                        child: (cell is WidgetSupplier
                            ? cell.widget
                            : widget.nullDataWidget ??
                                const Icon(Icons.question_mark)),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            idColumnHeader,
            Expanded(
              // Wrap tableHeaders with Expanded
              child: SizedBox(
                width: double.infinity, // Set the width to expand
                height: widget.fixedFirstRowHeight,
                child: tableHeaders,
              ),
            ),
          ],
        ),
        widget.decorationFromHeadersToData,
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: widget.fixedFirstColumnWidth,
                height: double.infinity, // Set the width to expand
                child: idColumnValues,
              ),
              Expanded(
                child: dataTable,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
