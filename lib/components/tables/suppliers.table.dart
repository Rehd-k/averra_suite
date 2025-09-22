import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class SupplierTable extends StatelessWidget {
  final List suppliers;
  const SupplierTable({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Card(
      margin: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(cardColor),

          columns: const [
            DataColumn(
              label: SizedBox(
                width: 200, // Supplier Name widest
                child: Text(
                  'Supplier Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text(
                  'Total Spend',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: suppliers
              .map(
                (supplier) => DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          capitalizeFirstLetter(supplier['name']),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          supplier['address'],
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          supplier['amountSpent'].toString().formatToFinancial(
                            isMoneySymbol: true,
                          ),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
