import 'package:auto_route/auto_route.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../app_router.gr.dart';
import '../../helpers/supplierholder.dart';
import '../../service/api.service.dart';

@RoutePage()
class ViewSuppliersScreen extends StatefulWidget {
  const ViewSuppliersScreen({super.key});

  @override
  ViewSuppliersState createState() => ViewSuppliersState();
}

class ViewSuppliersState extends State<ViewSuppliersScreen> {
  final apiService = ApiService();
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  List<Supplier> filteredSuppliers = [];
  late List suppliers = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "name";
  bool ascending = true;

  void filterProducts(String query) {
    setState(() {
      suppliers.where((supplier) {
        return supplier.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();

      filteredSuppliers = List.from(
        suppliers.map((res) {
          return Supplier(
            name: res['name'],
            primaryContact: res['contactPerson'],
            email: res['contactPerson'],
            phoneNumber: res['phone_number'],
            status: res['status'],
          );
        }),
      );
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
    suppliers = dbsuppliers.data;
    setState(() {
      filteredSuppliers = List.from(
        suppliers.map((res) {
          return Supplier(
            name: res['name'],
            primaryContact: res['contactPerson'],
            email: res['contactPerson'],
            phoneNumber: res['phone_number'],
            status: res['status'],
          );
        }),
      );
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

    ShowcaseView.register(
      autoPlayDelay: const Duration(seconds: 3),
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => ShowcaseView.get().dismiss(),

            child: const Text('Skip'),
          ),
        ),
      ),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 20,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          textStyle: const TextStyle(color: Colors.white),
          // Here we don't need previous action for the first showcase widget
          // so we hide this action for the first showcase widget
          hideActionWidgetForShowcase: [_one],
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          textStyle: const TextStyle(color: Colors.white),
          // Here we don't need next action for the last showcase widget so we
          // hide this action for the last showcase widget
          hideActionWidgetForShowcase: [_five],
        ),
      ],
    );

    // Start showcase after the screen is rendered to ensure internal initialization.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          ShowcaseView.get().startShowCase([_one, _two, _three, _four, _five]),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        // smallScreen ? searchBox(smallScreen) : Container(),
        Expanded(
          child: PaginatedDataTable2(
            headingRowColor: WidgetStateProperty.all(
              Theme.of(context).cardColor,
            ),
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
              Showcase(
                tooltipBackgroundColor: Theme.of(context).cardColor,
                key: _two,
                title: 'Search Suppliers',
                titleTextStyle: TextStyle(
                  fontSize: !smallScreen ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
                descTextStyle: TextStyle(fontSize: !smallScreen ? 12 : 10),
                description:
                    'Click to Extract the Suppliers List as a CSV File',
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.exit_to_app, size: 10),
                  label: Text(
                    'Extract',
                    style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10),
                  ),
                ),
              ),
            ],
            header: smallScreen
                ? SizedBox()
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
              DataColumn2(label: Text("Primary Contact"), size: ColumnSize.L),
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
            source: SuppliersDataSource(
              suppliers: getFilteredAndSortedRows(),
              context: context,
              three: _three,
              four: _four,
              five: _five,
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

  Showcase searchBox(bool smallScreen) {
    return Showcase(
      tooltipBackgroundColor: Theme.of(context).cardColor,
      key: _one,
      title: 'Search Suppliers',
      titleTextStyle: TextStyle(
        fontSize: !smallScreen ? 12 : 10,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: TextStyle(fontSize: !smallScreen ? 12 : 10),
      description:
          'Use Either Name, Email, or Phone Number to Search For Suppliers',
      child: SizedBox(
        width: smallScreen ? double.infinity : 250,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search...",
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => filterProducts(_searchController.text),
            ),
          ),
          onChanged: (query) => {filterProducts(query), searchQuery = query},
        ),
      ),
    );
  }
}

class SuppliersDataSource extends DataTableSource {
  final List suppliers;
  BuildContext context;
  final GlobalKey three;
  final GlobalKey four;
  final GlobalKey five;

  SuppliersDataSource({
    required this.suppliers,
    required this.context,
    required this.three,
    required this.four,
    required this.five,
  });

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= suppliers.length) return null;
    final supplier = suppliers[index];
    return DataRow(
      onLongPress: () {
        context.router.push(SupplierDetailsRoute(supplierId: supplier['_id']));
      },
      cells: [
        DataCell(Text(supplier['name'])),
        DataCell(Text(supplier['email'])),
        DataCell(Text(supplier['contactPerson'])),
        DataCell(Text(supplier['phone_number'])),
        DataCell(Text(supplier['address'])),
        DataCell(Text(supplier['orders'].length.toString())),
        DataCell(Text(supplier['initiator'])),
        DataCell(Text(formatDate(supplier['createdAt']))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Showcase(
                tooltipBackgroundColor: Theme.of(context).cardColor,
                key: three,
                title: 'Search Suppliers',
                titleTextStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                descTextStyle: TextStyle(fontSize: 10),
                description:
                    'Click to View This Supplier\'s Detailed Information',
                child: InkWell(
                  onTap: () {
                    context.router.push(
                      SupplierDetailsRoute(supplierId: supplier['_id']),
                    );
                  },
                  child: Tooltip(
                    message: 'Open',
                    child: Icon(Icons.open_in_full_outlined, size: 12),
                  ),
                ),
              ),
              Showcase(
                tooltipBackgroundColor: Theme.of(context).cardColor,
                key: four,
                title: 'Deactivate Suppliers',
                titleTextStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                descTextStyle: TextStyle(fontSize: 10),
                description:
                    'Click to Deactivate This Supplier from the System',
                child: InkWell(
                  onTap: () {},
                  child: Tooltip(
                    message: 'Deactivate',
                    child: Icon(Icons.remove_circle_outline, size: 12),
                  ),
                ),
              ),
              Showcase(
                tooltipBackgroundColor: Theme.of(context).cardColor,
                key: five,
                title: 'Delete Suppliers',
                titleTextStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                descTextStyle: TextStyle(fontSize: 10),
                description: 'Click to Remove This Supplier from the System',
                child: InkWell(
                  onTap: () {},
                  child: Tooltip(
                    message: 'Delete',
                    child: Icon(Icons.delete_forever_outlined, size: 12),
                  ),
                ),
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
  int get rowCount => suppliers.length;

  @override
  int get selectedRowCount => 0;
}
