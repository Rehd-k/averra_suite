import 'dart:convert';

import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../components/tables/gen_big_table/big_table.dart';
import '../../components/tables/gen_big_table/big_table_source.dart';
import 'table_collums.dart';

class OrderHistory extends StatefulWidget {
  final String supplier;
  const OrderHistory({super.key, required this.supplier});

  @override
  OrderHistoryState createState() => OrderHistoryState();
}

class OrderHistoryState extends State<OrderHistory> {
  final apiService = ApiService();
  final jsonEncoder = JsonEncoder();
  late List<ColumnDefinition> _columnDefinitions;
  String supplier = '';
  String? searchFeild = 'createdAt';
  bool loadingTable = true;
  String? productId;
  String? status;
  DateTime? fromDate = DateTime(2010, 1, 1);
  DateTime? toDate = DateTime.now();
  String initialSort = 'createdAt';
  @override
  void initState() {
    supplier = widget.supplier;
    _columnDefinitions = columnDefs
        .map((map) => ColumnDefinition.fromMap(map))
        .toList();

    super.initState();
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
      'purchases?filter={"supplier":"$supplier", "$searchFeild" : "", "productId":"$productId", "status" :  "${status?.toLowerCase()}"}&sort=$sorting&startDate=$fromDate&endDate=$toDate&skip=$offset&limit=$limit',
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return SizedBox(
      height: 600,
      child: ReusableAsyncPaginatedDataTable(
        columnDefinitions: _columnDefinitions, // Pass definitions
        fetchDataCallback: _fetchServerData,
        onSelectionChanged: (selected) {},
        header: const Text('Purchases', style: TextStyle(fontSize: 10)),
        initialSortField: initialSort,
        initialSortAscending: true,
        rowsPerPage: 15,
        availableRowsPerPage: const [10, 15, 25, 50],
        showCheckboxColumn: true,
        fixedLeftColumns: smallScreen ? 1 : 2, // Fix the 'Title' column
        minWidth: 2500, // Increase minWidth for more columns
        empty: const Center(child: CircularProgressIndicator()),
        border: TableBorder.all(color: Colors.grey.shade100, width: 1),
        columnSpacing: 30,
        dataRowHeight: 50,
        headingRowHeight: 60,
        doDamagedGoods: (rowData) {
          // handleDamagedGoodsClicked(rowData);
        },
        doReturnGoods: (rowData) {
          // handleReturnGoodsClicked(rowData);
        },
      ),
    );
  }
}
