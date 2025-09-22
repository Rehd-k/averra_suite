import 'package:flutter/material.dart';

import '../../helpers/supplierholder.dart';

class SupplierTable extends StatelessWidget {
  final List<Supplier> suppliers;
  final void Function(Supplier) onRowTap;

  const SupplierTable({
    super.key,
    required this.suppliers,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 20,
      headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
      columns: const [
        DataColumn(label: Text("Supplier Name")),
        DataColumn(label: Text("Primary Contact")),
        DataColumn(label: Text("Email")),
        DataColumn(label: Text("Phone Number")),
        DataColumn(label: Text("Status")),
      ],
      rows: suppliers.map((supplier) {
        return DataRow(
          cells: [
            DataCell(Text(supplier.name), onTap: () => onRowTap(supplier)),
            DataCell(
              Text(supplier.primaryContact),
              onTap: () => onRowTap(supplier),
            ),
            DataCell(Text(supplier.email), onTap: () => onRowTap(supplier)),
            DataCell(
              Text(supplier.phoneNumber),
              onTap: () => onRowTap(supplier),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: supplier.status.toLowerCase() == "active"
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  supplier.status,
                  style: TextStyle(
                    color: supplier.status.toLowerCase() == "active"
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () => onRowTap(supplier),
            ),
          ],
        );
      }).toList(),
    );
  }
}
