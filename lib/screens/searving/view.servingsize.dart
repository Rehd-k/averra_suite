import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../helpers/financial_string_formart.dart';

class ViewServingsize extends StatelessWidget {
  final List filteredServingsize;
  final TextEditingController searchController;
  final bool isLoading;

  final String sortBy;
  final bool ascending;
  final Function filterServingsize;
  final Function getFilteredAndSortedRows;
  final Function deleteServingsize;
  const ViewServingsize({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.sortBy,
    required this.ascending,
    required this.getFilteredAndSortedRows,
    required this.deleteServingsize,
    required this.filteredServingsize,
    required this.filterServingsize,
  });

  @override
  Widget build(BuildContext context) {
    String formatDate(String isoDate) {
      final DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Short Hand')),
          DataColumn(label: Text('Initiator')),
          DataColumn(label: Text('Created At')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredServingsize.map<DataRow>((department) {
          return DataRow(
            cells: [
              DataCell(Text(capitalizeFirstLetter(department['title'] ?? ''))),
              DataCell(Text(department['shortHand'] ?? '')),
              DataCell(Text(department['initiator'] ?? '')),
              DataCell(Text(formatDate(department['createdAt']))),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_attributes),
                      onPressed: () {
                        deleteServingsize(department['_id']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_forever_outlined),
                      onPressed: () {
                        deleteServingsize(department['_id']);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
