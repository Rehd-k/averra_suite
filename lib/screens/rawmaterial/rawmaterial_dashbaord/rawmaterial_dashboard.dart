import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toastification/toastification.dart';

import '../../../components/error.dart';
import '../../../components/finance_card.dart';
import '../../../components/tables/gen_big_table/big_table.dart';
import '../../../components/tables/gen_big_table/big_table_source.dart';
import '../../../service/api.service.dart';
import '../../ledgers/day_ledger.dart';
import 'add_order.dart';
import 'header.dart';
import 'helpers/damaged_goods.dart';
import 'helpers/edit_product.dart';
import 'table_collums.dart';

@RoutePage()
class RawMaterialDashboard extends StatefulWidget {
  final String rawmaterialId;
  final String rawmaterialName;
  final num servingSize;
  final String unit;

  const RawMaterialDashboard({
    super.key,
    required this.rawmaterialId,
    required this.rawmaterialName,
    required this.servingSize,
    required this.unit,
  });

  @override
  RawMaterialDashboardState createState() => RawMaterialDashboardState();
}

class RawMaterialDashboardState extends State<RawMaterialDashboard> {
  ApiService apiService = ApiService();
  JsonEncoder jsonEncoder = JsonEncoder();
  late String rawmaterialId;
  late Map data;
  bool loading = true;
  bool loadingTable = false;
  bool loadingCharts = true;
  late List purchases;
  List<FlSpot> spots = [];
  DateTime? _fromDate = DateTime(2010, 1, 1);
  DateTime? _toDate = DateTime.now();
  dynamic rangeInfo;
  bool allowMultipleSelection = true;
  List returnedSelection = [];
  String selectedRange = 'Today';
  bool showDetails = false;

  String? searchFeild = 'createdAt';
  String? selectedStatus = '';
  String? selectedSupplier = '';
  List<Map> suppliers = [];
  Set supplierSet = <String>{};
  dynamic totalSales = 0;
  bool hasError = false;

  String initialSort = 'createdAt';
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  List<TableDataModel> _selectedRows = [];

  // Convert maps to ColumnDefinition objects
  late List<ColumnDefinition> _columnDefinitions;

  @override
  void initState() {
    _columnDefinitions = columnDefs
        .map((map) => ColumnDefinition.fromMap(map))
        .toList();

    rawmaterialId = widget.rawmaterialId;

    getDashboardData();
    super.initState();
  }

  Future deleteRawMaterial() async {
    showToast('loading...', ToastificationType.info);
    await apiService.delete('rawmaterial/${widget.rawmaterialId}');
    showToast('success', ToastificationType.success);
  }

  Future getDashboardData() async {
    try {
      final dynamic response = await apiService.get(
        'rm-purchases/dashboard/$rawmaterialId',
      );

      setState(() {
        data = response.data;
        loading = false;
        hasError = false;
      });
    } catch (err) {
      setState(() {
        hasError = true;
        loading = false;
      });
    }
  }

  Future callDialog() => showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text(
          'This Process Is Irreversible and will cause Accounting Issues \n Do You Want To Continue',
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false); // Dismiss the dialog
            },
          ),
          TextButton(
            child: Text("Continue"),
            onPressed: () {
              // Perform logout action
              Navigator.of(context).pop(true); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );

  void printSelected() {
    debugPrint(_selectedRows.toString());
  }

  Future<void> handleDamagedGoodsClicked(rowData) async {
    if (returnedSelection.isEmpty) {
      if (rowData['quantity'] == getSold(rowData['sold'])) {
        doAlerts('This batch have been sold out');
      } else {
        showDamagedGoodsForm(
          context,
          handleDamagedGoods,
          rowData['_id'],
          (rowData['quantity'] - getSold(rowData['sold'])),
        );
      }
    }
  }

  Future<void> handleReturnGoodsClicked(rowData) async {
    if (returnedSelection.isEmpty) {
      if (rowData['quantity'] == getSold(rowData['sold'])) {
        doAlerts('This batch have been sold out');
      } else {
        showDamagedGoodsForm(
          context,
          handleDamagedGoods,
          rowData['_id'],
          (rowData['quantity'] - getSold(rowData['sold'])),
        );
      }
    }
  }

  Future<void> handleDamagedGoods(data) async {
    await apiService.put('rm-purchases/doDamage/${data['_id']}', {
      ...data,
      "rawmaterialId": rawmaterialId,
    });
  }

  Future<void> handleReturndGoods(data) async {
    num amountSpent = data['totalPayable'] - data['debt'];
    num quantityPaidFor = amountSpent ~/ data['price'];
    num quantityRemening = data['quantity'] - quantityPaidFor;

    if (data['quantity'] <= quantityRemening) {}

    await apiService.put('rm-purchases/return/${data['_id']}', {
      ...data,
      "rawmaterialId": rawmaterialId,
    });
  }

  Future<void> handleRangeChange(String? select, DateTime? picked) async {
    if (select == 'from') {
      setState(() {
        _fromDate = picked;
      });
    } else if (select == 'to') {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedRange = rangeLabel;
    });
  }

  Future<Map<String, dynamic>> _fetchServerData({
    required int offset,
    required int limit,
    String? sortField,
    bool? sortAscending,
  }) async {
    var sorting = jsonEncoder.convert({
      "$sortField": (sortAscending ?? true) ? 'asc' : 'desc',
    });
    var dbrawmaterial = await apiService.get(
      'rm-purchases?filter={"rawmaterialId":"$rawmaterialId", "$searchFeild" : "","supplier":"$selectedSupplier", "status" :  "${selectedStatus?.toLowerCase()}"}&sort=$sorting&startDate=$_fromDate&endDate=$_toDate&skip=$offset&limit=$limit',
    );

    var {'purchases': purchases, 'totalDocuments': totalDocuments} =
        dbrawmaterial.data;
    // --- Sorting Logic (Mock) ---

    List<TableDataModel> data = List.from(purchases); // Work on a copy

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
    bool isBigScreen = width >= 1200;
    if (!hasError) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.router.back();
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined),
          ),
          title: Text(
            '${capitalizeFirstLetter(widget.rawmaterialName)} Dashboard',
            style: TextStyle(fontSize: 10),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  showDetails = !showDetails;
                });
              },
              icon: AnimatedRotation(
                turns: showDetails ? 0.5 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Icon(Icons.keyboard_arrow_down),
              ),
            ),
            if (isBigScreen)
              IconButton(
                tooltip: 'Add Order',
                onPressed: () => showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddOrder(
                    rawmaterialId: rawmaterialId,
                    getUpDate: getDashboardData,
                    servingSize: widget.servingSize,
                    unit: widget.unit,
                  ),
                ),
                icon: Icon(Icons.add_box_outlined),
              ),
            if (isBigScreen)
              IconButton(
                tooltip: 'View Report',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionsTable(id: rawmaterialId),
                  ),
                ),

                icon: Icon(Icons.view_agenda_outlined, size: 20),
              ),
            if (isBigScreen)
              IconButton(
                tooltip: 'Save Report',
                onPressed: () => showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddOrder(
                    rawmaterialId: rawmaterialId,
                    getUpDate: getDashboardData,
                    servingSize: widget.servingSize,
                    unit: widget.unit,
                  ),
                ),
                icon: Icon(Icons.save_alt_outlined, size: 20),
              ),
            if (isBigScreen)
              IconButton(
                tooltip: 'Edit RawMaterial',
                onPressed: () => {
                  showBarModalBottomSheet(
                    expand: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditRawMaterial(
                      updatePageInfo: () {},
                      rawmaterialId: widget.rawmaterialId,
                    ),
                  ),
                },
                icon: Icon(Icons.edit_note_outlined),
              ),
            if (isBigScreen)
              IconButton(
                onPressed: () async {
                  final bool doDelete = await callDialog();
                  if (doDelete) {
                    deleteRawMaterial();
                  }
                },
                icon: Icon(Icons.delete_outline),
              ),

            if (!isBigScreen)
              PopupMenuButton<int>(
                padding: const EdgeInsets.all(1),
                icon: Icon(
                  Icons.more_vert_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Add Order",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => {
                        showBarModalBottomSheet(
                          expand: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AddOrder(
                            rawmaterialId: rawmaterialId,
                            getUpDate: getDashboardData,
                            servingSize: widget.servingSize,
                            unit: widget.unit,
                          ),
                        ),
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Edit RawMaterial",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => {
                        showBarModalBottomSheet(
                          expand: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SizedBox(),
                          // EditRawMaterial(
                          //   updatePageInfo: getAllData,
                          //   rawmaterialId: widget.rawmaterialId,
                          // ),
                        ),
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.upload_file_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Save Report",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {},
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.show_chart_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Show Report",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionsTable(id: rawmaterialId),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Delete RawMaterial",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final bool doDelete = await callDialog();
                        if (doDelete) {
                          deleteRawMaterial();
                        }
                      },
                    ),
                  ];
                },
                elevation: 2,
              ),
          ],
        ),
        floatingActionButton: isBigScreen
            ? null
            : FloatingActionButton.small(
                tooltip: 'Make an Order',
                onPressed: () => showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddOrder(
                    rawmaterialId: rawmaterialId,
                    getUpDate: getDashboardData,
                    servingSize: widget.servingSize,
                    unit: widget.unit,
                  ),
                ),
                child: Icon(Icons.add_outlined),
              ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  width: double.infinity,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  height: showDetails ? 200 : 0,
                  child: Column(
                    children: [
                      ProductHeader(
                        selectedField: searchFeild,
                        selectedSupplier: selectedSupplier,
                        selectedStatus: selectedStatus,
                        onFieldChange: (value) {
                          setState(() {
                            searchFeild = value;
                          });
                        },
                        onSupplierChange: (value) {
                          setState(() {
                            selectedSupplier = value;
                          });
                        },
                        onSelectStatus: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                        suppliers: suppliers,
                        handleRangeChange: handleRangeChange,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        handleDateReset: handleDateReset,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: isBigScreen ? 550 : 350,
                  child: loading
                      ? Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : cardsInfo(isBigScreen, data),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 600,
                  child: loadingTable
                      ? CircularProgressIndicator()
                      : ReusableAsyncPaginatedDataTable(
                          columnDefinitions:
                              _columnDefinitions, // Pass definitions
                          fetchDataCallback: _fetchServerData,
                          onSelectionChanged: (selected) {
                            _selectedRows = selected;
                          },
                          header: const Text(
                            'Purchases',
                            style: TextStyle(fontSize: 10),
                          ),
                          initialSortField: initialSort,
                          initialSortAscending: true,
                          rowsPerPage: 15,
                          availableRowsPerPage: const [10, 15, 25, 50],
                          showCheckboxColumn: true,
                          fixedLeftColumns: 1, // Fix the 'Title' column
                          minWidth: 2500, // Increase minWidth for more columns
                          empty: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          border: TableBorder.all(
                            color: Colors.grey.shade100,
                            width: 1,
                          ),
                          columnSpacing: 30,
                          dataRowHeight: 50,
                          headingRowHeight: 60,
                          doDamagedGoods: (rowData) {
                            handleDamagedGoodsClicked(rowData);
                          },
                          doReturnGoods: (rowData) {
                            handleReturnGoodsClicked(rowData);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return ErrorPage(onRetry: getDashboardData);
    }
  }

  num getSold(List sold) {
    return sold.fold(0, (sum, item) => sum + (item["amount"] ?? 0));
  }

  void handleDateReset() {
    setState(() {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      // getSales();
    });
  }

  void doAlerts(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        padding: EdgeInsets.all(16),
        content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }

  LayoutBuilder cardsInfo(bool isBigScreen, Map data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;

        bool largeScreen = maxWidth >= 900;
        int cardsPerRow;
        double spacing;

        if (maxWidth >= 900) {
          cardsPerRow = 3; // large screen
          spacing = 16.0;
        } else if (maxWidth >= 600) {
          cardsPerRow = 2; // medium screen
          spacing = 6.0;
        } else {
          cardsPerRow = 2; // small screen
          spacing = 8.0;
        }

        // Card width calculation with spacing

        double cardWidth =
            (maxWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Total Used',
                icon: Icon(Icons.sell_outlined, size: isBigScreen ? 10 : 8),
                isFinancial: false,
                amount: data['totalSales'],
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Total Orders',
                icon: Icon(
                  Icons.drive_file_move_rtl_sharp,
                  size: isBigScreen ? 10 : 8,
                ),
                isFinancial: false,
                amount: data['totalPurchases'],
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Total Orders Value',
                icon: Icon(
                  Icons.drive_file_move_rtl_outlined,
                  size: isBigScreen ? 10 : 8,
                ),
                isFinancial: true,
                amount: data['totalPurchasesValue'],
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Quantity at Store',
                icon: Icon(
                  Icons.inventory_2_outlined,
                  size: isBigScreen ? 10 : 5,
                ),
                isFinancial: false,
                amount: (data['quantity'] - data['totalSales']),
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Expired',
                icon: Icon(
                  Icons.calendar_month_outlined,
                  size: isBigScreen ? 10 : 8,
                ),
                isFinancial: false,
                amount: data['totalExpiredQuantity'],
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Damaged',
                icon: Icon(
                  Icons.dangerous_outlined,
                  size: isBigScreen ? 10 : 8,
                ),
                isFinancial: false,
                amount: data['totalDamagedQuantity'],
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),
          ],
        );
      },
    );
  }
}
