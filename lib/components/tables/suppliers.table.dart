import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class SupplierTable extends StatelessWidget {
  final List suppliers;
  const SupplierTable({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;

    return Card(
      margin: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(cardColor),
          columnSpacing: smallScreen ? 90 : 235,
          columns: [
            DataColumn(
              label: Text(
                'Supplier Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Total Spend',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: suppliers
              .map(
                (supplier) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        capitalizeFirstLetter(supplier['name']),
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    DataCell(
                      Text(supplier['address'], style: TextStyle(fontSize: 10)),
                    ),
                    DataCell(
                      Text(
                        supplier['amountSpent'].toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                        style: TextStyle(fontSize: 10),
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
