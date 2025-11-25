import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/finance_card.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

// import '../../../components/tables/purchases/purchases_table.dart';
import '../../../../components/tables/gen_big_table/big_table.dart';
import '../../../../components/tables/gen_big_table/big_table_source.dart';

import '../../../service/api.service.dart';
import '../../../service/defaultprinter.service.dart';
import '../../../service/printer.service.dart';
import '../../../service/receipt_holder.dart';
import '../../../service/token.service.dart';
import 'collums_deff.dart';
import 'header.dart';
import 'more_details.dart';

@RoutePage()
class IncomeReportsScreen extends StatefulWidget {
  const IncomeReportsScreen({super.key});

  @override
  IncomeReportsScreenState createState() => IncomeReportsScreenState();
}

class IncomeReportsScreenState extends State<IncomeReportsScreen> {
  final apiService = ApiService();
  JsonEncoder jsonEncoder = JsonEncoder();
  final StringBuffer buffer = StringBuffer();
  final TextEditingController _searchController = TextEditingController();
  final PrinterService _printerService = PrinterService();
  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
  String searchQuery = "";
  late Map<String, dynamic> summaryCalculations;
  Map<String, dynamic> transactionUpdate = {};
  String? searchFeild = 'transactionId';
  String? initialSort = 'transactionDate';
  String? searchFeildForSearchText = '';
  String? paymentMethordToShow = '';
  String? selectedAccount = '';
  String? selectedBank = '';
  List cashiers = [''];
  List banks = [];
  bool showDetails = false;
  bool showHeader = false;
  String query = '';
  bool loading = true;
  List<TableDataModel> _selectedRows = [];
  late TableDataModel selectedItem;

  late List<ColumnDefinition> _columnDefinitions;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  // Search logic
  void searchThroughSales(String newQuery) async {
    Future.delayed(const Duration(milliseconds: 500), () {
      query = newQuery;
      handleCalculations();
    });
  }

  void doPrint() {
    debugPrint(_selectedRows.toString());
  }

  // filter logic
  void filterLogic(String searchFeild, String? query) async {
    setState(() {
      searchFeild = searchFeild;
    });
  }

  void updateTransaction() async {
    final userRole = JwtService().decodedToken;
    if (userRole != null) {
      if (userRole['role'] == 'admin' || userRole['role'] == 'god') {
        await apiService.put(
          'sales/${_selectedRows[0]['_id']}',
          transactionUpdate,
        );
        setState(() {});
      } else {
        await apiService.post('todo', {
          'title': 'Back Date',
          'description':
              'Change the date of transaction with Id  ${_selectedRows[0]['transactionId']} to ${formatDate(transactionUpdate['transactionDate'])}',
          'from': userRole['username'],
          'createdAt': DateTime.now().toString(),
        });

        toastification.show(
          title: Text(
            'A request has been sent to the Manager, and will be effected soon',
          ),
          type: ToastificationType.info,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  void handleUpdate(dynamic updateInfo) {
    setState(() {
      transactionUpdate = updateInfo;
      updateTransaction();
    });
    // Check if widget is still mounted before showing message
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Use captured scaffoldMessenger
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Updated'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void handleShowDetails(dynamic details, isBigScreen) {
    selectedItem = details;
    if (isBigScreen) {
      setState(() {
        showDetails = !showDetails;
      });
    } else {
      handleSelection(selectedItem);
    }
  }

  void handleSelection(dynamic selected) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.95, // Almost full screen
          padding: EdgeInsets.all(16),
          child: ShowDetails(
            dataList: selectedItem,
            doRePrint: doRePrint,
            handleUpdate: handleUpdate,
            updatePageInfo: () {
              setState(() {});
            },
            handleShowDetails: handleShowDetails,
          ),
        );
      },
    );
  }

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        _fromDate = picked;
      });
    } else if (select == 'to') {
      setState(() {
        _toDate = picked;
      });
    }

    handleCalculations();
  }

  void onReciptScanned(String field, String reciptQuery) {
    setState(() {
      searchFeild = field;
      query = reciptQuery;

      handleCalculations();
    });
  }

  Future<Map<String, dynamic>> _fetchServerData({
    required int offset,
    required int limit,
    String? sortField,
    bool? sortAscending,
  }) async {
    var sorting = jsonEncoder.convert({
      "$initialSort": (sortAscending ?? true) ? 1 : -1,
    });

    var dbproducts = await apiService.get(
      'sales?filter={"$searchFeild" : {"\$regex" : "${query.toLowerCase()}"}, "handler" : "$selectedAccount", "paymentMethod" : "$paymentMethordToShow", "bank" : "$selectedBank"}&sort=$sorting&startDate=$_fromDate&endDate=$_toDate&skip=$offset&limit=$limit',
    );

    var {
      'sales': sales,
      'handlers': handlers,
      'totalDocuments': totalDocuments,
    } = dbproducts.data;

    List<TableDataModel> data = List.from(sales); // Work on a copy

    // --- Pagination Logic (Mock) ---
    final totalRows = totalDocuments;
    final paginatedData = data.toList();

    return {
      'rows': paginatedData, // Return the list of maps
      'totalRows': totalRows,
    };
  }

  Future<void> handleCalculations() async {
    var dbproducts = await apiService.get(
      'sales?filter={"$searchFeild" : {"\$regex" : "${query.toLowerCase()}"}, "handler" : "$selectedAccount", "paymentMethod" : "$paymentMethordToShow", "bank" : "$selectedBank"}&startDate=$_fromDate&endDate=$_toDate',
    );
    var {
      "summary": summary,
      'handlers': handlers,
      "totalDocuments": totalDocuments,
    } = dbproducts.data;

    double totalSales = summary['totalAmount'].toDouble();
    double transfer = summary['totalTransfer'].toDouble();
    double card = summary['totalCard'].toDouble();
    double cash = summary['totalCash'].toDouble();
    double discount = summary['totalDiscount'].toDouble();
    double profit = summary['totalProfit'].toDouble();
    setState(() {
      loading = false;
      cashiers = ['', ...handlers];
      summaryCalculations = {
        'no_of_sale': totalDocuments,
        'total_sales': totalSales,
        'total_paid': totalSales - transfer,
        'transfer': transfer,
        'card': card,
        'cash': cash,
        'discount': discount,
        'profit': profit,
      };
    });
    return;
  }

  Future<void> getBanks() async {
    banks = [];
    var res = await apiService.get('bank');

    setState(() {
      banks.add({'accountNumber': '', 'name': ''});
      banks.addAll(res.data);
    });
  }

  Future<void> handleSelectBank(String bank) async {
    setState(() {
      selectedBank = bank;
    });

    await handleCalculations();
  }

  Future<void> doRePrint(Map saleData) async {
    final profile = await CapabilityProfile.load();
    _printerService.printData(
      _printerService.printers.firstWhere(
        (printer) => printer.name == getDefaultPrinter(),
        orElse: () => _printerService.printers[0],
      ),
      generateReceipt(PaperSize.mm58, profile, saleData, {}),
    );
  }
  // await apiService.getRequest('/sales/send-whatsapp/${selectedItem["_id"]}');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _printerService.startScan();
    });
    handleCalculations();
    getBanks();
    _columnDefinitions = salesColumnDefinitionMaps
        .map((map) => ColumnDefinition.fromMap(map))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showHeader = !showHeader;
              });
            },
            icon: AnimatedRotation(
              turns: showHeader ? 0.5 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ],
      ),

      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (event) async {
          if (event is KeyDownEvent) {
            // Collect barcode characters
            buffer.write(event.character ?? '');
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              final scannedData = buffer.toString().trim();

              onReciptScanned('barcodeId', scannedData);

              buffer.clear();
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.all(isBigScreen ? 8.0 : 4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AnimatedContainer(
                  width: double.infinity,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  height: showHeader ? 250 : 0,
                  child: Column(
                    children: [
                      IncomeReportsHeader(
                        selectedField: searchFeild,
                        selectedPaymentMethod: paymentMethordToShow,
                        selectedAccount: selectedAccount,
                        isSearchEnabled: true,
                        searchController: _searchController,
                        onFieldChange: (value) {
                          setState(() {
                            searchFeild = value;
                          });
                        },
                        onAccountChange: (value) {
                          setState(() {
                            selectedAccount = value;
                          });
                          handleCalculations();
                        },
                        onPaymentMethodChange: (value) {
                          setState(() {
                            paymentMethordToShow = value;
                          });
                          handleCalculations();
                        },
                        onSearcfieldChange: (value) {
                          searchThroughSales(value);
                        },
                        cashiers: cashiers,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: dateRangeHolder(context, isBigScreen),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Bank',
                                border: OutlineInputBorder(),
                              ),
                              items: banks.map<DropdownMenuItem<String>>((
                                bank,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: bank['accountNumber'].toString(),
                                  child: Text(
                                    bank['name'].toString() == ''
                                        ? 'All'
                                        : bank['name'].toString(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (bank) {
                                handleSelectBank(bank ?? '');
                              },
                              initialValue: selectedAccount,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: isBigScreen ? 450 : 400,
                  child: loading
                      ? Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : layout(isBigScreen, summaryCalculations),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 600,
                        child: loading
                            ? Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : ReusableAsyncPaginatedDataTable(
                                columnDefinitions:
                                    _columnDefinitions, // Pass definitions
                                fetchDataCallback: _fetchServerData,
                                onSelectionChanged: (selected) {
                                  _selectedRows = selected;
                                },
                                header: const Text('Transactions'),
                                initialSortField: initialSort,
                                initialSortAscending: true,
                                rowsPerPage: 15,
                                availableRowsPerPage: const [10, 15, 25, 50],
                                showCheckboxColumn: true,
                                fixedLeftColumns: isBigScreen
                                    ? 2
                                    : 1, // Fix the 'Title' column
                                minWidth:
                                    2200, // Increase minWidth for more columns
                                empty: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                border: TableBorder.all(
                                  color: Colors.grey.shade100,
                                  width: 1,
                                ),
                                columnSpacing: 30,
                                dataRowHeight: 50,
                                headingRowHeight: 60,
                                handleShowDetails: handleShowDetails,
                              ),
                      ),
                    ),
                    isBigScreen
                        ? AnimatedContainer(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: Duration(milliseconds: 600),
                            width: showDetails ? 650.0 : 0.00,
                            child: showDetails
                                ? ShowDetails(
                                    dataList: selectedItem,
                                    doRePrint: doRePrint,
                                    handleUpdate: handleUpdate,
                                    handleShowDetails: handleShowDetails,
                                    updatePageInfo: () {
                                      setState(() {});
                                    },
                                  )
                                : Container(),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container dateRangeHolder(BuildContext context, isBigScreen) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: isBigScreen
          ? Row(
              children: [
                Row(
                  children: [
                    isBigScreen ? Text('From :') : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      tooltip: 'From date',
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: _toDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          handleRangeChange('from', picked);
                        }
                      },
                    ),
                    Text(
                      _fromDate != null
                          ? "${_fromDate!.toLocal()}".split(' ')[0]
                          : "From",
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    isBigScreen ? Text('To :') : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      tooltip: 'To date',
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _toDate ?? DateTime.now(),
                          firstDate: _fromDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          handleRangeChange('to', picked);
                        }
                      },
                    ),
                    Text(
                      _toDate != null
                          ? "${_toDate!.toLocal()}".split(' ')[0]
                          : "To",
                    ),
                  ],
                ),
                Spacer(),
                isBigScreen
                    ? OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _fromDate = DateTime.now();
                            _toDate = DateTime.now();
                          });
                        },
                        child: Text('Reset'),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _fromDate = DateTime.now();
                            _toDate = DateTime.now();
                          });
                        },
                        icon: Icon(Icons.cancel_outlined),
                      ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            tooltip: 'From date',
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: _toDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                handleRangeChange('from', picked);
                              }
                            },
                          ),
                          Text(
                            _fromDate != null
                                ? "${_fromDate!.toLocal()}".split(' ')[0]
                                : "From",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isBigScreen) Text('To :'),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            tooltip: 'To date',
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _toDate ?? DateTime.now(),
                                firstDate: _fromDate ?? DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                handleRangeChange('to', picked);
                              }
                            },
                          ),
                          Text(
                            _toDate != null
                                ? "${_toDate!.toLocal()}".split(' ')[0]
                                : "To",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = DateTime.now();
                      _toDate = DateTime.now();
                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
              ],
            ),
    );
  }

  LayoutBuilder layout(bool isBigScreen, Map data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine how many cards per row based on screen width
        double maxWidth = constraints.maxWidth;
        int cardsPerRow;

        if (maxWidth >= 900) {
          cardsPerRow = 3; // large screen
        } else if (maxWidth >= 600) {
          cardsPerRow = 2; // medium screen
        } else {
          cardsPerRow = 2; // small screen
        }

        // Card width calculation with spacing
        double spacing = 16.0;
        double cardWidth =
            (maxWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'No of Sales',
                icon: Icon(Icons.payments_outlined),
                isFinancial: false,
                amount: data['no_of_sale'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Sales Value',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['total_sales'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Total Paid',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['total_paid'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Transfers',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['transfer'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Card Payments',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['card'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Cash Payments',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['cash'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Discounts',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['discount'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: FinanceCard(
                title: 'Porfit',
                icon: Icon(Icons.payments_outlined),
                isFinancial: true,
                amount: data['profit'],
                fontSize: isBigScreen ? 10 : 5,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        );
      },
    );
  }
}
