import 'dart:async';
import 'dart:developer';
// Required for BuildContext if showing dialogs from service
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

import 'package:flutter_thermal_printer/utils/printer.dart';
// Ensure this path is correct for your project structure for Printer class
// If Printer class is part of

enum PrintFlowStatus {
  noPrintersFound,
  printingDirectly,
  requiresSelection,
  printSuccess,
  printError,
  scanTimeout,
  scanFailed,
}

class PrintInitiationResult {
  final PrintFlowStatus status;
  final List<Printer>? printersForSelection;
  final Printer? singlePrinter;
  final String message;

  PrintInitiationResult(this.status,
      {this.printersForSelection, this.singlePrinter, required this.message});
}

class PrinterService {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
  List<Printer> printers = [];
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  // Get Printer List
  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin
        .getPrinters(connectionTypes: [ConnectionType.USB]);
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      printers = event;
      printers
          .removeWhere((element) => element.name == null || element.name == '');

      // log(event.map((e) => e.address).toList().toString());
    });
  }

  stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  Future<void> printData(Printer printer, data,
      {Function(String)? onSuccess, Function(String)? onError}) async {
    log("PrinterService: Attempting to print to ${printer.name} (VID:${printer.vendorId}, PID:${printer.productId})");
    try {
      log("PrinterService: Print result for ${printer.name}");

      return await _flutterThermalPrinterPlugin.printData(printer, await data);
    } catch (e) {
      log("PrinterService: Error printing data to ${printer.name}: $e");
      onError?.call("Error printing data: $e");
    }
  }

  void dispose() {
    log("PrinterService: Disposing service and cancelling stream subscriptions.");
    _devicesStreamSubscription?.cancel();
    _devicesStreamSubscription = null;
  }
}
