import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SmallTable extends StatelessWidget {
  final List<String> columns;
  final dynamic rows;
  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  const SmallTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns:
              columns.map((column) => DataColumn(label: Text(column))).toList(),
          rows: [
            ...rows.map((res) {
              // Map<String, dynamic> row = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(res['name'].toString())),
                  DataCell(Text(res['lastPurchaseDate'] != null
                      ? formatDate(res['lastPurchaseDate'].toString())
                      : 'No Purchase Yet')),
                  DataCell(Text(res['lastPurchaseAmount'] != null
                      ? res['lastPurchaseAmount'].toString()
                      : '0')),
                  DataCell(Text(res['total_spent'].toString()))
                ],
              );
            })
          ],
          border: TableBorder.all(style: BorderStyle.none),
        ),
      ),
    );
  }
}
