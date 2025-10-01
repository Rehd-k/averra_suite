import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:averra_suite/service/token.service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toastification/toastification.dart';

import '../../../components/charts/line_chart.dart';
import '../../../components/charts/range.dart';
import '../../../components/error.dart';
import '../../../components/finance_card.dart';
import '../../../components/tables/gen_big_table/big_table.dart';
import '../../../components/tables/gen_big_table/big_table_source.dart';
import '../../../service/api.service.dart';
import '../../ledgers/day_ledger.dart';
import '../../ledgers/goods.audit.dart';
import 'add_order.dart';
import 'header.dart';
import 'helpers/damaged_goods.dart';
import 'helpers/edit_product.dart';
import 'helpers/return_goods.dart';
import 'table_collums.dart';

@RoutePage()
class ProductDashboard extends StatefulWidget {
  final String? productId;
  final String? productName;
  final String type;
  final String? servingQuantity;

  const ProductDashboard({
    super.key,
    this.productId,
    this.productName,
    required this.type,
    required this.servingQuantity,
  });

  @override
  ProductDashboardState createState() => ProductDashboardState();
}

class ProductDashboardState extends State<ProductDashboard> {
  ApiService apiService = ApiService();
  JsonEncoder jsonEncoder = JsonEncoder();
  JwtService jwtService = JwtService();
  late String productId;
  late Map data;
  bool loading = true;
  bool loadingTable = true;
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
  dynamic servingQuantity = 1;

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

    if (widget.productId != null) {
      productId = widget.productId!;
    } else {
      hasError = true;
      return;
    }

    if (widget.servingQuantity != null && widget.servingQuantity!.isNotEmpty) {
      if (int.tryParse(widget.servingQuantity!) != null) {
        servingQuantity = int.parse(widget.servingQuantity!);
      }
    }
    getAllData();
    super.initState();
  }

  getAllData() async {
    await getDashboardData();
    await getChartData('Today');
  }

  Future deleteProduct() async {
    showToast('loading...', ToastificationType.info);
    await apiService.delete('products/delete/${widget.productId}');
    showToast('success', ToastificationType.success);
  }

  Future getDashboardData() async {
    try {
      final dynamic response = await apiService.get(
        'products/dashboard/$productId',
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

  Future getChartData(dateRange) async {
    final range = getDateRange(dateRange);
    final response = await apiService.get(
      'sales/getchart/$productId?filter={"sorter":"$dateRange"}&startDate=${range.startDate}&endDate=${range.endDate}',
    );
    setState(() {
      spots.clear();
      response.data.forEach((item) {
        spots.add(
          FlSpot(
            (item['for'] as num).toDouble(),
            (item['totalSales'] as num).toDouble(),
          ),
        );
      });
      rangeInfo = range;
      loadingCharts = false;
      loadingTable = false;
    });
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

  printSelected() {
    debugPrint(_selectedRows.toString());
  }

  handleDamagedGoodsClicked(rowData) async {
    if (returnedSelection.isEmpty) {
      if (rowData['quantity'] == getSold(rowData['sold'])) {
        doAlerts('This batch have been sold out');
      } else {
        showDamagedGoodsForm(
          context,
          handleDamagedGoods,
          rowData['_id'],
          rowData['dropOfLocation'],
          (rowData['quantity'] - getSold(rowData['sold'])),
        );
      }
    }
  }

  handleReturnGoodsClicked(rowData) async {
    if (returnedSelection.isEmpty) {
      if (rowData['quantity'] == getSold(rowData['sold'])) {
        doAlerts('This batch have been sold out');
      } else {
        showReturnsHandler(
          context,
          handleReturndGoods,
          rowData['_id'],
          rowData['dropOfLocation'],
          (rowData['quantity'] - getSold(rowData['sold'])),
        );
      }
    }
  }

  handleDamagedGoods(data) async {
    await apiService.put('purchases/doDamage/${data['_id']}', {
      ...data,
      "productId": productId,
    });
  }

  handleReturndGoods(data) async {
    await apiService.put('purchases/return/${data['_id']}', {
      ...data,
      "productId": productId,
    });
  }

  handleRangeChange(String? select, DateTime? picked) async {
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

  handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedRange = rangeLabel;
    });
    getChartData(selectedRange);
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
    var dbproducts = await apiService.get(
      'purchases?filter={"productId":"$productId", "$searchFeild" : "","supplier":"$selectedSupplier", "status" :  "${selectedStatus?.toLowerCase()}"}&sort=$sorting&startDate=$_fromDate&endDate=$_toDate&skip=$offset&limit=$limit',
    );

    var {'purchases': purchases, 'totalDocuments': totalDocuments} =
        dbproducts.data;
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
            '${capitalizeFirstLetter(widget.productName!)} Dashboard',
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
              if ([
                'god',
                'admin',
                'manager',
                'supervisor',
                'store',
              ].contains(jwtService.decodedToken?['role']))
                IconButton(
                  tooltip: 'Add Order',
                  onPressed: () => showBarModalBottomSheet(
                    expand: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddOrder(
                      productId: productId,
                      getUpDate: getAllData,
                      type: widget.type,
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
                    builder: (context) => TransactionsTable(id: productId),
                    // GoodsAudit(product: 'star')
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
                    productId: productId,
                    getUpDate: getAllData,
                    type: widget.type,
                  ),
                ),
                icon: Icon(Icons.save_alt_outlined, size: 20),
              ),
            if (isBigScreen)
              if ([
                'god',
                'admin',
                'manager',
              ].contains(jwtService.decodedToken?['role']))
                IconButton(
                  tooltip: 'Edit Product',
                  onPressed: () => showBarModalBottomSheet(
                    expand: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditProduct(
                      updatePageInfo: getAllData,
                      productId: widget.productId,
                    ),
                  ),
                  icon: Icon(Icons.edit_note_outlined),
                ),
            if (isBigScreen)
              if ([
                'god',
                'admin',
                'manager',
              ].contains(jwtService.decodedToken?['role']))
                IconButton(
                  onPressed: () async {
                    final bool doDelete = await callDialog();
                    if (doDelete) {
                      deleteProduct();
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
                    if ([
                      'god',
                      'admin',
                      'manager',
                      'supervisor',
                      'store',
                    ].contains(jwtService.decodedToken?['role']))
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
                              productId: productId,
                              getUpDate: getAllData,
                              type: widget.type,
                            ),
                          ),
                        },
                      ),
                    if ([
                      'god',
                      'admin',
                      'manager',
                    ].contains(jwtService.decodedToken?['role']))
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
                              "Edit Product",
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
                            builder: (context) => EditProduct(
                              updatePageInfo: getAllData,
                              productId: widget.productId,
                            ),
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
                              TransactionsTable(id: productId),
                          // GoodsAudit(product: 'star'),
                        ),
                      ),
                    ),
                    if ([
                      'god',
                      'admin',
                      'manager',
                    ].contains(jwtService.decodedToken?['role']))
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
                              "Delete Product",
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
                            deleteProduct();
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
                    productId: productId,
                    getUpDate: getAllData,
                    type: widget.type,
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
                loadingCharts
                    ? Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(
                        height: isBigScreen ? 600 : 900,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isBigScreen
                            ? Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Card(
                                      elevation: 3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      child: MainLineChart(
                                        onRangeChanged: handleRangeChanged,
                                        rangeInfo: rangeInfo,
                                        selectedRange: selectedRange,
                                        spots: spots,
                                        isCurved: true,
                                        redSpots: [],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: ProductCategoryChart(),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: Card(
                                      elevation: 3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      child: MainLineChart(
                                        onRangeChanged: handleRangeChanged,
                                        rangeInfo: rangeInfo,
                                        selectedRange: selectedRange,
                                        spots: [],
                                        isCurved: false,
                                        redSpots: [],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                  Expanded(child: ProductCategoryChart()),
                                ],
                              ),
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

  handleDateReset() {
    setState(() {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      // getSales();
    });
  }

  doAlerts(String message) {
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
                title: 'Total Sales',
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
                title: 'Total Purchases',
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
                title: 'Total Revenue',
                icon: Icon(Icons.payments_outlined, size: isBigScreen ? 10 : 8),
                isFinancial: true,
                amount: data['totalSalesValue'],
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Profit Margin',
                icon: Icon(Icons.money_outlined, size: isBigScreen ? 10 : 8),
                isFinancial: true,
                amount: data['totalProfit'],
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
                  size: isBigScreen ? 10 : 8,
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

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: '${widget.type}s',
                icon: Icon(
                  Icons.dangerous_outlined,
                  size: isBigScreen ? 10 : 8,
                ),
                isFinancial: false,
                amount: widget.type != 'unit'
                    ? (((data['quantity'] ?? 0) - (data['totalSales'] ?? 0)) ~/
                          servingQuantity)
                    : ((data['quantity'] ?? 0) - (data['totalSales'] ?? 0)),
                fontSize: isBigScreen ? 10 : 5,
                largeScreen: largeScreen,
                // color: Theme.of(context).colorScheme.surface,
              ),
            ),

            if (widget.type != 'unit')
              SizedBox(
                width: cardWidth,
                child: FinanceCard(
                  title: 'units',
                  icon: Icon(
                    Icons.dangerous_outlined,
                    size: isBigScreen ? 10 : 8,
                  ),
                  isFinancial: false,
                  amount:
                      (((data['quantity'] ?? 0) - (data['totalSales'] ?? 0)) %
                      servingQuantity),
                  fontSize: isBigScreen ? 10 : 5,
                  largeScreen: largeScreen,
                  // color: Theme.of(context).colorScheme.surface,
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProductCategoryChart extends StatelessWidget {
  const ProductCategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(
                x: 1,
                barRods: [BarChartRodData(color: Colors.green, toY: 30)],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [BarChartRodData(toY: 20, color: Colors.red)],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [BarChartRodData(toY: 40, color: Colors.blue)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
