import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:toastification/toastification.dart';

import '../../components/tables/custom_data_table.dart';
import '../../service/api.service.dart';
import '../../service/date_range_helper.dart';

@RoutePage()
class CashStatementScreen extends StatefulWidget {
  const CashStatementScreen({super.key});

  @override
  CashStatementState createState() => CashStatementState();
}

class CashStatementState extends State<CashStatementScreen> {
  ApiService apiService = ApiService();
  final formKey = GlobalKey<FormState>();
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  String direction = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final JsonEncoder jsonEncoder = JsonEncoder();

  late List banks = [];
  late List cashflow = [];
  String bank = '';
  late Map selectedBank = {};
  num moneyIn = 0;
  num moneyOut = 0;
  num finalBalace = 0;
  num openingBalace = 0;

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
        cashflow = [];
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
        cashflow = [];
      });
    }
    getCashFlow();
  }

  void handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
    });
    getCashFlow();
  }

  Future<void> handleFilter(value) async {
    if (value != null) {
      setState(() {
        selectedBank = banks.firstWhere(
          (element) => element['accountNumber'] == value,
          orElse: () => {
            'name': 'Cash',
            'accountNumber': '',
            'accountName': '',
          },
        );

        bank = value;
      });
    }
    getCashFlow();
  }

  Future<void> getBanks() async {
    banks = [];
    var dbBanks = await apiService.get(
      'bank?select=" name accountNumber accountName "',
    );
    setState(() {
      banks = dbBanks.data;
    });
  }

  Future<void> getCashFlow() async {
    var cashFlow = await apiService.get(
      'cashflow?filter={"moneyFrom": "$bank"}&startDate=$startDate&endDate=$endDate',
    );
    setState(() {
      cashflow = cashFlow.data['transactions'];
      finalBalace = cashFlow.data['transactions'].isEmpty
          ? 0
          : cashFlow.data['transactions'].last['balanceAfter'];
      openingBalace = cashFlow.data['openingBalance'] ?? 0;
      sumByType(cashFlow.data['transactions']);
    });
  }

  void sumByType(List items) {
    double totalIn = 0.0;
    double totalOut = 0.0;

    for (var item in items) {
      final amount = item['amount'];
      final type = item['type'];

      if (amount is num) {
        if (type == "in") {
          totalIn += amount.toDouble();
        } else if (type == "out") {
          totalOut += amount.toDouble();
        }
      }
    }
    setState(() {
      moneyIn = totalIn;
      moneyOut = totalOut;
    });
  }

  Future<void> submitTransaction() async {
    showToast('Adding', ToastificationType.info);
    if (formKey.currentState!.validate()) {
      var data = {
        'title': descController.text,
        'paymentFor': categoryController.text,
        "cash": selectedBank["accountNumber"] == '' ? amountController.text : 0,
        "bank": selectedBank["accountNumber"] != '' ? amountController.text : 0,
        'type': direction,
        'moneyFrom': selectedBank["accountNumber"],
        'transactionDate': DateTime.now().toString(),
      };
      await apiService.post('cashflow', data);
      showToast('Added', ToastificationType.success);
      Navigator.pop(context);
    }
  }

  void clearForm() {
    descController.clear();
    amountController.clear();
    categoryController.clear();
  }

  @override
  void initState() {
    getBanks();
    super.initState();
  }

  @override
  void dispose() {
    descController.dispose();
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: DateRangeHolder(
          fromDate: startDate,
          toDate: endDate,
          handleRangeChange: handleRangeChange,
          handleDateReset: handleDateReset,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              handleFilter(value);
            },
            itemBuilder: (context) =>
                [
                      {'name': 'Cash', 'accountNumber': ''},
                      ...banks,
                    ]
                    .map(
                      (item) => PopupMenuItem(
                        value: item['accountNumber'] as String,
                        child: Text(capitalizeFirstLetter(item['name'])),
                      ),
                    )
                    .toList(),
            offset: const Offset(0, 40), // dropdown below button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // pill shape
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: null, // handled by PopupMenuButton
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.food_bank_outlined, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    selectedBank['name'] ?? '',
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down, size: 10),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        mini: true,
        useRotationAnimation: true,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.upload_outlined),
            label: 'Deposit',
            onTap: () {
              direction = 'in';
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // makes sheet full height if needed
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return TransactionForm(
                    direction: 'in',
                    formKey: formKey,
                    descController: descController,
                    amountController: amountController,
                    categoryController: categoryController,
                    amount: finalBalace,
                    submitTransaction: submitTransaction,
                    clearForm: clearForm,
                  );
                },
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.download_outlined),
            label: 'Withdraw',
            onTap: () {
              direction = 'out';
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // makes sheet full height if needed
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return TransactionForm(
                    direction: 'out',
                    formKey: formKey,
                    descController: descController,
                    amountController: amountController,
                    categoryController: categoryController,
                    amount: finalBalace,
                    submitTransaction: submitTransaction,
                    clearForm: clearForm,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  smallScreen ? SizedBox() : Expanded(child: SizedBox()),
                  Expanded(
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Account Name : \n${selectedBank["accountName"]}',
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Account Number : \n${selectedBank["accountNumber"]}',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  smallScreen ? SizedBox() : Expanded(child: SizedBox()),
                  Expanded(
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Opening Balance',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                openingBalace.toString().formatToFinancial(
                                  isMoneySymbol: true,
                                ),
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Closing Balance',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                finalBalace.toString().formatToFinancial(
                                  isMoneySymbol: true,
                                ),
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            smallScreen
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Money In',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  moneyIn.toString().formatToFinancial(
                                    isMoneySymbol: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Money Out',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  moneyOut.toString().formatToFinancial(
                                    isMoneySymbol: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Money In',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  moneyIn.toString().formatToFinancial(
                                    isMoneySymbol: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Money Out',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  moneyOut.toString().formatToFinancial(
                                    isMoneySymbol: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            CustomDataTable(
              columns: const [
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      'Date/Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      'Money In',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      'Money out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 300,
                    child: Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      'Balance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              data: cashflow,
              cellBuilder: (flow) => [
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      formatBackendTime(flow['createdAt']),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      flow['type'] == 'in'
                          ? flow['amount'].toString().formatToFinancial(
                              isMoneySymbol: true,
                            )
                          : '-',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      flow['type'] == 'out'
                          ? flow['amount'].toString().formatToFinancial(
                              isMoneySymbol: true,
                            )
                          : '-',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(flow['title'], style: TextStyle(fontSize: 10)),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      flow['balanceAfter'].toString().formatToFinancial(
                        isMoneySymbol: true,
                      ),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionForm extends StatelessWidget {
  final String direction;
  final num amount;
  final GlobalKey formKey;
  final TextEditingController descController;
  final TextEditingController amountController;
  final TextEditingController categoryController;
  final Function submitTransaction;
  final Function clearForm;
  const TransactionForm({
    super.key,
    required this.formKey,
    required this.descController,
    required this.amountController,
    required this.categoryController,
    required this.direction,
    required this.amount,
    required this.submitTransaction,
    required this.clearForm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // keyboard safe
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                "Add Transaction",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter description" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Payment For",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please Fill Here" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter amount";
                  }
                  if (int.tryParse(value) == null) {
                    return "Amount Must Be Number";
                  }
                  if (direction == 'out' && int.parse(value) > amount) {
                    return "Not Enough Money For That";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        clearForm();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Clear"),
                    ),
                  ),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        submitTransaction();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Save Transaction"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
