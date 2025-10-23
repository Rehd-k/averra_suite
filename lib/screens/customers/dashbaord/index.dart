import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../components/tables/gen_big_table/big_table.dart';
import '../../../components/tables/gen_big_table/big_table_source.dart';
import '../../../service/api.service.dart';
import 'balance.card.dart';
import 'collumn.definition.dart';
import 'costumer.info.dart';

@RoutePage()
class CustomerDetails extends StatefulWidget {
  final Map customer;
  const CustomerDetails({super.key, required this.customer});

  @override
  IndexState createState() => IndexState();
}

class IndexState extends State<CustomerDetails> {
  final List<ColumnDefinition> _columnDefinitions = customerColumnDefinitionMaps
      .map((map) => ColumnDefinition.fromMap(map))
      .toList();
  final ApiService apiService = ApiService();
  final JsonEncoder jsonEncoder = JsonEncoder();
  String searchItem = '';
  String searchQuery = '';
  String initialSort = 'dueDate';
  late Map balanceData;
  bool isLoading = true;

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
      'invoice/customer?filter={"customer" : "${widget.customer['_id']}","invoiceNumber" : {"\$regex" : "${searchQuery.toLowerCase()}"}}&skip=$offset&limit=$limit&sort=$sorting',
    );

    var {'result': result, 'totalDocuments': totalDocuments} = dbproducts.data;
    // --- Sorting Logic (Mock) ---
    List<TableDataModel> data = List.from(result); // Work on a copy

    // --- Pagination Logic (Mock) ---
    final totalRows = totalDocuments;
    final paginatedData = data.toList();
    return {
      'rows': paginatedData, // Return the list of maps
      'totalRows': totalRows,
    };
  }

  Future<void> getDashBaordData() async {
    var dbproducts = await apiService.get(
      'invoice/customer/dashboard?filter={"customer" : "${widget.customer['_id']}"}',
    );
    setState(() {
      balanceData = dbproducts.data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDashBaordData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Row(
          children: [
            isBigScreen
                ? Expanded(
                    flex: isBigScreen ? 2 : 0,
                    child: CostumerInfo(details: widget.customer),
                  )
                : SizedBox.shrink(),
            Expanded(
              flex: isBigScreen ? 5 : 1,
              child: Column(
                children: [
                  !isLoading
                      ? SizedBox(
                          child: !isBigScreen
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        BalanceCard(
                                          title: 'Total invoice amount',
                                          amount:
                                              balanceData['totalAmountAllValue']
                                                  .toString(),
                                        ),
                                        BalanceCard(
                                          title: 'Total paid',
                                          amount:
                                              balanceData['totalAmountPaidValue']
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        BalanceCard(
                                          title: 'Total Due',
                                          amount:
                                              balanceData['totalAmountDueTodayValue']
                                                  .toString(),
                                        ),
                                        BalanceCard(
                                          title: 'Total Debt',
                                          amount:
                                              balanceData['totalAmountPendingValue']
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    BalanceCard(
                                      title: 'Total invoice amount',
                                      amount: balanceData['totalAmountAllValue']
                                          .toString(),
                                    ),
                                    BalanceCard(
                                      title: 'Total paid',
                                      amount:
                                          balanceData['totalAmountPaidValue']
                                              .toString(),
                                    ),
                                    BalanceCard(
                                      title: 'Total Due',
                                      amount:
                                          balanceData['totalAmountDueTodayValue']
                                              .toString(),
                                    ),
                                    BalanceCard(
                                      title: 'Total Debt',
                                      amount:
                                          balanceData['totalAmountPendingValue']
                                              .toString(),
                                    ),
                                  ],
                                ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ],
                        ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: isBigScreen ? 500 : 400,
                          child: ReusableAsyncPaginatedDataTable(
                            showCheckboxColumn: false,
                            columnDefinitions:
                                _columnDefinitions, // Pass definitions
                            fetchDataCallback: _fetchServerData,
                            onSelectionChanged: (selected) {},
                            header: const Text(''),
                            initialSortField: initialSort,
                            initialSortAscending: true,
                            rowsPerPage: 15,
                            availableRowsPerPage: const [10, 15, 25, 50],
                            fixedLeftColumns: 0,
                            minWidth: 500,
                            empty: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            border: TableBorder.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                            columnSpacing: 30,
                            dataRowHeight: 50,
                            headingRowHeight: 60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
