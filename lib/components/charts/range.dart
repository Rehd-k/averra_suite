enum RangeLabel {
  today('Today'),
  thisWeek('This Week'),
  lastSevenDays('Last 7 Days'),
  thisMonth('This Month'),
  lastWeek('Last Week'),
  lastMonth('Last Month'),
  firstQuarter('First Quarter'),
  secondQuarter('Second Quarter'),
  thirdQuarter('Third Quarter'),
  fourthQuarter('Fourth Quarter'),
  thisYear('This Year');

  const RangeLabel(this.label);
  final String label;
}

class ChartTitle {
  final int value;
  final String label;

  const ChartTitle({
    required this.value,
    required this.label,
  });
}

({DateTime startDate, DateTime endDate, double xAxis, List<ChartTitle> titles})
    getDateRange(String label) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (label) {
    case 'Today':
      return (
        startDate: today,
        endDate: today
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1)),
        xAxis: 12,
        titles: [
          ChartTitle(value: 1, label: '12AM'),
          ChartTitle(value: 2, label: '2AM'),
          ChartTitle(value: 3, label: '4AM'),
          ChartTitle(value: 4, label: '6AM'),
          ChartTitle(value: 5, label: '8AM'),
          ChartTitle(value: 6, label: '10AM'),
          ChartTitle(value: 7, label: '12PM'),
          ChartTitle(value: 8, label: '2PM'),
          ChartTitle(value: 9, label: '4PM'),
          ChartTitle(value: 10, label: '6PM'),
          ChartTitle(value: 11, label: '8PM'),
          ChartTitle(value: 12, label: '10PM'),
        ]
      );

    case 'This Week':
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart
          .add(const Duration(days: 7))
          .subtract(const Duration(microseconds: 1));
      return (
        startDate: weekStart,
        endDate: weekEnd,
        xAxis: 7,
        titles: [
          ChartTitle(value: 1, label: 'MON'),
          ChartTitle(value: 2, label: 'TUE'),
          ChartTitle(value: 3, label: 'WED'),
          ChartTitle(value: 4, label: 'THU'),
          ChartTitle(value: 5, label: 'FRI'),
          ChartTitle(value: 6, label: 'SAT'),
          ChartTitle(value: 7, label: 'SUN'),
        ]
      );

    case 'Last 7 Days':
      return (
        startDate: today.subtract(const Duration(days: 7)),
        endDate: today
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1)),
        xAxis: 7,
        titles: [
          ChartTitle(value: 1, label: 'Day 1'),
          ChartTitle(value: 2, label: 'Day 2'),
          ChartTitle(value: 3, label: 'Day 3'),
          ChartTitle(value: 4, label: 'Day 4'),
          ChartTitle(value: 5, label: 'Day 5'),
          ChartTitle(value: 6, label: 'Day 6'),
          ChartTitle(value: 7, label: 'Today')
        ]
      );

    case 'This Month':
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1)
          .subtract(const Duration(microseconds: 1));
      return (
        startDate: monthStart,
        endDate: monthEnd,
        xAxis: 4,
        titles: [
          ChartTitle(value: 1, label: ''),
          ChartTitle(value: 2, label: 'Week 2'),
          ChartTitle(value: 3, label: 'Week 3'),
          ChartTitle(value: 4, label: 'Week 4')
        ]
      );

    case 'Last Week':
      final lastWeekStart = today.subtract(Duration(days: today.weekday + 6));
      final lastWeekEnd = lastWeekStart
          .add(const Duration(days: 7))
          .subtract(const Duration(microseconds: 1));
      return (
        startDate: lastWeekStart,
        endDate: lastWeekEnd,
        xAxis: 7,
        titles: [
          ChartTitle(value: 1, label: 'MON'),
          ChartTitle(value: 2, label: 'TUE'),
          ChartTitle(value: 3, label: 'WED'),
          ChartTitle(value: 4, label: 'THU'),
          ChartTitle(value: 5, label: 'FRI'),
          ChartTitle(value: 6, label: 'SAT'),
          ChartTitle(value: 7, label: 'SUN')
        ]
      );

    case 'Next Month':
      final nextMonthStart = DateTime(now.year, now.month + 1, 1);
      final nextMonthEnd = DateTime(now.year, now.month + 2, 1)
          .subtract(const Duration(microseconds: 1));
      return (
        startDate: nextMonthStart,
        endDate: nextMonthEnd,
        xAxis: 4,
        titles: [
          ChartTitle(value: 1, label: 'Week 1'),
          ChartTitle(value: 2, label: 'Week 2'),
          ChartTitle(value: 3, label: 'Week 3'),
          ChartTitle(value: 4, label: 'Week 4')
        ]
      );

    case 'Last Month':
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 1)
          .subtract(const Duration(microseconds: 1));
      return (
        startDate: lastMonthStart,
        endDate: lastMonthEnd,
        xAxis: 4,
        titles: [
          ChartTitle(value: 1, label: 'Week 1'),
          ChartTitle(value: 2, label: 'Week 2'),
          ChartTitle(value: 3, label: 'Week 3'),
          ChartTitle(value: 4, label: 'Week 4')
        ]
      );

    case 'First Quarter':
      return (
        startDate: DateTime(now.year, 1, 1),
        endDate:
            DateTime(now.year, 4, 1).subtract(const Duration(microseconds: 1)),
        xAxis: 3,
        titles: [
          ChartTitle(value: 1, label: 'JAN'),
          ChartTitle(value: 4, label: 'FEB'),
          ChartTitle(value: 7, label: 'MAR')
        ]
      );

    case 'Second Quarter':
      return (
        startDate: DateTime(now.year, 4, 1),
        endDate:
            DateTime(now.year, 7, 1).subtract(const Duration(microseconds: 1)),
        xAxis: 3,
        titles: [
          ChartTitle(value: 1, label: 'APR'),
          ChartTitle(value: 4, label: 'MAY'),
          ChartTitle(value: 7, label: 'JUN'),
        ]
      );

    case 'Third Quarter':
      return (
        startDate: DateTime(now.year, 7, 1),
        endDate:
            DateTime(now.year, 10, 1).subtract(const Duration(microseconds: 1)),
        xAxis: 3,
        titles: [
          ChartTitle(value: 1, label: 'JUL'),
          ChartTitle(value: 6, label: 'AUG'),
          ChartTitle(value: 12, label: 'SEP'),
        ]
      );

    case 'Fourth Quarter':
      return (
        startDate: DateTime(now.year, 10, 1),
        endDate: DateTime(now.year + 1, 1, 1)
            .subtract(const Duration(microseconds: 1)),
        xAxis: 3,
        titles: [
          ChartTitle(value: 1, label: 'OCT'),
          ChartTitle(value: 6, label: 'NOV'),
          ChartTitle(value: 12, label: 'DEC'),
        ]
      );

    case 'This Year':
      return (
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year + 1, 1, 1)
            .subtract(const Duration(microseconds: 1)),
        xAxis: 12,
        titles: [
          ChartTitle(value: 1, label: 'JAN'),
          ChartTitle(value: 2, label: 'FEB'),
          ChartTitle(value: 3, label: 'MAR'),
          ChartTitle(value: 4, label: 'APR'),
          ChartTitle(value: 5, label: 'MAY'),
          ChartTitle(value: 6, label: 'JUN'),
          ChartTitle(value: 7, label: 'JUL'),
          ChartTitle(value: 8, label: 'AUG'),
          ChartTitle(value: 9, label: 'SEP'),
          ChartTitle(value: 10, label: 'OCT'),
          ChartTitle(value: 11, label: 'NOV'),
          ChartTitle(value: 12, label: 'DEC'),
        ]
      );

    default:
      return (
        startDate: today,
        endDate: today,
        xAxis: 12,
        titles: [
          ChartTitle(value: 1, label: '6AM'),
          ChartTitle(value: 2, label: '8AM'),
          ChartTitle(value: 3, label: '10AM'),
          ChartTitle(value: 4, label: '12PM'),
          ChartTitle(value: 5, label: '2PM'),
          ChartTitle(value: 6, label: '4PM'),
          ChartTitle(value: 7, label: '6PM'),
          ChartTitle(value: 8, label: '8PM'),
          ChartTitle(value: 9, label: '10PM'),
          ChartTitle(value: 10, label: '12AM'),
          ChartTitle(value: 11, label: '2AM'),
          ChartTitle(value: 12, label: '4AM'),
        ]
      );
  }
}
