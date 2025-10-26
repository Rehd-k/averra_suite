import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


class ViewCategory extends StatelessWidget {
  final int rowsPerPage;
  final void Function(int) onRowsPerPageChanged;
  final String sortBy;
  final bool ascending;
  final int Function(String) getColumnIndex;
  final void Function(String, bool) onSortChanged;
  final void Function(String) filterProducts;
  final List Function() getFilteredAndSortedRows;
  final TextEditingController searchController;
  final void Function(Map<String, dynamic>) updateCategory;
  final VoidCallback? onExtract; // optional

  const ViewCategory({
    super.key,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    required this.sortBy,
    required this.ascending,
    required this.getColumnIndex,
    required this.onSortChanged,
    required this.filterProducts,
    required this.getFilteredAndSortedRows,
    required this.searchController,
    required this.updateCategory,
    this.onExtract,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        smallScreen ? searchBox(context, smallScreen) : Container(),
        Expanded(
          child: PaginatedDataTable2(
            fixedCornerColor: Theme.of(context).colorScheme.onSecondary,
            columnSpacing: 12,
            horizontalMargin: 12,
            sortColumnIndex: getColumnIndex(sortBy),
            sortAscending: ascending,
            rowsPerPage: rowsPerPage,
            onRowsPerPageChanged: (value) {
              onRowsPerPageChanged(value ?? rowsPerPage);
            },
            actions: [
              IconButton.filledTonal(
                onPressed: onExtract,
                icon: Icon(Icons.exit_to_app, size: 10),
                tooltip: 'Extract',
              ),
            ],
            header: smallScreen
                ? SizedBox(
                    width: 10,
                    child: FilledButton.icon(
                      onPressed: () => showBarModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SizedBox(),
                        // AddCategory(updateCategory: updateCategory),
                      ),
                      label: Text('Add Product'),
                      icon: Icon(Icons.add_box_outlined),
                    ),
                  )
                : Row(children: [searchBox(context, smallScreen)]),
            columns: [
              DataColumn2(
                label: Text("Title"),
                size: ColumnSize.L,
                onSort: (index, asc) {
                  onSortChanged('title', asc);
                },
              ),
              DataColumn2(label: Text("Description"), size: ColumnSize.L),
              DataColumn2(label: Text("Initiator")),
              DataColumn2(
                label: Text('Added On'),
                size: ColumnSize.L,
                onSort: (index, asc) {
                  onSortChanged('createdAt', asc);
                },
              ),
              DataColumn2(label: Text('Actions')),
            ],
            source: CategoryDataSource(categories: getFilteredAndSortedRows()),
            border: TableBorder(
              horizontalInside: BorderSide.none,
              verticalInside: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget searchBox(BuildContext context, bool smallScreen) {
    return SizedBox(
      width: smallScreen ? double.infinity : 250,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search...",
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () => filterProducts(searchController.text),
          ),
        ),
        onChanged: (query) {
          filterProducts(query);
        },
      ),
    );
  }
}

class CategoryDataSource extends DataTableSource {
  final List categories;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  CategoryDataSource({required this.categories});

  @override
  DataRow? getRow(int index) {
    if (index >= categories.length) return null;
    final category = categories[index];
    return DataRow(
      cells: [
        DataCell(Text(category['title'] ?? '')),
        DataCell(Text(category['description'] ?? '')),
        DataCell(Text(category['initiator'] ?? '')),
        DataCell(
          Text(formatDate(category['createdAt'] ?? '1970-01-01T00:00:00Z')),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // action buttons can be provided by parent via callbacks if needed
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categories.length;

  @override
  int get selectedRowCount => 0;
}
