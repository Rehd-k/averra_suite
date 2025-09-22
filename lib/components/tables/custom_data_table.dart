import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List data;
  final List<DataCell> Function(dynamic row) cellBuilder;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Card(
      margin: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(cardColor),
          columns: columns,
          rows: data.map((row) => DataRow(cells: cellBuilder(row))).toList(),
        ),
      ),
    );
  }
}
