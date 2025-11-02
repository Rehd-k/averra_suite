import 'package:flutter/material.dart';

import '../../../../components/finance_card.dart';
import '../../../../components/tables/smalltable/smalltable.dart';

class CustomerInsight extends StatelessWidget {
  final Map data;
  const CustomerInsight({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 400),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Align(
              alignment: isBigScreen ? Alignment.centerLeft : Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(isBigScreen ? 8.0 : 4.0),
                child: Text(
                  'Customer Insights',
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
              padding: EdgeInsets.symmetric(horizontal: 14),
              height: isBigScreen ? 175 : 70,
              child: grids(isBigScreen, context),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 400),
                child: isBigScreen
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Top Customers',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  SmallTable(
                                    columns: [
                                      'Name',
                                      'Last Purchase Date',
                                      'Amount Spent',
                                      'Total Spent',
                                    ],
                                    rows: data['mostFrequentCustomer'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'New Customers',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  SmallTable(
                                    columns: [
                                      'Name',
                                      'Last Purchase Date',
                                      'Amount Spent',
                                      'Total Spent',
                                    ],
                                    rows: data['newestCustomers'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Top Customers',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                SmallTable(
                                  columns: [
                                    'Name',
                                    'Last Purchase Date',
                                    'Amount Spent',
                                    'Total Spent',
                                  ],
                                  rows: data['newestCustomers'],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'New Customers',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                SmallTable(
                                  columns: [
                                    'Name',
                                    'Last Purchase Date',
                                    'Amount Spent',
                                    'Total Spent',
                                  ],
                                  rows: data['mostFrequentCustomer'],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
          cardsPerRow = 2; // large screen
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
                title: 'Total Customers',
                icon: Icon(Icons.payments_outlined),
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
                amount: data['totalCustomers'].isNotEmpty
                    ? data['totalCustomers'][0]['totalCustomers'].toString()
                    : '0',
                isFinancial: false,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Customer Retention',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: data['retentionCurrentMonth'].isNotEmpty
                    ? data['retentionCurrentMonth'][0]['customerRetention']
                          .toString()
                    : '0',
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
