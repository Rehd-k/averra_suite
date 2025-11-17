import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/charts/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

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
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  bool isAlreadyShows = true;
  dynamic rangeInfo;
  String selectedRange = 'Today';
  List<FlSpot> spots = [];
  List<FlSpot> expensesSport = [];
  bool loading = true;
  bool loadingTable = true;
  bool loadingCharts = true;
  late Map cardsData = {'revenue': 0, 'expenses': 0};
  void handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedRange = rangeLabel;
    });
    getData(rangeLabel);
  }

  Future getData(dynamic dateRange) async {
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

  Future getCardsData(dynamic range) async {
    return await Future.wait([
      apiService.get(
        'sales/all-sells-data?startDate=${range.startDate}&endDate=${range.endDate}',
      ),
      apiService.get(
        'otherIncome/otherIncomeTotal?startDate=${range.startDate}&endDate=${range.endDate}',
      ),
      apiService.get(
        'expense/total?startDate=${range.startDate}&endDate=${range.endDate}',
      ),
    ]);
  }

  Future getChartData(dynamic range) {
    return apiService.get('analytics/get-sales-chart?filter=$range');
  }

  Future getExpensesChartData(dynamic range) {
    return apiService.get('expense/chart?filter=$range');
  }

  Future saveUserShowCaseState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List learnt = prefs.getStringList('learnt') ?? [];
    if (!learnt.contains('accountant_dasboard')) {
      await prefs.setStringList('learnt', <String>[
        ...learnt,
        'accountant_dasboard',
      ]);
    }
  }

  Future checkIfDone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List learnt = prefs.getStringList('learnt') ?? [];

    setState(() {
      isAlreadyShows = learnt.contains('accountant_dasboard');
    });
  }

  @override
  void initState() {
    checkIfDone();
    handleRangeChanged('Today');
    ShowcaseView.register(
      onFinish: () => saveUserShowCaseState(),
      onDismiss: (dismissedAt) => saveUserShowCaseState(),
      // enableShowcase: showcaseEnabled,
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

    if (!isAlreadyShows) {
      // Start showcase after the screen is rendered to ensure internal initialization.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowcaseView.get().startShowCase([
          _one,
          _two,
          _three,
          _four,
          _five,
        ]),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    // Unregister the showcase view
    ShowcaseView.get().unregister();
    super.dispose();
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
                    child: Showcase(
                      tooltipBackgroundColor: Theme.of(context).cardColor,
                      showArrow: false,
                      key: _one,
                      title: 'Total Revenue',
                      titleTextStyle: TextStyle(
                        fontSize: isBigScreen ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      descTextStyle: TextStyle(fontSize: isBigScreen ? 12 : 10),
                      description: 'This Shows All The Revenue Gotten That Day',
                      child: FinanceCard(
                        fontSize: isBigScreen ? 10 : 5,
                        isFinancial: true,
                        amount: cardsData['revenue'],
                        title: 'Total Revenue',
                        icon: Icon(Icons.account_tree_outlined),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: Showcase(
                      key: _two,
                      tooltipBackgroundColor: Theme.of(context).cardColor,
                      title: 'Total Expenses',
                      description:
                          'This Shows All The Expenses Gotten That Day',
                      titleTextStyle: TextStyle(
                        fontSize: isBigScreen ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      descTextStyle: TextStyle(fontSize: isBigScreen ? 12 : 10),
                      child: FinanceCard(
                        fontSize: isBigScreen ? 10 : 5,
                        isFinancial: true,
                        amount: cardsData['expenses'],
                        title: 'Total Expenses',
                        icon: Icon(Icons.receipt_long_outlined),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: Showcase(
                      key: _three,
                      tooltipBackgroundColor: Theme.of(context).cardColor,
                      titleTextStyle: TextStyle(
                        fontSize: isBigScreen ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      descTextStyle: TextStyle(fontSize: isBigScreen ? 12 : 10),
                      title: 'Total Expenses',
                      description:
                          'This Shows All The Expenses Gotten That Day',
                      child: FinanceCard(
                        fontSize: isBigScreen ? 10 : 5,
                        isFinancial: false,
                        amount: cardsData['revenue'] - cardsData['expenses'],
                        title: 'Difference',
                        icon: Icon(Icons.trending_up_outlined),
                      ),
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
              child: Showcase(
                key: _four,
                title: 'Revenue/Expenses Visualization',
                description: 'It Shows The Revenue And Expenses Over Time',
                tooltipBackgroundColor: Theme.of(context).cardColor,
                titleTextStyle: TextStyle(
                  fontSize: isBigScreen ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
                descTextStyle: TextStyle(fontSize: isBigScreen ? 12 : 10),
                child: MainLineChart(
                  showCaseKey: _five,
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
          ),
        ],
      ),
    );
  }
}
