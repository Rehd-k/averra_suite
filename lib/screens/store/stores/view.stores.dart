import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../helpers/financial_string_formart.dart';

class ViewStores extends StatelessWidget {
  final List filteredStores;
  final TextEditingController searchController;
  final bool isLoading;

  final String sortBy;
  final bool ascending;
  final Function filterStore;
  final Function getFilteredAndSortedRows;
  final Function deleteStore;
  const ViewStores({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.sortBy,
    required this.ascending,
    required this.getFilteredAndSortedRows,
    required this.deleteStore,
    required this.filteredStores,
    required this.filterStore,
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
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Initiator')),
          DataColumn(label: Text('Created At')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredStores.map<DataRow>((store) {
          return DataRow(
            cells: [
              DataCell(Text(capitalizeFirstLetter(store['title'] ?? ''))),
              DataCell(Text(store['description'] ?? '')),
              DataCell(Text(capitalizeFirstLetter(store['type'] ?? ''))),
              DataCell(Text(store['initiator'] ?? '')),
              DataCell(Text(formatDate(store['createdAt']))),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_attributes),
                      onPressed: () {
                        deleteStore(store['_id']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_forever_outlined),
                      onPressed: () {
                        deleteStore(store['_id']);
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
