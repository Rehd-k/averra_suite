import 'package:flutter/material.dart';

import '../../../../components/finance_card.dart';

class Inventorysummery extends StatelessWidget {
  final Map data;
  const Inventorysummery({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: isBigScreen ? 450 : 1100),
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
                  'Inventory Summary',
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
              height: isBigScreen ? 400 : 297,
              child: grids(isBigScreen, context),
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
          cardsPerRow = 4; // large screen
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
                title: 'No. of Products',
                icon: Icon(Icons.payments_outlined),
                isFinancial: false,
                amount: data['totalProducts'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Total Stock',
                icon: Icon(Icons.payments_outlined),
                isFinancial: false,
                amount: data['totalQuantity'].toString(),
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Total Stock Value',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['totalValue'].toString(),
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Low Stock',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: data['lowStockCount'].toString(),
                fontSize: isBigScreen ? 10 : 5,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Expired/Expiring',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: data['expiredProducts'] == null
                    ? 'No Data'
                    : data['expiredProducts'].toString(),
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Fast-Moving',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: data['fastestMovingProduct'] != null
                    ? data['fastestMovingProduct']['title']
                    : '0',
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: ' Slow-Moving ',
                icon: Icon(Icons.trending_up),
                isFinancial: false,
                amount: data['slowestMovingProduct'] != null
                    ? data['slowestMovingProduct']['title']
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
