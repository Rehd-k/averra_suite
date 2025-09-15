import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../components/charts/line_chart.dart';
import '../../components/charts/range.dart';
import '../../components/finance_card.dart';
import '../../components/info.card.dart';

@RoutePage()
class ExpensesDashbaord extends StatefulWidget {
  const ExpensesDashbaord({super.key});

  @override
  ExpensesDashbaordState createState() => ExpensesDashbaordState();
}

class ExpensesDashbaordState extends State<ExpensesDashbaord> {
  final ApiService apiService = ApiService();
  dynamic rangeInfo;
  String selectedRange = 'Today';
  List<FlSpot> spots = [];
  bool loading = true;
  bool loadingTable = true;
  bool loadingCharts = true;
  // DateTime? _fromDate = DateTime(2010, 1, 1);
  // DateTime? _toDate = DateTime.now();

  handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedRange = rangeLabel;
    });
    getChartData(selectedRange);
  }

  Future getChartData(dateRange) async {
    final range = getDateRange(dateRange);
    final response = await apiService.get(
      'sales/getchart/"productId"?filter={"sorter":"$dateRange"}&startDate=${range.startDate}&endDate=${range.endDate}',
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(isBigScreen ? 40.0 : 20),
                child: Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Determine how many cards per row based on screen width
              double maxWidth = constraints.maxWidth;
              int cardsPerRow;

              if (maxWidth >= 900) {
                cardsPerRow = 3; // large screen
              } else if (maxWidth >= 600) {
                cardsPerRow = 2; // medium screen
              } else {
                cardsPerRow = 1; // small screen
              }

              // Card width calculation with spacing
              double spacing = 16.0;
              double cardWidth =
                  (maxWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: FinanceCard(
                      fontSize: isBigScreen ? 10 : 5,
                      isFinancial: true,
                      amount: 546864536,
                      title: 'Total Expenses',
                      icon: Icon(Icons.money),
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: InfoCard(
                      fontSize: isBigScreen ? 10 : 5,
                      isFinancial: true,
                      info: 'Dining',
                      title: 'Highest Spending Category',
                      icon: Icon(Icons.money),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: FinanceCard(
                      fontSize: isBigScreen ? 10 : 5,
                      isFinancial: false,
                      amount: 58,
                      title: 'Number Of Transactions',
                      icon: Icon(Icons.money),
                    ),
                  ),
                ],
              );
            },
          ),

          Container(
            height: isBigScreen ? 600 : 900,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: isBigScreen
                ? Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Card(
                          elevation: 3,
                          color: Theme.of(context).colorScheme.surface,
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
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.only(
                                  left: 20,
                                  top: 20,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Recent Transaction',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    // final product = _updatedProducts[index];
                                    return ListTile(
                                      leading: Icon(
                                        Icons.punch_clock,
                                        size: 10,
                                      ),
                                      title: Text(
                                        "product['title']",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      subtitle: Text(
                                        'Quantity: ${"product['quantity']"}',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      trailing: Text(
                                        '30090002'.formatToFinancial(
                                          isMoneySymbol: true,
                                        ),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 3,
                          color: Theme.of(context).colorScheme.surface,
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
                      Expanded(
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.only(
                                  left: 20,
                                  top: 20,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Recent Transaction',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    // final product = _updatedProducts[index];
                                    return ListTile(
                                      leading: Icon(
                                        Icons.punch_clock,
                                        size: 10,
                                      ),
                                      title: Text(
                                        "product['title']",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      subtitle: Text(
                                        'Quantity: ${"product['quantity']"}',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      trailing: Text(
                                        '30090002'.formatToFinancial(
                                          isMoneySymbol: true,
                                        ),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
