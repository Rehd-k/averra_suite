import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as imgi;

generateReceipt(
  PaperSize paper,
  CapabilityProfile profile,
  Map saleData,
  Map? storeDetails,
) async {
  final generator = Generator(paper, profile);
  List<int> bytes = [];
  String qrData = "vessellabs.org";
  const double qrSize = 100;
  final ByteData data = await rootBundle.load('assets/icon/icon.png');
  final Uint8List pngbytes = data.buffer.asUint8List();
  final imgi.Image? image = imgi.decodeImage(pngbytes);

  bytes += generator.image(image!);
  if (storeDetails != null) {
    bytes += generator.text(
      storeDetails['firm_name'],
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      storeDetails['location'],
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Phone: ${storeDetails['manager']}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Email: ${storeDetails['manager'] ?? '---------'}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();
  }

  bytes += generator.text('Receipt No: ${saleData['transactionId']}');
  bytes += generator.text(
    'Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(saleData['transactionDate']))}',
  );
  bytes += generator.text('Cashier: ${saleData['handler']}');
  bytes += generator.text('Terminal: ---');
  if (saleData['customer'] != null) {
    bytes += generator.text('Customer: ${saleData['customer']['name']}');
    bytes += generator.text('Loyalty ID: ${saleData['customer']['_id']}');
  }

  bytes += generator.hr();

  // Header Row
  bytes += generator.row([
    PosColumn(text: 'Item', width: 4, styles: const PosStyles(bold: true)),
    PosColumn(
      text: 'Qty',
      width: 2,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ),
    PosColumn(
      text: 'Price',
      width: 3,
      styles: const PosStyles(align: PosAlign.right, bold: true),
    ),
    PosColumn(
      text: 'Total',
      width: 3,
      styles: const PosStyles(align: PosAlign.right, bold: true),
    ),
  ]);

  final items = saleData['products'];

  double subtotal = 0;
  for (var item in items) {
    final total = item['quantity'] * item['price'];
    subtotal += total;
    bytes += generator.row([
      PosColumn(text: item['title'], width: 4),
      PosColumn(
        text: '${item['quantity']}',
        width: 2,
        styles: const PosStyles(align: PosAlign.center),
      ),
      PosColumn(
        text: item['price'].toString().formatToFinancial(),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '$total',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
  }

  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(text: 'Subtotal:', width: 8),
    PosColumn(
      text: subtotal.toStringAsFixed(2),
      width: 4,
      styles: const PosStyles(align: PosAlign.right),
    ),
  ]);

  bytes += generator.row([
    PosColumn(text: 'TOTAL:', width: 8, styles: const PosStyles(bold: true)),
    PosColumn(
      text: subtotal.toStringAsFixed(2),
      width: 4,
      styles: const PosStyles(align: PosAlign.right, bold: true),
    ),
  ]);

  bytes += generator.hr();
  bytes += generator.text('Payment Method: cash');
  bytes += generator.text('Amount Tendered:  ${subtotal.toStringAsFixed(2)}');
  bytes += generator.text('Change Due:  0.00');

  bytes += generator.text(
    'Please Come Back For More...',
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.barcode(
    Barcode.code128(saleData['barcodeId'].toString().split("")),
    textPos: BarcodeText.none,
  );
  bytes += generator.feed(2);
  bytes += generator.text(
    'Powered By VesselLabs',
    styles: const PosStyles(align: PosAlign.center),
  );

  Future<ui.Image> convertToUiImage(imgi.Image image) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.fromList(imgi.encodePng(image)), (
      ui.Image img,
    ) {
      completer.complete(img);
    });
    return completer.future;
  }

  final ui.Image flutterImage = await convertToUiImage(image);
  final uiImg = await QrPainter(
    data: qrData,
    version: QrVersions.auto,
    gapless: false,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
    embeddedImage: flutterImage,
    embeddedImageStyle: QrEmbeddedImageStyle(size: Size(30, 30)),
  ).toImageData(qrSize);
  final dir = await getTemporaryDirectory();
  final pathName = '${dir.path}/qr_tmp.png';
  final qrFile = File(pathName);
  if (uiImg != null) {
    final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    final img = imgi.decodeImage(imgFile.readAsBytesSync());

    bytes += generator.image(img!);
  }
  bytes += generator.feed(2);

  return Uint8List.fromList(bytes);
}
