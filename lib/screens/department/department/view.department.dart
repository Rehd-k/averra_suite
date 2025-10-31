import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../helpers/financial_string_formart.dart';

class ViewDepartments extends StatelessWidget {
  final List filteredDepartments;
  final TextEditingController searchController;
  final bool isLoading;

  final String sortBy;
  final bool ascending;
  final Function filterDepartment;
  final Function getFilteredAndSortedRows;
  final Function deleteDepartment;
  final Function openUpdateDepartment;
  const ViewDepartments({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.sortBy,
    required this.ascending,
    required this.getFilteredAndSortedRows,
    required this.deleteDepartment,
    required this.filteredDepartments,
    required this.filterDepartment,
    required this.openUpdateDepartment,
  });

  @override
  Widget build(BuildContext context) {
    String formatDate(String isoDate) {
      final DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Initiator')),
            DataColumn(label: Text('Created At')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredDepartments.map<DataRow>((department) {
            return DataRow(
              cells: [
                DataCell(
                  Text(capitalizeFirstLetter(department['title'] ?? '')),
                ),
                DataCell(Text(department['description'] ?? '')),
                DataCell(Text(capitalizeFirstLetter(department['type'] ?? ''))),
                DataCell(Text(department['initiator'] ?? '')),
                DataCell(Text(formatDate(department['createdAt']))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_attributes),
                        onPressed: () {
                          openUpdateDepartment(
                            context,
                            department['_id'],
                            department,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_outlined),
                        onPressed: () {
                          deleteDepartment(department['_id']);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
