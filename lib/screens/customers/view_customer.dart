import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/token.service.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_router.gr.dart';
import '../../helpers/financial_string_formart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../service/api.service.dart';
import 'add_customer.dart';

class ViewCustomers extends StatefulWidget {
  final Function()? updateCustomer;
  const ViewCustomers({super.key, this.updateCustomer});

  @override
  ViewCustomersState createState() => ViewCustomersState();
}

class ViewCustomersState extends State<ViewCustomers> {
  final apiService = ApiService();
  final jwtService = JwtService();
  List filteredCustomers = [];
  late List customers = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "name";
  bool ascending = true;

  void filterProducts(String query) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future updateCustomerList() async {
    setState(() {
      isLoading = true;
    });
    var dbcustomers = await apiService.get('customer?skip=${customers.length}');
    setState(() {
      customers.addAll(dbcustomers.data);
      filteredCustomers = List.from(customers);
      isLoading = false;
    });
  }

  Future getCustomersList() async {
    var dbcustomers = await apiService.get('customer');
    setState(() {
      customers = dbcustomers.data;
      filteredCustomers = List.from(customers);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = customers.where((product) {
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
    getCustomersList();
    filteredCustomers = List.from(customers);
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
            empty: Text('No Customers Recorded'),
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
                            AddCustomer(updateCustomer: widget.updateCustomer),
                      ),
                      label: Text('Add Customer'),
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
              DataColumn2(label: Text("Amount Spent")),
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
            source: CustomersDataSource(
              customers: getFilteredAndSortedRows(),
              context: context,
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

class CustomersDataSource extends DataTableSource {
  final List customers;
  final BuildContext context;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  CustomersDataSource({required this.context, required this.customers});

  @override
  DataRow? getRow(int index) {
    if (index >= customers.length) return null;
    final customer = customers[index];
    return DataRow(
      cells: [
        DataCell(Text(customer['name'])),
        DataCell(Text(customer['email'])),
        DataCell(Text(customer['phone_number'])),
        DataCell(Text(customer['address'])),
        DataCell(
          Text(
            customer['total_spent'].toString().formatToFinancial(
              isMoneySymbol: true,
            ),
          ),
        ),
        DataCell(Text(customer['initiator'])),
        DataCell(Text(formatDate(customer['createdAt']))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  context.router.push(CustomerDetails(customer: customer));
                },
                icon: Icon(
                  Icons.login_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'View Customer',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => customers.length;

  @override
  int get selectedRowCount => 0;
}
