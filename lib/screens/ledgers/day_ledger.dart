import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../service/date_range_helper.dart';

// --- DATA MODEL ---
// This class represents a single transaction record.
// You would typically define this in its own file (e.g., 'models/transaction_model.dart').
class TransactionModel {
  final DateTime date;
  final String description;
  final int inwardQty;
  final int inwardAmt;
  final int outwardQty;
  final int outwardAmt;

  TransactionModel({
    required this.date,
    required this.description,
    this.inwardQty = 0,
    this.inwardAmt = 0,
    this.outwardQty = 0,
    this.outwardAmt = 0,
  });
}

// --- THE TRANSACTION TABLE WIDGET ---
class TransactionsTable extends StatefulWidget {
  final String id;
  const TransactionsTable({super.key, required this.id});

  @override
  DayLedgerState createState() => DayLedgerState();
}

class DayLedgerState extends State<TransactionsTable> {
  ApiService apiService = ApiService();
  late List<TransactionModel> transactions = [];
  late String id;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  static const List<Color> _monthColors = [
    Color(0xFFE3F2FD), // Jan - Light Blue
    Color(0xFFE8F5E9), // Feb - Light Green
    Color(0xFFFFFDE7), // Mar - Light Yellow
    Color(0xFFEDE7F6), // Apr - Light Purple
    Color(0xFFF3E5F5), // May - Light Orchid
    Color(0xFFE0F7FA), // Jun - Light Cyan
    Color(0xFFFBE9E7), // Jul - Light Orange
    Color(0xFFEFEBE9), // Aug - Light Brown
    Color(0xFFF1F8E9), // Sep - Light Lime
    Color(0xFFE1F5FE), // Oct - Lighter Blue
    Color(0xFFF9FBE7), // Nov - Lighter Yellow
    Color(0xFFECEFF1), // Dec - Blue Grey
  ];

  Future<void> getReportData() async {
    var result = await apiService.get(
      'analytics/get-products-report?id=$id&start=$startDate&end=$endDate',
    );
    List<TransactionModel> innerTransaction = [];
    for (var element in result.data) {
      innerTransaction.add(
        TransactionModel(
          date: DateTime.parse(element['Date']),
          description: element['Description'],
          inwardQty: element['direction'] == 'inward' ? element['qty'] : 0,
          inwardAmt: element['direction'] == 'inward' ? element['amount'] : 0,
          outwardQty: element['direction'] == 'outward' ? element['qty'] : 0,
          outwardAmt: element['direction'] == 'outward' ? element['amount'] : 0,
        ),
      );
    }

    setState(() {
      transactions.addAll(innerTransaction);
    });
  }

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
        transactions = [];
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
        transactions = [];
      });
    }
    getReportData();
  }

  void handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
      transactions = [];
    });
    getReportData();
  }

  @override
  void initState() {
    id = widget.id;
    getReportData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<TableRow> tableRows = [];

    // --- HEADER ROWS ---
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.grey[300]),
        children: [
          _buildHeaderCell('Date', isSubHeader: false),
          _buildHeaderCell('Description', isSubHeader: false),
          _buildHeaderCell(
            'Inward',
            isSubHeader: false,
            alignment: TextAlign.center,
          ),
          _buildHeaderCell('', isSubHeader: false),
          _buildHeaderCell(
            'Outward',
            isSubHeader: false,
            alignment: TextAlign.center,
          ),
          _buildHeaderCell('', isSubHeader: false),
          _buildHeaderCell(
            'Total',
            isSubHeader: false,
            alignment: TextAlign.center,
          ),
          _buildHeaderCell('', isSubHeader: false),
        ],
      ),
    );
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
        ),
        children: [
          _buildHeaderCell(''),
          _buildHeaderCell(''),
          _buildHeaderCell('Qty', alignment: TextAlign.right),
          _buildHeaderCell('Amt', alignment: TextAlign.right),
          _buildHeaderCell('Qty', alignment: TextAlign.right),
          _buildHeaderCell('Amt', alignment: TextAlign.right),
          _buildHeaderCell('Qty', alignment: TextAlign.right),
          _buildHeaderCell('Amt', alignment: TextAlign.right),
        ],
      ),
    );

    // --- DATA AND TOTAL ROWS ---
    if (transactions.isNotEmpty) {
      // Sort transactions by date to ensure they are in chronological order.
      final sortedTransactions = List<TransactionModel>.from(transactions)
        ..sort((a, b) => a.date.compareTo(b.date));

      int currentMonth = sortedTransactions.first.date.month;
      int monthlyQty = 0;
      double monthlyAmt = 0.0;

      for (int i = 0; i < sortedTransactions.length; i++) {
        final transaction = sortedTransactions[i];

        // If the month of the current transaction is different, it's time to add the total row.
        if (transaction.date.month != currentMonth) {
          tableRows.add(_buildTotalRow(monthlyQty, monthlyAmt));
          // Reset trackers for the new month.
          monthlyQty = 0;
          monthlyAmt = 0.0;
          currentMonth = transaction.date.month;
        }

        // Add current transaction's values to the monthly total.
        monthlyQty += transaction.inwardQty - transaction.outwardQty;
        monthlyAmt += transaction.inwardAmt - transaction.outwardAmt;

        // Add the regular data row for the current transaction.
        final monthColor = _monthColors[transaction.date.month - 1];
        final formattedDate = DateFormat('dd/MM/yyyy').format(transaction.date);
        tableRows.add(
          TableRow(
            decoration: BoxDecoration(color: monthColor),
            children: [
              _buildDataCell(formattedDate),
              _buildDataCell(transaction.description),
              _buildDataCell(
                transaction.inwardQty != 0
                    ? transaction.inwardQty.toString()
                    : '',
                alignment: TextAlign.right,
              ),
              _buildDataCell(
                transaction.inwardAmt != 0
                    ? transaction.inwardAmt
                          .toStringAsFixed(0)
                          .formatToFinancial(isMoneySymbol: true)
                    : '',
                alignment: TextAlign.right,
              ),
              _buildDataCell(
                transaction.outwardQty != 0
                    ? transaction.outwardQty.toString()
                    : '',
                alignment: TextAlign.right,
              ),
              _buildDataCell(
                transaction.outwardAmt != 0
                    ? transaction.outwardAmt
                          .toStringAsFixed(0)
                          .formatToFinancial(isMoneySymbol: true)
                    : '',
                alignment: TextAlign.right,
              ),
              _buildDataCell(''), // Empty Total Qty
              _buildDataCell(''), // Empty Total Amt
            ],
          ),
        );

        // If this is the very last transaction in the list, add the total row for the final month.
        if (i == sortedTransactions.length - 1) {
          tableRows.add(_buildTotalRow(monthlyQty, monthlyAmt));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: DateRangeHolder(
          fromDate: startDate,
          toDate: endDate,
          handleRangeChange: handleRangeChange,
          handleDateReset: handleDateReset,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // createExcelFile();
            },
            tooltip: 'Extract to Excel',
            icon: Icon(Icons.dataset_outlined),
          ),
        ],
      ),
      body: transactions.isNotEmpty
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade400),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(flex: 2.0),
                  2: IntrinsicColumnWidth(),
                  3: IntrinsicColumnWidth(),
                  4: IntrinsicColumnWidth(),
                  5: IntrinsicColumnWidth(),
                  6: IntrinsicColumnWidth(),
                  7: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: tableRows,
              ),
            )
          : Center(child: Text('No Data')),
    );
  }

  // Helper widget to build the monthly total row.
  TableRow _buildTotalRow(int qty, double amt) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        border: Border(
          top: BorderSide(color: Colors.blueGrey.shade300, width: 1.5),
        ),
      ),
      children: [
        _buildDataCell(''), _buildDataCell(''),
        _buildDataCell(''), _buildDataCell(''),
        // Span the "Monthly Total" text over two cells for better alignment.
        _buildDataCell(
          'Monthly Total',
          alignment: TextAlign.right,
          isBold: true,
        ),
        _buildDataCell('', isBold: true),
        _buildDataCell(
          qty.toString(),
          alignment: TextAlign.right,
          isBold: true,
        ),
        _buildDataCell(
          amt.toStringAsFixed(0).formatToFinancial(isMoneySymbol: true),
          alignment: TextAlign.right,
          isBold: true,
        ),
      ],
    );
  }

  // Helper widget to build styled header cells.
  Widget _buildHeaderCell(
    String text, {
    bool isSubHeader = true,
    TextAlign alignment = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Text(
        text,
        textAlign: alignment,
        style: TextStyle(
          fontWeight: isSubHeader ? FontWeight.normal : FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper widget to build styled data cells.
  Widget _buildDataCell(
    String text, {
    TextAlign alignment = TextAlign.left,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
      child: Text(
        text,
        textAlign: alignment,
        style: TextStyle(
          color: Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
