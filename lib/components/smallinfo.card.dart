import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class SmallinfoCard extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subString;
  final String description;
  final bool status;
  final num amount;
  final bool isMoney;
  const SmallinfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subString,
    required this.description,
    required this.status,
    required this.amount,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    double varticalPadding;
    double width = MediaQuery.sizeOf(context).width;
    bool largeScreen = width >= 1200;
    if (largeScreen == true) {
      varticalPadding = 20.0;
    } else {
      varticalPadding = 20.0;
    }
    return Card(
      shadowColor: status ? Colors.greenAccent : Colors.redAccent,
      child: Padding(
        padding: EdgeInsets.only(
          top: varticalPadding,
          bottom: varticalPadding,
          left: 0,
          right: 5,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: status ? Icon(Icons.check_circle) : Icon(Icons.more_horiz),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(subString, style: TextStyle(fontSize: 10)),
                  SizedBox(height: 5),
                  Text(description, style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    amount.toString().formatToFinancial(isMoneySymbol: isMoney),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
