import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../barchart.dart';

class Financialsummary extends StatefulWidget {
  final List salesData;
  const Financialsummary({super.key, required this.salesData});

  @override
  FinancialsummaryState createState() => FinancialsummaryState();
}

class FinancialsummaryState extends State<Financialsummary> {
  List<BarChartGroupData> barGroups = [];
  List<String> weekDays = [];
  @override
  void initState() {
    // Define the days of the week in the correct order
    weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Create a map of day to totalSales from salesData, defaulting missing days to 0
    Map<String, double> salesMap = {
      for (var day in weekDays) day: 0.0,
    }; // Initialize to 0
    Map<String, double> expensesMap = {for (var day in weekDays) day: 0.0};

    for (var entry in widget.salesData) {
      salesMap[entry['day']] = entry['totalSales'].toDouble();
      expensesMap[entry['day']] = entry['expenses'].toDouble();
    }

    // Create a list of BarChartGroupData with toY matching totalSales for each day
    barGroups = weekDays.map((day) {
      return BarChartGroupData(
        x: weekDays.indexOf(day),
        barRods: [
          BarChartRodData(
            toY: salesMap[day] as double, // Use the totalSales from the map
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: salesMap[day]! > 0
                  ? [Colors.greenAccent, Colors.green]
                  : [Colors.grey, Colors.black], // Grey gradient for 0 sales
            ),
          ),
          BarChartRodData(
            toY: expensesMap[day] as double,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.redAccent, Colors.red],
            ),
          ),
        ],
      );
    }).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 400),
      child: Column(
        children: [
          Barchart(
            cashData: barGroups,
            period: 'this week',
            weekDays: weekDays,
          ),
        ],
      ),
    );
  }
}
