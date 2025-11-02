import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../components/charts/line_chart.dart';
import '../../../../components/charts/range.dart';
import '../../../../components/finance_card.dart';
import '../../../../service/api.service.dart';

class Salesoverview extends StatefulWidget {
  final num totalSales;
  final Map topSellingProducts;

  const Salesoverview({
    super.key,
    required this.totalSales,
    required this.topSellingProducts,
  });

  @override
  SalesoverviewState createState() => SalesoverviewState();
}

class SalesoverviewState extends State<Salesoverview> {
  dynamic rangeInfo;
  String selectedRange = 'Today';
  final apiService = ApiService();
  List<FlSpot> spots = [];

  @override
  void initState() {
    getChartData('Today');
    super.initState();
  }

  void handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedRange = rangeLabel;
    });
    getChartData(selectedRange);
  }

  Future getChartData(dynamic dateRange) async {
    final range = getDateRange(dateRange);
    var data = await apiService.get(
      'analytics/get-sales-chart?filter=$dateRange',
    );

    setState(() {
      spots.clear();
      data.data.forEach((item) {
        spots.add(
          FlSpot(
            (item['for'] as num).toDouble(),
            (item['totalSales'] as num).toDouble(),
          ),
        );
      });
      rangeInfo = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    num width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 400),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        height: isBigScreen ? 1000 : 700,
        child: Column(
          children: [
            Align(
              alignment: isBigScreen ? Alignment.centerLeft : Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(isBigScreen ? 8.0 : 4.0),
                child: Text(
                  'Sales Overview',
                  style: TextStyle(
                    fontSize: isBigScreen ? 30 : 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isBigScreen ? 14 : 0),
              height: isBigScreen ? 350 : 175,
              child: grids(isBigScreen, context),
            ),
            SizedBox(height: 1),
            Divider(color: Theme.of(context).colorScheme.surface),
            SizedBox(height: 5),
            Expanded(
              child: MainLineChart(
                onRangeChanged: handleRangeChanged,
                rangeInfo: rangeInfo,
                selectedRange: selectedRange,
                spots: spots,
                isCurved: true,
                redSpots: [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LayoutBuilder grids(bool isBigScreen, BuildContext context) {
    return LayoutBuilder(
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
                title: 'Today\'s Total Sales',
                icon: Icon(Icons.payments_outlined),
                isFinancial: false,
                amount: widget.totalSales,
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Top-Selling Products \n Today',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: widget.topSellingProducts['topSellingToday'].isNotEmpty
                    ? widget.topSellingProducts['topSellingToday'][0]['title']
                    : 'No Sale Today',
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Top-Selling Products \n Weekly',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: widget.topSellingProducts['topSellingWeekly'].isNotEmpty
                    ? widget.topSellingProducts['topSellingWeekly'][0]['title']
                    : 'No Sale This Week',
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Top-Selling Products \n Monthly',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount:
                    widget.topSellingProducts['topSellingMonthly'].isNotEmpty
                    ? widget.topSellingProducts['topSellingMonthly'][0]['title']
                    : 'No Sale This Month',
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        );
      },
    );
  }
}
