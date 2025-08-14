// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import 'data_sources.dart';

class MainTable extends StatelessWidget {
  final List data;
  final Widget range;
  final List columnDefs;
  final Map sortableColumns;
  final List<Widget>? actions;
  final String title;
  final bool isLoading;
  final bool showCheckboxColumn;
  final bool allowMultipleSelection;
  final Function(List) onSelectionChanged;
  final Function(int, bool) onSort;
  final Function(int) onPageChanged;
  final int currentPage;
  final bool longPress;
  final int rowsPerPage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool kkk;

  const MainTable({
    super.key,
    required this.isLoading,
    required this.data,
    required this.columnDefs,
    required this.sortableColumns,
    required this.actions,
    required this.title,
    required this.range,
    required this.showCheckboxColumn,
    required this.allowMultipleSelection,
    required this.onSelectionChanged,
    required this.onSort,
    required this.onPageChanged,
    required this.currentPage,
    required this.longPress,
    required this.rowsPerPage,
    this.sortColumnIndex,
    this.sortAscending = true,
    required this.kkk,
  });

  List<DataColumn2> _buildColumns(BuildContext context) {
    return columnDefs.asMap().entries.map((entry) {
      final Map<String, dynamic> column = entry.value;
      final int index = entry.key;

      return DataColumn2(
        label: Text(column['name']),
        onSort: column['sortable']
            ? (columnIndex, ascending) => onSort(columnIndex, ascending)
            : null,
        size: ColumnSize.M,
        fixedWidth: index == 0 ? 200 : null, // First column fixed width
        // fixed: index == 0 ? true : false, // First column fixed position
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = DessertDataSourceAsync(
      data: data,
      columnDefs: columnDefs,
      allowMultipleSelection: allowMultipleSelection,
      handleSelection: (selectedRows) {
        // Pass selected rows to parent
        onSelectionChanged(selectedRows);
      },
      context: context,
      longPress: longPress,
      actions: actions,
    );

    return SizedBox(
      height: 600,
      child: Column(
        children: [
          Expanded(
            child: AsyncPaginatedDataTable2(
              horizontalMargin: 30,
              checkboxHorizontalMargin: 12,
              showCheckboxColumn: showCheckboxColumn,
              columnSpacing: 0,
              wrapInCard: true,
              header: Text(
                '$title ${data.length}',
                style: const TextStyle(fontSize: 12),
              ),
              rowsPerPage: rowsPerPage,
              autoRowsToHeight: false,
              minWidth: 1500,
              fit: FlexFit.tight,
              onRowsPerPageChanged: (value) => onPageChanged(value ?? 10),
              initialFirstRowIndex: currentPage * rowsPerPage,
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              sortArrowIcon: Icons.keyboard_arrow_up,
              sortArrowAnimationDuration: const Duration(milliseconds: 0),
              availableRowsPerPage: const [10, 25, 50, 100],
              showFirstLastButtons: true,
              renderEmptyRowsInTheEnd: false,
              // columnResizeMode: ColumnResizeMode.onResize,
              fixedLeftColumns: 1,
              // enableDragSelection: true,
              onSelectAll: (select) {
                if (select != null) {
                  if (select) {
                    dataSource.selectAll();
                  } else {
                    dataSource.deselectAll();
                  }
                  onSelectionChanged(dataSource.getSelectedRows());
                }
              },
              columns: _buildColumns(context),
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
              loading: isLoading ? _Loading() : null,
              errorBuilder: (e) => _ErrorAndRetry(
                e.toString(),
                () => dataSource.refreshDatasource(),
              ),

              source: dataSource,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: range,
          )
        ],
      ),
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          color: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.all(7),
          width: 150,
          height: 50,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
              Text('Loading..')
            ],
          ),
        ),
      ),
    );
  }
}
