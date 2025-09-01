import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../service/api.service.dart';

class MakePurchacePayments extends StatefulWidget {
  final Map purchaseInfo;
  const MakePurchacePayments({super.key, required this.purchaseInfo});

  @override
  MakePurchacePaymentsState createState() => MakePurchacePaymentsState();
}

class MakePurchacePaymentsState extends State<MakePurchacePayments> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late List banks = [];
  bool isLoading = true;
  String selectedBank = '';
  String selectedPaymentMethod = 'cash';
  late Map purchaseInfo;
  DateTime selectedPaymentDate = DateTime.now();
  final TextEditingController amountController = TextEditingController();

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPaymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedPaymentDate) {
      setState(() {
        selectedPaymentDate = picked;
      });
    }
  }

  Future getBanksList() async {
    try {
      var dbbanks = await apiService.get('bank');

      setState(() {
        banks = dbbanks.data;
        isLoading = false;
      });
    } catch (e) {
      toastification.show(
        title: Text('Error, Failed to Load Banks'),
        description: Text("Close Drawer and open again to reload"),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
  }

  Future createPayment() async {
    var payment = {
      'title': 'Purchase Payment',
      'paymentFor': purchaseInfo['_id'],
      'cash': selectedPaymentMethod == 'cash'
          ? int.tryParse(amountController.text) ?? 0
          : 0,
      'bank': selectedPaymentMethod == 'bank'
          ? int.tryParse(amountController.text) ?? 0
          : 0,
      'moneyFrom': selectedBank,
      'transactionDate': selectedPaymentDate.toIso8601String(),
    };
    try {
      await apiService.post('purchases/make-payment', payment);
      toastification.show(
        title: Text('Success, Payment Posted'),
        description: null,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    } catch (e) {
      toastification.show(
        title: Text('Error, Failed Post Payment'),
        description: Text("$e Try Again"),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    purchaseInfo = widget.purchaseInfo;
    getBanksList();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Text(
            purchaseInfo['debt'].toString().formatToFinancial(
              isMoneySymbol: true,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              !isLoading
                  ? Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: 'Select Payment Methord',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              labelStyle: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 15,
                              ),
                            ),
                            value: selectedPaymentMethod,
                            items: [
                              DropdownMenuItem(
                                value: 'cash',
                                child: Text('Cash'),
                              ),
                              DropdownMenuItem(
                                value: 'bank',
                                child: Text('Bank'),
                              ),
                            ],

                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value.toString();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        if (selectedPaymentMethod == 'bank')
                          Expanded(
                            child: DropdownButtonFormField(
                              value: selectedBank.isEmpty ? null : selectedBank,
                              decoration: InputDecoration(
                                labelText: 'Select Bank',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 15,
                                ),
                              ),
                              items:
                                  [
                                        {
                                          '_id': '',
                                          'name': 'No Selection',
                                          'accountNumber': '',
                                        },
                                        ...banks,
                                      ]
                                      .where((c) => c.isNotEmpty)
                                      .map<DropdownMenuItem<String>>((bank) {
                                        return DropdownMenuItem<String>(
                                          value: bank['accountNumber'],
                                          child: Text(bank['name']),
                                        );
                                      })
                                      .toList(),
                              validator: (value) =>
                                  value == '' && selectedPaymentMethod == 'bank'
                                  ? 'Please select an option'
                                  : null,
                              onChanged: (value) {
                                setState(() {
                                  selectedBank = value ?? '';
                                });
                              },
                            ),
                          ),
                      ],
                    )
                  : CircularProgressIndicator(),
              SizedBox(height: 10),

              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final intValue = int.tryParse(newValue.text) ?? 0;
                    final maxValue = purchaseInfo['debt'] is int
                        ? purchaseInfo['debt']
                        : int.tryParse(purchaseInfo['debt'].toString()) ?? 0;
                    if (intValue < 0) {
                      return oldValue;
                    }
                    if (intValue > maxValue) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
                controller: amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the a value';
                  }
                  if (int.parse(value) < 1) {
                    return 'Enter A Value';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  helperText: 'Max: ${purchaseInfo['debt']}',
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => _selectDeliveryDate(context),
                    child: const Text('Select Transaction Date'),
                  ),
                  Text("${selectedPaymentDate.toLocal()}".split(' ')[0]),
                ],
              ),
              SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    createPayment();
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    50,
                  ), // Set minimum width to fill parent, and a desired height
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
