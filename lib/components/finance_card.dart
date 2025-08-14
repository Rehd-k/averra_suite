import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class FinanceCard extends StatelessWidget {
  final int amount;
  final String title;
  final Icon icon;
  final bool isFinancial;
  final double fontSize;

  const FinanceCard({
    super.key,
    required this.amount,
    required this.title,
    required this.icon,
    required this.isFinancial,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
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
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                  height: 60,
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
