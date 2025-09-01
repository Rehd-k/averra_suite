import 'dart:convert';
import 'package:flutter/material.dart';

import '../../components/tables/gen_big_table/big_table.dart';
import '../../components/tables/gen_big_table/big_table_source.dart';

import '../../service/api.service.dart';
import 'table_column.dart';

class ViewMaterials extends StatelessWidget {
  final String searchFeild;
  final String searchQuery;
  final String selectedCategory;
  final String initialSort;
  final bool isLoading;
  final ApiService apiService;
  final List categories;
  final List<ColumnDefinition> columnDefinitions;
  final Function setSelectField;
  final Function submitSearch;
  final Function onSearchChanged;
  final Function setSelectedCategory;
  final TextEditingController categoryController;
  final TextEditingController searchController;
  final List<TableDataModel> selectedRows;
  final Function handleSelectedRows;
  final JsonEncoder jsonEncoder;
  final int rowsPerPage;
  final Widget tableHeader;
  final List<Widget> actions;

  const ViewMaterials({
    super.key,
    required this.searchFeild,
    required this.searchQuery,
    required this.categoryController,
    required this.isLoading,
    required this.apiService,
    required this.categories,
    required this.setSelectField,
    required this.submitSearch,
    required this.onSearchChanged,
    required this.setSelectedCategory,
    required this.columnDefinitions,
    required this.selectedCategory,
    required this.initialSort,
    required this.selectedRows,
    required this.handleSelectedRows,
    required this.jsonEncoder,
    required this.searchController,
    required this.rowsPerPage,
    required this.tableHeader,
    required this.actions,
  });

  Future<Map<String, dynamic>> _fetchServerData({
    required int offset,
    required int limit,
    String? sortField,
    bool? sortAscending,
  }) async {
    var sorting = jsonEncoder.convert({
      "$sortField": (sortAscending ?? true) ? 'asc' : 'desc',
    });

    var dbproducts = await apiService.get(
      'rawmaterial?filter={"$searchFeild" : {"\$regex" : "${searchQuery.toLowerCase()}"}, "category" :  {"\$regex" : "${categoryController.text.toLowerCase()}"}}&skip=$offset&limit=$limit&sort=$sorting',
    );

    var {'materials': materials, 'totalDocuments': totalDocuments} =
        dbproducts.data;
    // --- Sorting Logic (Mock) ---
    List<TableDataModel> data = List.from(materials); // Work on a copy

    // --- Pagination Logic (Mock) ---
    final totalRows = totalDocuments;
    final paginatedData = data.toList();
    return {
      'rows': paginatedData, // Return the list of maps
      'totalRows': totalRows,
    };
  }
  // --- End Mock Backend ---

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        // Header(
        //   searchFeild: searchFeild,
        //   setSelectField: setSelectField,
        //   searchController: searchController,
        //   submitSearch: submitSearch,
        //   onSearchChanged: onSearchChanged,
        //   selectedCategory: selectedCategory,
        //   categories: categories,
        //   setSelectedCategory: setSelectedCategory,
        // ),
        Expanded(
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                )
              : ReusableAsyncPaginatedDataTable(
                  showCheckboxColumn: false,
                  columnDefinitions: columnDefinitions, // Pass definitions
                  fetchDataCallback: _fetchServerData,
                  onSelectionChanged: (selected) {
                    handleSelectedRows(selected);
                  },
                  header: tableHeader,
                  actions: actions,
                  initialSortField: initialSort,
                  initialSortAscending: true,
                  rowsPerPage: 15,
                  availableRowsPerPage: const [10, 15, 25, 50],
                  fixedLeftColumns: smallScreen ? 0 : 1,
                  minWidth: 1500,
                  empty: const Center(child: CircularProgressIndicator()),
                  border: TableBorder.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  columnSpacing: 30,
                  dataRowHeight: 50,
                  headingRowHeight: 60,
                ),
        ),
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.searchFeild,
    required this.setSelectField,
    required this.searchController,
    required this.submitSearch,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.categories,
    required this.setSelectedCategory,
  });

  final String searchFeild;
  final Function setSelectField;
  final TextEditingController searchController;
  final Function submitSearch;
  final Function onSearchChanged;
  final String selectedCategory;
  final List categories;
  final Function setSelectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: searchFeild,
          hint: const Text('Search Field'),
          items: dropRmDownMaps
              .map(
                (field) => DropdownMenuItem<String>(
                  value: field['field'],
                  child: Text(field['name']),
                ),
              )
              .toList(),
          onChanged: (value) {
            setSelectField(value);
          },
        ),
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => submitSearch(),
          onChanged: (_) => onSearchChanged(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectedCategory.isEmpty ? null : selectedCategory,
                hint: const Text('Select Category'),
                items: [
                  DropdownMenuItem<String>(value: '', child: Text('')),
                  ...categories.map(
                    (category) => DropdownMenuItem<String>(
                      value: category['title'],
                      child: Text(category['title']),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setSelectedCategory(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
