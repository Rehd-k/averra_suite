import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../service/api.service.dart';
import 'add_supplier.dart';

class ViewSuppliers extends StatefulWidget {
  final Function()? updateSupplier;
  const ViewSuppliers({super.key, this.updateSupplier});

  @override
  ViewSuppliersState createState() => ViewSuppliersState();
}

class ViewSuppliersState extends State<ViewSuppliers> {
  final apiService = ApiService();
  List filteredSuppliers = [];
  late List suppliers = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "name";
  bool ascending = true;

  void filterProducts(String query) {
    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        return supplier.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future updateSupplierList() async {
    setState(() {
      isLoading = true;
    });
    var dbsuppliers = await apiService.get('supplier?skip=${suppliers.length}');
    setState(() {
      suppliers.addAll(dbsuppliers.data);
      filteredSuppliers = List.from(suppliers);
      isLoading = false;
    });
  }

  Future getSuppliersList() async {
    var dbsuppliers = await apiService.get('supplier');
    setState(() {
      suppliers = dbsuppliers.data;
      filteredSuppliers = List.from(suppliers);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = suppliers.where((product) {
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
      case 'name':
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
  void initState() {
    super.initState();
    getSuppliersList();
    filteredSuppliers = List.from(suppliers);
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
            empty: Text('No Suppliers Recorded'),
            minWidth: 1500,
            actions: [
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
                            AddSupplier(updateSupplier: widget.updateSupplier),
                      ),
                      label: Text('Add Supplier'),
                      icon: Icon(Icons.add_box_outlined),
                    ),
                  )
                : Row(children: [searchBox(smallScreen)]),
            columns: [
              DataColumn2(
                label: Text("Name"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'name';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(label: Text("Email"), size: ColumnSize.L),
              DataColumn2(label: Text("Phone Number")),
              DataColumn2(label: Text("Address"), size: ColumnSize.L),
              DataColumn2(label: Text("No. of Orders")),
              DataColumn2(label: Text("initiator")),
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
            source: SuppliersDataSource(suppliers: getFilteredAndSortedRows()),
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

class SuppliersDataSource extends DataTableSource {
  final List suppliers;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  SuppliersDataSource({required this.suppliers});

  @override
  DataRow? getRow(int index) {
    if (index >= suppliers.length) return null;
    final supplier = suppliers[index];
    return DataRow(
      cells: [
        DataCell(Text(supplier['name'])),
        DataCell(Text(supplier['email'])),
        DataCell(Text(supplier['phone_number'])),
        DataCell(Text(supplier['address'])),
        DataCell(Text(supplier['orders'].length.toString())),
        DataCell(Text(supplier['initiator'])),
        DataCell(Text(formatDate(supplier['createdAt']))),
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
  int get rowCount => suppliers.length;

  @override
  int get selectedRowCount => 0;
}
