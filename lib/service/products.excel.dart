// import 'dart:io';
import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';

Future<void> createExcelFile() async {
  // Create a new Excel document
  var excel = Excel.createExcel(); // By default, it has one sheet
  String sheetName = excel.getDefaultSheet()!;

  // Get the sheet
  var sheet = excel[sheetName];

  // Add header row
  sheet.appendRow([
    TextCellValue('ID'),
    TextCellValue('Name'),
    TextCellValue('Email'),
  ]);

  // Add some data rows
  sheet.appendRow([
    IntCellValue(1),
    TextCellValue('John Doe"'),
    TextCellValue("john@example.com"),
  ]);
  sheet.appendRow([
    IntCellValue(2),
    TextCellValue('John Doe"'),
    TextCellValue("john@example.com"),
  ]);
  sheet.appendRow([
    IntCellValue(3),
    TextCellValue('John Doe"'),
    TextCellValue("john@example.com"),
  ]);

  // Save file to device storage
  // List<int>? fileBytes = excel.save();
  // Directory dir = await getApplicationDocumentsDirectory();
  // String filePath = "${dir.path}/example.xlsx";
  // File(filePath)
  //   ..createSync(recursive: true)
  //   ..writeAsBytesSync(fileBytes);
}
