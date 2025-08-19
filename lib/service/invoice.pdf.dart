import 'dart:io';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../screens/invoice/components/infinite_table.dart';

Future<File> generateInvoicePdf(Invoice invoice) async {
  final pdf = pw.Document();
  // Load Poppins for general text
  final poppinsRegularData = await rootBundle.load(
    "assets/fonts/Poppins-Regular.ttf",
  );
  final poppinsBoldData = await rootBundle.load(
    "assets/fonts/Poppins-Bold.ttf",
  );

  final poppinsRegular = pw.Font.ttf(poppinsRegularData);
  final poppinsBold = pw.Font.ttf(poppinsBoldData);

  // Load DejaVuSans for Naira symbol
  final dejaVuSansData = await rootBundle.load("assets/fonts/DejaVuSans.ttf");
  final dejaVuSans = pw.Font.ttf(dejaVuSansData);

  final theme = pw.ThemeData.withFont(base: poppinsRegular, bold: poppinsBold);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      build: (context) => [
        pw.Text(
          "INVOICE",
          style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _contactInfo("Rikanenz Integrated Service LTD", [
              "Ekit Itam, Itam",
              "Uyo, Akwa Ibom 458784",
              "(234) 803-977-0324",
              "frontdesk@nenzltd.com",
            ]),
            _contactInfo("BILL TO", [
              invoice.customer['name'],
              invoice.customer['address'],
              "${invoice.customer['city']}, ${invoice.customer['state']} ${invoice.customer['zipCode']}",
            ]),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _invoiceMeta(
              "INVOICE #",
              invoice.invoiceNumber.toUpperCase(),
              poppinsRegular,
            ),
            _invoiceMeta(
              "DATE",
              _formatDate(invoice.issueDate),
              poppinsRegular,
            ),
            _invoiceMeta(
              "DUE DATE",
              _formatDate(invoice.dueDate),
              poppinsRegular,
            ),
            _invoiceMeta(
              "AMOUNT DUE",
              invoice.total.toString().formatToFinancial(isMoneySymbol: true),
              dejaVuSans,
              highlight: true,
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        _invoiceTable(invoice.items, dejaVuSans),
        pw.SizedBox(height: 24),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "SUBTOTAL: ${((invoice.total + invoice.discount) - invoice.tax).toString().formatToFinancial(isMoneySymbol: true)}",
                style: pw.TextStyle(font: dejaVuSans),
              ),
              pw.Text(
                "TAX: ${invoice.tax.toString().formatToFinancial(isMoneySymbol: true)}",
                style: pw.TextStyle(font: dejaVuSans),
              ),
              pw.Text(
                "Total: ${(invoice.total + invoice.discount).toString().formatToFinancial(isMoneySymbol: true)}",
                style: pw.TextStyle(font: dejaVuSans),
              ),
              pw.Text(
                "Discount: ${invoice.discount.toString().formatToFinancial(isMoneySymbol: true)}",
                style: pw.TextStyle(font: dejaVuSans),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Grand Total: ${invoice.total.toString().formatToFinancial(isMoneySymbol: true)}",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: dejaVuSans,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Text("NOTES", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(invoice.note),
      ],
    ),
  );

  final outputDir = await getTemporaryDirectory();
  final file = File("${outputDir.path}/invoice.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}

pw.Widget _contactInfo(String title, List<String> lines) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ...lines.map((line) => pw.Text(line)),
    ],
  );
}

pw.Widget _invoiceMeta(
  String label,
  String value,
  dejaVuSans, {
  bool highlight = false,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(color: PdfColors.teal)),
      pw.Text(
        value,
        style: pw.TextStyle(
          font: dejaVuSans,
          fontWeight: highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    ],
  );
}

pw.Widget _invoiceTable(List<dynamic> items, dejaVuSans) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    columnWidths: {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(2),
    },
    children: [
      _tableRow(
        ['DESCRIPTION', 'RATE', 'QTY', 'AMOUNT'],
        dejaVuSans,
        isHeader: true,
      ),
      ...items.map(
        (item) => _tableRow([
          item['title'],
          item['price'].toString().formatToFinancial(isMoneySymbol: true),
          item['quantity'].toString().formatToFinancial(isMoneySymbol: false),
          item['total'].toString().formatToFinancial(isMoneySymbol: true),
        ], dejaVuSans),
      ),
    ],
  );
}

pw.TableRow _tableRow(List<String> cells, dejaVuSans, {bool isHeader = false}) {
  return pw.TableRow(
    decoration: isHeader
        ? const pw.BoxDecoration(color: PdfColors.grey300)
        : null,
    children: cells
        .map(
          (cell) => pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              cell,
              style: pw.TextStyle(
                font: dejaVuSans,
                fontWeight: isHeader
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        )
        .toList(),
  );
}

String _formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
}
