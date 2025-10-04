import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewLocations extends StatelessWidget {
  final List filteredLocations;
  final TextEditingController searchController;
  final bool isLoading;
  final int rowsPerPage;

  final String sortBy;
  final bool ascending;
  final Function filterLocations;
  final Function getFilteredAndSortedRows;
  final Function getColumnIndex;
  final Function deleteLocation;
  const ViewLocations({
    super.key,
    required this.filteredLocations,
    required this.searchController,
    required this.isLoading,
    required this.rowsPerPage,
    required this.sortBy,
    required this.ascending,
    required this.filterLocations,
    required this.getFilteredAndSortedRows,
    required this.getColumnIndex,
    required this.deleteLocation,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        smallScreen ? searchBox(smallScreen, context) : Container(),
        Expanded(
          child: PaginatedDataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            sortColumnIndex: getColumnIndex(sortBy),
            sortAscending: ascending,
            rowsPerPage: rowsPerPage,
            onRowsPerPageChanged: (value) {
              // setState(() {
              //   rowsPerPage = value ?? rowsPerPage;
              // });
            },
            empty: Text('No Locations Recorded'),
            minWidth: 1000,

            header: smallScreen
                ? SizedBox()
                : Row(children: [searchBox(smallScreen, context)]),
            columns: [
              DataColumn2(
                label: Text("Name"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  // setState(() {
                  //   sortBy = 'name';
                  //   this.ascending = ascending;
                  // });
                },
              ),
              DataColumn2(label: Text("Location")),
              DataColumn2(label: Text("Manager")),
              DataColumn2(label: Text("Opening Hours")),
              DataColumn2(label: Text('Opening Hours')),
              DataColumn2(label: Text("initiator")),
              DataColumn2(
                label: Text('Added On'),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  // setState(() {
                  //   sortBy = 'createdAt';
                  //   this.ascending = ascending;
                  // });
                },
              ),
              DataColumn2(label: Text('Actions')),
            ],
            source: LocationsDataSource(
              locations: getFilteredAndSortedRows(),
              deleteLocation: deleteLocation,
            ),
            border: TableBorder(
              horizontalInside: BorderSide.none,
              verticalInside: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  SizedBox searchBox(bool smallScreen, BuildContext context) {
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
            onPressed: () => filterLocations(searchController.text),
          ),
        ),
        onChanged: (query) => {filterLocations(query)},
      ),
    );
  }
}

class LocationsDataSource extends DataTableSource {
  final List locations;
  final Function deleteLocation;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  LocationsDataSource({required this.locations, required this.deleteLocation});

  @override
  DataRow? getRow(int index) {
    if (index >= locations.length) return null;
    final location = locations[index];
    return DataRow(
      cells: [
        DataCell(Text(location['name'])),
        DataCell(Text(location['location'])),
        DataCell(Text(location['manager'])),
        DataCell(Text(location['openingHours'] ?? '')),
        DataCell(Text(location['closingHours'] ?? '')),
        DataCell(Text(location['initiator'])),
        DataCell(Text(formatDate(location['createdAt']))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // OutlinedButton(onPressed: () {}, child: Text('Update'))
              location['name'] != 'main'
                  ? OutlinedButton(
                      onPressed: () {
                        deleteLocation(location['_id']);
                      },
                      child: Text('Delete'),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => locations.length;

  @override
  int get selectedRowCount => 0;
}
