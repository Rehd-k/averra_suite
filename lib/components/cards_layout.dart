import 'package:flutter/material.dart';

import 'finance_card.dart';

class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
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
                fontSize: isBigScreen ? 10 : 5,
                isFinancial: true,
                amount: 546864536,
                title: 'Total Sales',
                icon: Icon(Icons.money),
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                fontSize: isBigScreen ? 10 : 5,
                isFinancial: true,
                amount: 546864536,
                title: 'Total Procurment',
                icon: Icon(Icons.money),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                fontSize: isBigScreen ? 10 : 5,
                isFinancial: false,
                amount: 58,
                title: 'Total Staff',
                icon: Icon(Icons.money),
              ),
            ),

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
              child: FinanceCard(
                fontSize: isBigScreen ? 10 : 5,
                isFinancial: true,
                amount: 546864536,
                title: 'Total Drinks',
                icon: Icon(Icons.money),
              ),
            ),
          ],
        );
      },
    );
  }
}
