import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class FinanceCard extends StatelessWidget {
  final dynamic amount;
  final String title;
  final Icon icon;
  final bool isFinancial;
  final double fontSize;
  final Color? color;
  final bool? largeScreen;

  const FinanceCard({
    super.key,
    required this.amount,
    required this.title,
    required this.icon,
    required this.isFinancial,
    required this.fontSize,
    this.color,
    this.largeScreen,
  });

  @override
  Widget build(BuildContext context) {
    double varticalPadding;
    double horizontalPadding;
    double height;
    double textSize;
    if (largeScreen == null) {
      varticalPadding = 16.0;
      horizontalPadding = 20;
      height = 60;
      textSize = 14;
    } else if (largeScreen == true) {
      varticalPadding = 16.0;
      horizontalPadding = 20;
      height = 60;
      textSize = 14;
    } else {
      varticalPadding = 0.0;
      horizontalPadding = 5;
      height = 30;
      textSize = 10;
    }
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: varticalPadding,
          horizontal: horizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        amount.toString().formatToFinancial(
                          isMoneySymbol: isFinancial,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: textSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: icon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
