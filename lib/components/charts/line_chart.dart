import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../filter.pill.dart';
import 'range.dart';

class MainLineChart extends StatelessWidget {
  final Function(String) onRangeChanged;
  final dynamic rangeInfo;
  final String selectedRange;
  final List<FlSpot> spots;
  final List<FlSpot> redSpots;
  final bool isCurved;
  final String? heading;
  final GlobalKey? showCaseKey;

  const MainLineChart({
    super.key,
    required this.onRangeChanged,
    required this.rangeInfo,
    required this.selectedRange,
    required this.spots,
    required this.isCurved,
    required this.redSpots,
    this.heading,
    this.showCaseKey,
  });

  @override
  Widget build(BuildContext context) {
    late List<ChartTitle> bottomTitles;

    bottomTitles = rangeInfo?.titles ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                heading ?? 'Sales Visualization',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FiltersDropdown(
                  showCaseKey: showCaseKey,
                  selected: selectedRange,
                  menuList: RangeLabel.values.map<Map>((RangeLabel value) {
                    return {'title': value.label};
                  }).toList(),
                  doSelect: onRangeChanged,
                  pillIcon: Icons.today_outlined,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: rangeInfo == null
                ? Center(child: CircularProgressIndicator())
                : _LineChart(
                    bottomTitlesData: bottomTitles,
                    xAxis: rangeInfo.xAxis,
                    spots: spots,
                    redSpots: redSpots,
                    isCurved: isCurved,
                  ),
          ),
        ),
      ],
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<ChartTitle> bottomTitlesData;
  final double xAxis;
  final List<FlSpot> spots;
  final List<FlSpot> redSpots;
  final bool isCurved;

  const _LineChart({
    required this.bottomTitlesData,
    required this.xAxis,
    required this.spots,
    required this.isCurved,
    required this.redSpots,
  });

  @override
  Widget build(BuildContext context) {
    String formatNumber(double number) {
      if (number < 1000) {
        return number.toString();
      } else if (number >= 1000 && number < 1000000) {
        double value = number / 1000;
        return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}k';
      } else if (number >= 1000000) {
        double value = number / 1000000;
        return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}m';
      }
      return number
          .toString(); // In case something goes wrong, default to the original number
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: MediaQuery.of(context).size.width < 600 ? 40 : 50,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 14,
                );
                return SideTitleWidget(
                  meta: meta,
                  child: Text(formatNumber(value), style: style),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              //  withValues()
              color: Theme.of(context).colorScheme.primary.withAlpha(2),
              width: 4,
            ),
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary.withAlpha(2),
              width: 4,
            ),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            spots: spots,
          ),

          LineChartBarData(
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            spots: redSpots,
          ),
        ],
        minX: 0,
        maxX: MediaQuery.of(context).size.width < 600
            ? getMaxX(xAxis)
            : getMaxX(xAxis) + 1,
        minY: 0,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);

    final title = bottomTitlesData.firstWhere((element) {
      return element.value == value.toInt();
    }, orElse: () => ChartTitle(value: -1, label: ''));

    return SideTitleWidget(
      meta: meta,
      space: 20,
      child: Text(title.value == -1 ? '' : title.label, style: style),
    );
  }

  double getMaxX(dynamic xAxis) {
    if (xAxis < 4) {
      return 7;
    } else {
      return xAxis.toDouble();
    }
  }

  // FlBorderData get borderData => FlBorderData(
  //       show: true,
  //       border: Border(
  //         bottom: BorderSide(
  //             color: AppColors.primary.withValues(alpha: 0.2), width: 4),
  //         left: BorderSide(
  //             color: AppColors.primary.withValues(alpha: 0.2), width: 4),
  //         right: const BorderSide(color: Colors.transparent),
  //         top: const BorderSide(color: Colors.transparent),
  //       ),
  //     );
}
