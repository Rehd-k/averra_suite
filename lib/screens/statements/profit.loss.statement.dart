import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../service/api.service.dart';
import '../../service/date_range_helper.dart';

@RoutePage()
class ProfitLossStatementScreen extends StatefulWidget {
  const ProfitLossStatementScreen({super.key});

  @override
  ProfitLossStatementState createState() => ProfitLossStatementState();
}

class ProfitLossStatementState extends State<ProfitLossStatementScreen> {
  ApiService apiService = ApiService();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  late Map entries = {};
  bool loading = true;

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
        entries = {};
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
        entries = {};
      });
    }
    getInitailData();
  }

  void handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
    });
    getInitailData();
  }

  Future<void> getSalesData() async {
    var salesData = await apiService.get(
      'sales/all-sells-data?startDate=$startDate&endDate=$endDate',
    );
    setState(() {
      entries = {...entries, ...salesData.data};
    });
  }

  Future<void> getStockData() async {
    var purchasesData = await apiService.get(
      'purchases/getTotals?startDate=$startDate&endDate=$endDate',
    );
    setState(() {
      entries = {...entries, ...purchasesData.data};
    });
  }

  Future<void> getExensesData() async {
    var expensesData = await apiService.get(
      'expense/total-categories?startDate=$startDate&endDate=$endDate',
    );
    setState(() {
      entries = {...entries, 'expenses': expensesData.data};
      loading = false;
    });
  }

  Future<void> getInitailData() async {
    await Future.wait([getExensesData()]);
  }

  // getSalesData(), getStockData(),
  @override
  void initState() {
    getInitailData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: DateRangeHolder(
          fromDate: startDate,
          toDate: endDate,
          handleRangeChange: handleRangeChange,
          handleDateReset: handleDateReset,
        ),
      ),
      body: Center(
        child: Text('Contact Us To Get You Accounting Module Connected'),
      ),

      // Padding(
      //     padding: const EdgeInsets.all(20.0),
      //     child: Row(
      //       children: [
      //         Expanded(
      //           child: Column(
      //             children: [
      //               SingleChildScrollView(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       'Revenue',
      //                       style: TextStyle(fontWeight: FontWeight.bold),
      //                     ),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Sales Revenue'),
      //                         Text(
      //                           (entries['totalSales'] +
      //                                   entries['totalReturnsInward'])
      //                               .toString()
      //                               .formatToFinancial(isMoneySymbol: true),
      //                         ),
      //                       ],
      //                     ),

      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Returns'),
      //                         Text(
      //                           "(${entries['totalReturnsInward'].toString().formatToFinancial(isMoneySymbol: true)})",
      //                         ),
      //                       ],
      //                     ),
      //                     Divider(),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Net Sales'),
      //                         Text(
      //                           entries['totalSales']
      //                               .toString()
      //                               .formatToFinancial(isMoneySymbol: true),
      //                         ),
      //                       ],
      //                     ),
      //                     SizedBox(height: 20),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text(
      //                           'Inventory - ${formatBackendTime(startDate.toString())}',
      //                         ),
      //                         Text('loading'),
      //                       ],
      //                     ),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Pruchases'),
      //                         Text(
      //                           entries['totalPurchases']
      //                               .toString()
      //                               .formatToFinancial(isMoneySymbol: true),
      //                         ),
      //                       ],
      //                     ),

      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Returns Outward'),
      //                         Text(
      //                           " (${entries['totalReturnsOutward'].toString().formatToFinancial(isMoneySymbol: true)})",
      //                         ),
      //                       ],
      //                     ),
      //                     SizedBox(height: 10),

      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text(''),
      //                         Text(
      //                           (entries['totalPurchases'] -
      //                                   entries['totalReturnsOutward'])
      //                               .toString()
      //                               .formatToFinancial(isMoneySymbol: true),
      //                         ),
      //                       ],
      //                     ),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text(
      //                           'Inventory - ${formatBackendTime(endDate.toString())}',
      //                         ),
      //                         Text("(loading...)"),
      //                       ],
      //                     ),
      //                     Divider(),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Gross Profit'),
      //                         Text("(loading...)"),
      //                       ],
      //                     ),
      //                     SizedBox(height: 10),
      //                     Row(
      //                       mainAxisAlignment:
      //                           MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text('Discount Received'),
      //                         Text(
      //                           entries['totalDiscountReceived']
      //                               .toString()
      //                               .formatToFinancial(isMoneySymbol: true),
      //                         ),
      //                       ],
      //                     ),

      //                     SizedBox(height: 10),
      //                     Text('Expenses'),
      //                     SizedBox(height: 10),
      //                     SizedBox(
      //                       width: MediaQuery.of(context).size.width * 0.3,
      //                       child: Column(
      //                         children: (entries['expenses'] as List? ?? [])
      //                             .map<Widget>(
      //                               (res) => Row(
      //                                 mainAxisAlignment:
      //                                     MainAxisAlignment.spaceBetween,
      //                                 children: [
      //                                   Text(res['category'] ?? ''),
      //                                   Text(
      //                                     (res['totalAmount'] ?? 0)
      //                                         .toString()
      //                                         .formatToFinancial(
      //                                           isMoneySymbol: true,
      //                                         ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             )
      //                             .toList(),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         Expanded(child: SizedBox()),
      //       ],
      //     ),
      //   ),
    );
  }
}
