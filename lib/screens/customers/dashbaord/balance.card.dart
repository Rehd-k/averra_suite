import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String amount;
  final String title;
  const BalanceCard({super.key, required this.amount, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 150,
          ), // Set your minimum width here
          child: Column(
            children: [
              Text(
                amount.formatToFinancial(isMoneySymbol: true),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
