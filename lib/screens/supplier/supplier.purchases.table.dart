import 'package:flutter/material.dart';

import '../../components/tables/custom_data_table.dart';
import '../../helpers/financial_string_formart.dart';

class SupplierPurchasesTable extends StatelessWidget {
  final List orderHistory;
  const SupplierPurchasesTable({super.key, required this.orderHistory});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return CustomDataTable(
      columns: [
        DataColumn(
          label: SizedBox(
            width: smallScreen ? 100 : 200,
            child: Text(
              'Product Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: smallScreen ? 100 : 200,
            child: Text(
              'Total Amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: smallScreen ? 100 : 200,
            child: Text(
              'Total Paid',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: smallScreen ? 100 : 200,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: smallScreen ? 100 : 200,
            child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
      data: orderHistory,
      cellBuilder: (supplier) => [
        DataCell(
          SizedBox(
            width: 100,
            child: Text(supplier['product'], style: TextStyle(fontSize: 10)),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              supplier['totalPayable'].toString().formatToFinancial(
                isMoneySymbol: true,
              ),
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              supplier['totalPaid'].toString().formatToFinancial(
                isMoneySymbol: true,
              ),
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(supplier['status'], style: TextStyle(fontSize: 10)),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              formatBackendTime(supplier['purchaseDate']),
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
