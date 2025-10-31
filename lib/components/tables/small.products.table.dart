import 'package:flutter/material.dart';

import '../../helpers/financial_string_formart.dart';

class SmallProductsTable extends StatelessWidget {
  final List products;
  const SmallProductsTable({super.key, required this.products});

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
                width: 150, // Supplier Name widest
                child: Text(
                  'Title',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 130,
                child: Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 130,
                child: Text(
                  'Quantity Sold',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 130,
                child: Text(
                  'Revenue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: products
              .map(
                (product) => DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          capitalizeFirstLetter(product['title']),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          product['category'],
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Text(
                            (product['totalSold']).toString().formatToFinancial(
                              isMoneySymbol: false,
                            ),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          (product['totalRevenue'])
                              .toString()
                              .formatToFinancial(isMoneySymbol: true),
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
