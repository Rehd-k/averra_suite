import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Barchart extends StatelessWidget {
  final List<BarChartGroupData> cashData;
  final String period;
  final List weekDays;

  const Barchart({
    super.key,
    required this.cashData,
    required this.period,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Cash In vs Cash Out for $period'),
        SizedBox(
          height: 700,
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 5),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, titleMeta) {
                      int index = value.toInt();
                      if (index >= 0 && index < weekDays.length) {
                        return Text(
                          weekDays[index],
                        ); // Map x-axis values to day names
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                border: Border(
                  top: BorderSide(width: 0.01),
                  left: BorderSide(),
                  right: BorderSide(width: 0.01),
                  bottom: BorderSide(),
                ),
              ),
              barGroups: cashData,
            ),
          ),
        ),
      ],
    );
  }
}
