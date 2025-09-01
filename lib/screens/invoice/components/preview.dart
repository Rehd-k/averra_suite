import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../helpers/financial_string_formart.dart';

import '../../../components/dotted_lines.dart';
import 'infinite_table.dart';

class InvoicePage extends StatelessWidget {
  final Invoice invoice;

  const InvoicePage({
    super.key,
    required this.invoice,
  });

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              child: Text("INVOICE",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              onPressed: () async {},
            ),
            SizedBox(height: 16),
            MySeparator(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _contactInfo("Nenz Global", [
                  "1234 Elm Street",
                  "City, State 12345",
                  "(234) 906-470-6633",
                  "frontdesk@Kinzo-techglobal.com",
                ]),
                _contactInfo("BILL TO", [
                  invoice.customer['name'],
                  invoice.customer['address'],
                  "${invoice.customer['city']}, ${invoice.customer['state']} ${invoice.customer['zipCode']}",
                ]),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _invoiceMeta("INVOICE #", invoice.invoiceNumber.toUpperCase()),
                _invoiceMeta("DATE", formatDate(invoice.issueDate)),
                _invoiceMeta("DUE DATE", formatDate(invoice.dueDate)),
                _invoiceMeta(
                    "AMOUNT DUE",
                    invoice.total
                        .toString()
                        .formatToFinancial(isMoneySymbol: true),
                    highlight: true),
              ],
            ),
            SizedBox(height: 24),
            _buildInvoiceTable(invoice.items),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      "SUBTOTAL: ${(((invoice.total + invoice.discount) - invoice.tax)).toString().formatToFinancial(isMoneySymbol: true)}",
                      style: TextStyle(fontSize: 16)),
                  Text(
                      "TAX : ${invoice.tax.toString().formatToFinancial(isMoneySymbol: true)}",
                      style: TextStyle(fontSize: 16)),
                  Text(
                      "Total : ${invoice.tax.toString().formatToFinancial(isMoneySymbol: true)}",
                      style: TextStyle(fontSize: 16)),
                  Text(
                      "Discount : ${invoice.discount.toString().formatToFinancial(isMoneySymbol: true)}",
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                      "Grand Total: ${invoice.total.toString().formatToFinancial(isMoneySymbol: true)}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text("NOTES", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(invoice.note),
          ],
        ),
      ),
    );
  }

  Widget _contactInfo(String title, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ...lines.map((line) => Text(line)),
      ],
    );
  }

  Widget _invoiceMeta(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.teal)),
        Text(value,
            style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildInvoiceTable(items) {
    return Table(
      border: TableBorder.symmetric(
          inside: BorderSide(width: 0.5, color: Colors.grey)),
      columnWidths: {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      children: [
        _buildTableRow(['DESCRIPTION', 'RATE', 'QTY', 'AMOUNT'],
            isHeader: true),
        ...items.map((item) {
          return _buildTableRow([
            item['title'],
            item['price'].toString().formatToFinancial(isMoneySymbol: true),
            item['quantity'].toString(),
            item['total'].toString().formatToFinancial(isMoneySymbol: true),
          ]);
        }),
      ],
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(color: Colors.grey[300]) : null,
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        );
      }).toList(),
    );
  }
}
