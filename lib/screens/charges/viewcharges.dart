import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Viewcharges extends StatelessWidget {
  final List filteredCharges;
  final TextEditingController searchController;
  final bool isLoading;

  final String sortBy;
  final bool ascending;
  final Function filterCharges;
  final Function getFilteredAndSortedRows;
  final Function deleteCharge;

  const Viewcharges({
    super.key,
    required this.filteredCharges,
    required this.searchController,
    required this.isLoading,
    required this.sortBy,
    required this.ascending,
    required this.filterCharges,
    required this.getFilteredAndSortedRows,
    required this.deleteCharge,
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
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Initiator')),
          DataColumn(label: Text('Created At')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredCharges.map<DataRow>((charge) {
          return DataRow(
            cells: [
              DataCell(Text(charge['title'] ?? '')),
              DataCell(Text(charge['description'] ?? '')),
              DataCell(
                Text(
                  charge['amount']?.toString().formatToFinancial(
                        isMoneySymbol: true,
                      ) ??
                      '',
                ),
              ),
              DataCell(Text(charge['initiator'] ?? '')),
              DataCell(Text(formatDate(charge['createdAt']))),
              DataCell(
                OutlinedButton(
                  onPressed: () {
                    deleteCharge(charge['_id']);
                  },
                  child: Text('Delete'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
