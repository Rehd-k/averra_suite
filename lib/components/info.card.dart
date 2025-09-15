import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String info;
  final String title;
  final Icon icon;
  final bool isFinancial;
  final double fontSize;
  final Color? color;
  final bool? largeScreen;

  const InfoCard({
    super.key,
    required this.info,
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
                        info,
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
