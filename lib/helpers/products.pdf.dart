import 'dart:io';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PdfProductsService {
  /// Main function to generate the PDF
  Future<Uint8List> generateStockReport(
    List<Map<String, dynamic>> data,
    Uint8List logoBytes,
  ) async {
    final pdf = pw.Document(pageMode: PdfPageMode.outlines);

    final poppinsRegularData = await rootBundle.load(
      "assets/fonts/Poppins-Regular.ttf",
    );
    final poppinsBoldData = await rootBundle.load(
      "assets/fonts/Poppins-Bold.ttf",
    );

    // Load DejaVuSans for Naira symbol
    final dejaVuSansData = await rootBundle.load("assets/fonts/DejaVuSans.ttf");
    final dejaVuSans = pw.Font.ttf(dejaVuSansData);

    final poppinsRegular = pw.Font.ttf(poppinsRegularData);
    final poppinsBold = pw.Font.ttf(poppinsBoldData);

    final theme = pw.ThemeData.withFont(
      base: poppinsRegular,
      bold: poppinsBold,
    );

    // 1. Define Columns (Keys) and readable Headers
    // We map the specific object keys from your backend to display headers
    const tableHeaders = [
      'Title',
      'Category',
      'Brand',
      'Unit Price', // sellingPriceUnit
      'R.O.Q', // openingStock
      'Quantity', // quantitySold
      'Value', // closingStock
    ];

    // 2. Prepare Data Rows
    final tableData = data.map((item) {
      return [
        item['title'] ?? '',
        item['category'] ?? '',
        item['brand'] ?? '',
        _formatCurrency(item['price']),
        item['roq'] ?? '',
        item['quantity']?.toString() ?? '0',
        _formatCurrency(item['price'] * item['quantity'] ?? 0),
      ];
    }).toList();
    // 3. Add Page
    pdf.addPage(
      pw.MultiPage(
        // pageFormat: PdfPageFormat.a4.landscape, // Landscape for wide tables
        // margin: const pw.EdgeInsets.all(32),

        // --- WATERMARK CONFIGURATION ---
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.portrait,
          margin: const pw.EdgeInsets.all(10),
          theme: theme,
          // Watermark goes here
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Center(
              child: pw.Transform.rotate(
                angle: -0.5, // Negative for diagonal /
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Text(
                    'CONFIDENTIAL',
                    style: pw.TextStyle(
                      fontSize: 70,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- CONTENT BUILDER ---
        build: (pw.Context context) {
          return [
            _buildHeader(logoBytes),
            pw.SizedBox(height: 20),
            _buildTable(tableHeaders, dejaVuSans, tableData),
            pw.SizedBox(height: 20),
            _buildFooter(data, dejaVuSans),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // 2. Save to Downloads AND Share
  Future<void> saveAndShareFile(
    List<Map<String, dynamic>> data,
    Uint8List logoBytes,
  ) async {
    // A. Generate the PDF
    final bytes = await generateStockReport(data, logoBytes);
    final fileName =
        'products_report_${DateTime.now().microsecondsSinceEpoch}.pdf';

    // B. Save to Downloads (Android specific logic vs iOS/Desktop)
    File? downloadsFile;

    if (Platform.isAndroid) {
      // Check permissions for Android
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        // Hardcoded path is often most reliable for "Downloads" on Android
        final downloadsPath = '/storage/emulated/0/Download';
        final dir = Directory(downloadsPath);

        if (await dir.exists()) {
          downloadsFile = File('$downloadsPath/$fileName');
          await downloadsFile.writeAsBytes(bytes);
        }
      }
    }

    // For iOS/Desktop, getDownloadsDirectory usually works or use ApplicationDocuments
    if (downloadsFile == null) {
      final dir = await getApplicationDocumentsDirectory();
      downloadsFile = File('${dir.path}/$fileName');
      await downloadsFile.writeAsBytes(bytes);
    }

    // C. Share the file
    // Note: We use the file we just wrote to storage
    if (await downloadsFile.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(downloadsFile.path)],
          text: "Here's your invoice",
          subject: "Invoice",
        ),
      );
    }
  }

  // --- Helper: Header Section ---
  pw.Widget _buildHeader(Uint8List logoBytes) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company Info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'MY COMPANY LTD',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text('123 Business Road, Lagos, Nigeria'),
            pw.Text('Email: reports@mycompany.com'),
            pw.Text('Tel: +234 800 123 4567'),
          ],
        ),
        // Logo
        pw.Container(
          height: 60,
          width: 60,
          child: pw.Image(pw.MemoryImage(logoBytes)),
        ),
      ],
    );
  }

  // --- Helper: Table Section ---
  pw.Widget _buildTable(
    List<String> headers,
    dejaVuSans,
    List<List<dynamic>> data,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null, // Clean look without grid lines
      cellStyle: pw.TextStyle(font: dejaVuSans),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),

      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: .5),
        ),
      ),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        0: pw.Alignment.centerLeft, // Title
        1: pw.Alignment.centerLeft, // Category
        2: pw.Alignment.centerRight, // Numbers...
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.centerRight,
        9: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    );
  }

  // --- Helper: Footer / Totals ---
  pw.Widget _buildFooter(List<Map<String, dynamic>> data, dejaVuSans) {
    // Calculate Total Sales and Profit
    double totalSales = 0;
    for (var item in data) {
      totalSales += ((item['quantity'] * item['price']) as num? ?? 0)
          .toDouble();
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Total Products Value: ${_formatCurrency(totalSales)}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: dejaVuSans,
              ),
            ),
            // pw.Text(
            //   'Total Gross Profit: ${_formatCurrency(totalProfit)}',
            //   style: pw.TextStyle(
            //     fontWeight: pw.FontWeight.bold,
            //     color: PdfColors.green700,
            //   ),
            // ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated on: ${DateTime.now().toString().split('.')[0]}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0.00';
    return formatNaira(double.tryParse(value.toString()) ?? 0);
  }
}
