import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../components/charts/line_chart.dart';
import '../../../components/charts/range.dart';
import '../../../components/error.dart';
import '../../../components/finance_card.dart';
import '../../../components/tables/gen_big_table/big_table.dart';
import '../../../components/tables/gen_big_table/big_table_source.dart';
import '../../../service/api.service.dart';
import 'add_order.dart';
import 'header.dart';
import 'helpers/damaged_goods.dart';
import 'helpers/edit_product.dart';
import 'table_collums.dart';

@RoutePage()
class ProductDashboard extends StatefulWidget {
  final String? productId;
  final String? productName;
  final String type;
  final String? cartonAmount;

  const ProductDashboard({
    super.key,
    this.productId,
    this.productName,
    required this.type,
    required this.cartonAmount,
  });

  @override
  ProductDashboardState createState() => ProductDashboardState();
}

class ProductDashboardState extends State<ProductDashboard> {
  ApiService apiService = ApiService();
  JsonEncoder jsonEncoder = JsonEncoder();
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
  dynamic cartonAmount = 1;

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

    if (widget.cartonAmount != null && widget.cartonAmount!.isNotEmpty) {
      if (int.tryParse(widget.cartonAmount!) != null) {
        cartonAmount = int.parse(widget.cartonAmount!);
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
    try {
      await apiService.delete('products/delete/${widget.productId}');
      // ignore: use_build_context_synchronously
      context.router.pop();
    } catch (err) {
      setState(() {
        hasError = true;
      });
    }
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

  printSelected() {
    debugPrint(_selectedRows.toString());
  }

  handleDamagedGoodsClicked(rowData) async {
    // print(rowData);
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

  handleDamagedGoods(data) async {
    await apiService.put('purchases/update/${data['_id']}', {
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
          title: Text('${widget.productName} Dashboard'),
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
            IconButton(
              onPressed: () {
                // openBox(context, deleteProduct);
              },
              icon: Icon(Icons.delete_outline),
            ),
          ],
        ),
        floatingActionButton: isBigScreen
            ? null
            : FloatingActionButton(
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
                  height: isBigScreen
                      ? widget.type != 'unit'
                            ? 510
                            : 400
                      : widget.type != 'unit'
                      ? 500
                      : 450,
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
                          header: const Text('Order'),
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

  GridView cardsInfo(bool isBigScreen, Map data) {
    return GridView.count(
      physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
      primary: true,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      crossAxisCount: isBigScreen ? 3 : 2,
      childAspectRatio: 3,
      children: [
        FinanceCard(
          title: 'Total Sales',
          icon: Icon(Icons.sell_outlined),
          isFinancial: false,
          amount: data['totalSales'],
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Total Orders',
          icon: Icon(Icons.drive_file_move_rtl_sharp),
          isFinancial: false,
          amount: data['totalPurchases'],
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Total Purchases',
          icon: Icon(Icons.drive_file_move_rtl_outlined),
          isFinancial: false,
          amount: data['totalPurchasesValue'],
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Total Revenue',
          icon: Icon(Icons.payments_outlined),
          isFinancial: true,
          amount: data['totalSalesValue'],
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Profit Margin',
          icon: Icon(Icons.money_outlined),
          isFinancial: true,
          amount: data['totalProfit'],
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Quanitity at Store',
          icon: Icon(Icons.inventory_2_outlined),
          isFinancial: false,
          amount: (data['quantity'] - data['totalSales']),
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Expired',
          icon: Icon(Icons.calendar_month_outlined),
          isFinancial: false,
          amount: data['totalExpiredQuantity'],
          fontSize: isBigScreen ? 10 : 5,
        ),
        FinanceCard(
          title: 'Damaged',
          icon: Icon(Icons.dangerous_outlined),
          isFinancial: false,
          amount: data['totalDamagedQuantity'],
          fontSize: isBigScreen ? 10 : 5,
        ),

        FinanceCard(
          title: '${widget.type}s',
          icon: Icon(Icons.dangerous_outlined),
          isFinancial: false,
          amount: widget.type != 'unit'
              ? (((data['quantity'] ?? 0) - (data['totalSales'] ?? 0)) ~/
                    cartonAmount)
              : ((data['quantity'] ?? 0) - (data['totalSales'] ?? 0)),
          fontSize: isBigScreen ? 10 : 5,
          // color: Theme.of(context).colorScheme.surface,
        ),
        widget.type != 'unit'
            ? FinanceCard(
                title: 'units',
                icon: Icon(Icons.dangerous_outlined),
                isFinancial: false,
                amount:
                    (((data['quantity'] ?? 0) - (data['totalSales'] ?? 0)) %
                    cartonAmount),
                fontSize: isBigScreen ? 10 : 5,
                // color: Theme.of(context).colorScheme.surface,
              )
            : SizedBox(),
      ],
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
