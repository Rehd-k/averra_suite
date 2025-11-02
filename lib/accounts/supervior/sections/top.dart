import 'package:flutter/material.dart';

import '../../../components/finance_card.dart';

class Top extends StatelessWidget {
  final Map<String, dynamic> topValues;
  const Top({super.key, required this.topValues});

  @override
  Widget build(BuildContext context) {
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
                fontSize: cardsPerRow == 3 ? 10 : 5,
                isFinancial: true,
                amount: topValues['totalRevenue'],
                title: 'Total Daily Sales',
                icon: Icon(Icons.sell_outlined),
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                fontSize: cardsPerRow == 3 ? 10 : 5,
                isFinancial: true,
                amount: topValues["inventoryValue"],
                title: 'Total Inventory Value',
                icon: Icon(Icons.shelves),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                fontSize: cardsPerRow == 3 ? 10 : 5,
                isFinancial: false,
                amount: topValues['activeSupliers'],
                title: 'Active Suppliers',
                icon: Icon(Icons.inventory_2_outlined),
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                fontSize: cardsPerRow == 3 ? 10 : 5,
                isFinancial: true,
                amount: topValues['totalExpenses'],
                title: 'Total Expenses',
                icon: Icon(Icons.money_outlined),
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                fontSize: cardsPerRow == 3 ? 10 : 5,
                isFinancial: true,
                amount: topValues['profitOrLoss'],
                title: 'Tentative Profit Today',
                icon: Icon(Icons.money),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: InkWell(
                onTap: () {},
                child: FinanceCard(
                  fontSize: cardsPerRow == 3 ? 10 : 5,
                  isFinancial: false,
                  amount: topValues['lowStock'],
                  title: 'Low Stock/Empty Stock',
                  icon: Icon(Icons.hourglass_empty_outlined),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
