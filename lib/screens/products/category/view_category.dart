import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../service/api.service.dart';
import 'add_category.dart';

class ViewCategory extends StatefulWidget {
  final Function()? updateCategory;
  const ViewCategory({super.key, this.updateCategory});

  @override
  ViewCategoryState createState() => ViewCategoryState();
}

class ViewCategoryState extends State<ViewCategory> {
  final apiService = ApiService();
  List filteredCategories = [];
  late List categories = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "title";
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    getProductsList();
    filteredCategories = List.from(categories);
  }

  // Search logic
  void filterProducts(String query) {
    setState(() {
      filteredCategories = categories.where((category) {
        return category.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future updateCategoryList() async {
    setState(() {
      isLoading = true;
    });
    var dbcategories = await apiService.get(
      'category?skip=${categories.length}',
    );
    setState(() {
      categories.addAll(dbcategories.data);
      filteredCategories = List.from(categories);
      isLoading = false;
    });
  }

  Future getProductsList() async {
    var dbcategories = await apiService.get('category');
    setState(() {
      categories = dbcategories.data;
      filteredCategories = List.from(categories);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = categories.where((product) {
      return product.values.any(
        (value) =>
            value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }).toList();

    filteredCategories.sort((a, b) {
      if (ascending) {
        return a[sortBy].toString().compareTo(b[sortBy].toString());
      } else {
        return b[sortBy].toString().compareTo(a[sortBy].toString());
      }
    });

    return filteredCategories;
  }

  int getColumnIndex(String columnName) {
    switch (columnName) {
      case 'title':
        return 0;
      case 'createdAt':
        return 1;
      case 'price':
        return 2;
      case 'quantity':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        smallScreen ? searchBox(smallScreen) : Container(),
        Expanded(
          child: PaginatedDataTable2(
            fixedCornerColor: Theme.of(context).colorScheme.onSecondary,
            columnSpacing: 12,
            horizontalMargin: 12,
            sortColumnIndex: getColumnIndex(sortBy),
            sortAscending: ascending,
            rowsPerPage: rowsPerPage,
            onRowsPerPageChanged: (value) {
              setState(() {
                rowsPerPage = value ?? rowsPerPage;
              });
            },
            // empty: Text('No Products Yet'),
            // minWidth: 500,
            actions: [
              DropdownButton(
                elevation: 0,
                hint: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Filter',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                  ),
                ),
                borderRadius: BorderRadius.circular(10),
                icon: Icon(Icons.filter_alt_outlined, size: 10),
                // value: 'all',
                items: [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(
                    value: 'low stock',
                    child: Text('Low Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'no   stock',
                    child: Text('No Stock'),
                  ),
                ],
                onChanged: (v) {},
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: Icon(Icons.exit_to_app, size: 10),
                label: Text(
                  'Extract',
                  style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10),
                ),
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
                        builder: (context) =>
                            AddCategory(updateCategory: widget.updateCategory),
                      ),
                      label: Text('Add Product'),
                      icon: Icon(Icons.add_box_outlined),
                    ),
                  )
                : Row(children: [searchBox(smallScreen)]),
            columns: [
              DataColumn2(
                label: Text("Title"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'title';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(label: Text("Description"), size: ColumnSize.L),
              DataColumn2(label: Text("Initiator")),
              DataColumn2(
                label: Text('Added On'),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'createdAt';
                    this.ascending = ascending;
                  });
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

  SizedBox searchBox(bool smallScreen) {
    return SizedBox(
      width: smallScreen ? double.infinity : 250,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search...",
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () => filterProducts(_searchController.text),
          ),
        ),
        onChanged: (query) => {filterProducts(query), searchQuery = query},
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
        DataCell(Text(category['title'])),
        DataCell(Text(category['description'])),
        DataCell(Text(category['user'])),
        DataCell(Text(formatDate(category['createdAt']))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // OutlinedButton(onPressed: () {}, child: Text('Update'))
              // OutlinedButton(onPressed: () {}, child: Text('Delete'))
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
