import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Required for dragStartBehavior

import 'big_table_source.dart'; // For date/number formatting (add intl package to pubspec.yaml)

/// Signature for the callback when row selection changes.
typedef SelectionChangedCallback = void Function(
    List<TableDataModel> selectedRows);

//--- Reusable StatefulWidget ---

class ReusableAsyncPaginatedDataTable extends StatefulWidget {
  // Changed to accept ColumnDefinition list
  final List<ColumnDefinition> columnDefinitions;
  final FetchDataCallback fetchDataCallback;
  final SelectionChangedCallback onSelectionChanged;

  // Optional parameters (pass-through)
  final Widget? header;
  final List<Widget>? actions;
  final String? initialSortField; // Changed from index
  final bool initialSortAscending;
  final double dataRowHeight;
  final double headingRowHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final bool showCheckboxColumn;
  final bool showFirstLastButtons;
  final int initialFirstRowIndex;
  final int rowsPerPage;
  final List<int> availableRowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final DragStartBehavior dragStartBehavior;
  final Color? arrowHeadColor;
  final double? checkboxHorizontalMargin;
  final PaginatorController? controller;
  final String rowsPerPageTitle;
  final int fixedLeftColumns;
  final int fixedTopRows;
  final TableBorder? border;
  final double smRatio;
  final double lmRatio;
  final double? minWidth;
  final Widget? empty;
  final Function? handleShowDetails;
  final Function(dynamic rowData)? doDamagedGoods;

  const ReusableAsyncPaginatedDataTable({
    super.key,
    required this.columnDefinitions, // Now required
    required this.fetchDataCallback,
    required this.onSelectionChanged,
    this.header,
    this.actions,
    this.initialSortField, // Changed
    this.initialSortAscending = true,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
    this.initialFirstRowIndex = 0,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.availableRowsPerPage = const [
      PaginatedDataTable.defaultRowsPerPage,
      PaginatedDataTable.defaultRowsPerPage * 2,
      PaginatedDataTable.defaultRowsPerPage * 5,
      PaginatedDataTable.defaultRowsPerPage * 10
    ],
    this.onRowsPerPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    this.arrowHeadColor,
    this.checkboxHorizontalMargin,
    this.controller,
    this.rowsPerPageTitle = 'Rows per page:',
    this.fixedLeftColumns = 1,
    this.fixedTopRows = 1,
    this.border,
    this.smRatio = 0.67,
    this.lmRatio = 1.2,
    this.minWidth,
    this.empty,
    this.doDamagedGoods,
    this.handleShowDetails,
  });

  @override
  State<ReusableAsyncPaginatedDataTable> createState() =>
      _ReusableAsyncPaginatedDataTableState();
}

class _ReusableAsyncPaginatedDataTableState
    extends State<ReusableAsyncPaginatedDataTable> {
  late MyAsyncDataSource _dataSource;
  late String? _currentSortField; // Changed from index
  late bool _currentSortAscending;
  late int _currentRowsPerPage;
  late List<DataColumn> _dataColumns; // Store generated DataColumns

  @override
  void initState() {
    super.initState();
    _currentSortField = widget.initialSortField;
    _currentSortAscending = widget.initialSortAscending;
    _currentRowsPerPage = widget.rowsPerPage;

    _buildDataColumns(); // Generate DataColumns initially
    _initDataSource(); // Initialize the data source
  }

  void _initDataSource() {
    _dataSource = MyAsyncDataSource(
        fetchDataCallback: widget.fetchDataCallback,
        onSelectionChanged: widget.onSelectionChanged,
        columnDefinitions: widget.columnDefinitions, // Pass definitions
        initialSortField: _currentSortField,
        initialSortAscending: _currentSortAscending,
        doDamagedGoods: (rowData) {
          widget.doDamagedGoods!(rowData);
        },
        context: context,
        handleShowDetails: widget.handleShowDetails
        // onShowDetails: (rowData) { /* Handle action if needed */ },
        );
  }

  // Generate DataColumn objects from definitions
  void _buildDataColumns() {
    _dataColumns = widget.columnDefinitions.map((def) {
      return DataColumn2(
        label: Text(def.name),
        tooltip: def.name, // Simple tooltip
        // Only add onSort if the column is sortable
        onSort: def.sortable
            ? (columnIndex, ascending) {
                // Find the corresponding definition using the index
                // Note: This assumes the order of _dataColumns matches widget.columnDefinitions
                if (columnIndex < widget.columnDefinitions.length) {
                  final field = widget.columnDefinitions[columnIndex].field;

                  setState(() {
                    _currentSortField = field;
                    _currentSortAscending = ascending;
                  });
                  // Refresh the data source with new sorting parameters
                  _dataSource.refreshData(
                    sortField: _currentSortField,
                    sortAscending: _currentSortAscending,
                  );
                } else {}
              }
            : null, // No sort callback if not sortable
        // Add numeric hint for relevant types (optional)
        numeric: ['number', 'money'].contains(def.type),
        // You might want to add size constraints based on type or definition
        // size: _getColumnSize(def.type),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(covariant ReusableAsyncPaginatedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool needsSourceRefresh = false;
    bool needsColumnRebuild = false;

    // Check if column definitions themselves changed (requires deep comparison or better ID logic)
    // Simple check for now: if list identity or length changes, rebuild.
    if (widget.columnDefinitions != oldWidget.columnDefinitions ||
        widget.columnDefinitions.length != oldWidget.columnDefinitions.length) {
      needsColumnRebuild = true;
      needsSourceRefresh = true; // New columns mean new source needed
    }

    // Check if callbacks changed
    if (widget.fetchDataCallback != oldWidget.fetchDataCallback ||
        widget.onSelectionChanged != oldWidget.onSelectionChanged) {
      needsSourceRefresh = true; // Need to recreate source with new callbacks
      needsSourceRefresh = true;
    }

    if (widget.rowsPerPage != oldWidget.rowsPerPage) {
      // Update state, table should handle refresh internally via getRows
      _currentRowsPerPage = widget.rowsPerPage;
      // needsSourceRefresh = true;
      // No explicit refresh needed unless backend requires it
    }

    // Rebuild columns if needed
    if (needsColumnRebuild) {
      _buildDataColumns();
    }

    // Re-initialize data source if needed
    if (needsSourceRefresh) {
      _initDataSource();
      // Data source will be called by table automatically, no need for explicit refreshData here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find the index of the currently sorted column based on the field name
    int? currentSortColumnIndex;
    if (_currentSortField != null) {
      currentSortColumnIndex = widget.columnDefinitions
          .indexWhere((def) => def.field == _currentSortField);
      if (currentSortColumnIndex == -1) {
        currentSortColumnIndex = null; // Field not found in current definitions
      }
    }

    return AsyncPaginatedDataTable2(
      // --- Pass through parameters ---

      key: widget.key,
      header: widget.header,
      actions: widget.actions,
      columns: _dataColumns, // Use generated DataColumns
      sortColumnIndex: currentSortColumnIndex, // Pass the calculated index
      sortAscending: _currentSortAscending,
      dataRowHeight: widget.dataRowHeight,
      headingRowHeight: widget.headingRowHeight,
      horizontalMargin: widget.horizontalMargin,
      columnSpacing: widget.columnSpacing,
      showCheckboxColumn: widget.showCheckboxColumn,
      showFirstLastButtons: widget.showFirstLastButtons,
      initialFirstRowIndex: widget.initialFirstRowIndex,
      rowsPerPage: _currentRowsPerPage,
      availableRowsPerPage: widget.availableRowsPerPage,
      onRowsPerPageChanged: (value) {
        if (value != null && value != _currentRowsPerPage) {
          setState(() {
            _currentRowsPerPage = value;
          });
          widget.onRowsPerPageChanged?.call(value);
        }
      },
      dragStartBehavior: widget.dragStartBehavior,
      renderEmptyRowsInTheEnd: false,
      sortArrowIconColor: widget.arrowHeadColor,
      checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
      controller: widget.controller,
      fixedLeftColumns: widget.fixedLeftColumns,
      fixedTopRows: widget.fixedTopRows,
      border: widget.border,
      smRatio: widget.smRatio,
      lmRatio: widget.lmRatio,
      minWidth: widget.minWidth,
      empty: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: const EdgeInsets.all(20),
          child: const Text('No data'),
        ),
      ),
      loading: _Loading(),
      errorBuilder: (e) => _ErrorAndRetry(
        e.toString(),
        () => _dataSource.refreshDatasource(),
      ),

      // --- Core Logic ---
      source: _dataSource,
    );
  }
}

class _ErrorAndRetry extends StatelessWidget {
  const _ErrorAndRetry(this.errorMessage, this.retry);

  final String errorMessage;
  final void Function() retry;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(10),
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Oops! $errorMessage',
                  style: const TextStyle(color: Colors.white)),
              TextButton(
                onPressed: retry,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    Text('Retry', style: TextStyle(color: Colors.white))
                  ],
                ),
              )
            ],
          ),
        ),
      );
}

class _Loading extends StatefulWidget {
  @override
  __LoadingState createState() => __LoadingState();
}

class __LoadingState extends State<_Loading> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface.withAlpha(128),
      // at first show shade, if loading takes longer than 0,5s show spinner
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Theme.of(context).colorScheme.primary,
          ),
          padding: const EdgeInsets.all(7),
          width: 150,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              Text('Loading..',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary))
            ],
          ),
        ),
      ),
    );
  }
}
