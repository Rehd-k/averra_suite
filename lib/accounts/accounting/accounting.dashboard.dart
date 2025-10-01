import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/charts/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../components/charts/range.dart';
import '../../components/finance_card.dart';
import '../../service/api.service.dart';

@RoutePage()
class AccountingDashboardScreen extends StatefulWidget {
  const AccountingDashboardScreen({super.key});

  @override
  AccountingDashboardState createState() => AccountingDashboardState();
}

class AccountingDashboardState extends State<AccountingDashboardScreen> {
  final ApiService apiService = ApiService();
  dynamic rangeInfo;
  String selectedRange = 'Today';
  List<FlSpot> spots = [];
  List<FlSpot> expensesSport = [];
  bool loading = true;
  bool loadingTable = true;
  bool loadingCharts = true;
  late Map cardsData = {'revenue': 0, 'expenses': 0};
  handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedRange = rangeLabel;
    });
    getData(rangeLabel);
  }

  Future getData(dateRange) async {
    final range = getDateRange(dateRange);

    var futures = await Future.wait([
      getCardsData(range),
      getChartData(dateRange),
      getExpensesChartData(dateRange),
    ]);
    setState(() {
      spots.clear();
      cardsData = {
        'revenue': futures[0][0].data['totalSales'],
        'expenses': futures[0][2].data[0]['approvedInRange'],
      };
      futures[1].data.forEach((item) {
        spots.add(
          FlSpot(
            (item['for'] as num).toDouble(),
            (item['totalSales'] as num).toDouble(),
          ),
        );
      });

      futures[2].data.forEach((item) {
        expensesSport.add(
          FlSpot(
            (item['for'] as num).toDouble(),
            (item['totalExpenses'] as num).toDouble(),
          ),
        );
      });
      rangeInfo = range;
      loadingCharts = false;
      loadingTable = false;
    });
  }

  Future getCardsData(range) async {
    return await Future.wait([
      apiService.get(
        'sales/all-sells-data?startDate=${range.startDate}&endDate=${range.endDate}',
      ),
      apiService.get(
        'income/otherIncomeTotal?startDate=${range.startDate}&endDate=${range.endDate}',
      ),
      apiService.get(
        'expense/total?startDate=${range.startDate}&endDate=${range.endDate}',
      ),
    ]);
  }

  Future getChartData(range) {
    return apiService.get('analytics/get-sales-chart?filter=$range');
  }

  Future getExpensesChartData(range) {
    return apiService.get('expense/chart?filter=$range');
  }

  @override
  void initState() {
    handleRangeChanged('Today');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return SingleChildScrollView(
      child: Column(
        children: [
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
                      amount: cardsData['revenue'],
                      title: 'Total Revenue',
                      icon: Icon(Icons.account_tree_outlined),
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: FinanceCard(
                      fontSize: isBigScreen ? 10 : 5,
                      isFinancial: true,
                      amount: cardsData['expenses'],
                      title: 'Total Expenses',
                      icon: Icon(Icons.receipt_long_outlined),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: FinanceCard(
                      fontSize: isBigScreen ? 10 : 5,
                      isFinancial: false,
                      amount: cardsData['revenue'] - cardsData['expenses'],
                      title: 'Difference',
                      icon: Icon(Icons.trending_up_outlined),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 10),
          Container(
            height: isBigScreen ? 600 : 900,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Card(
              elevation: 3,
              color: Theme.of(context).colorScheme.surface,
              child: MainLineChart(
                onRangeChanged: handleRangeChanged,
                rangeInfo: rangeInfo,
                selectedRange: selectedRange,
                spots: spots,
                redSpots: expensesSport,
                isCurved: true,
                heading: 'Revenue Visualization',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
