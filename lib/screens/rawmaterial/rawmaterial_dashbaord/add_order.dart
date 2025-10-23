import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import '../../../helpers/financial_string_formart.dart';

import '../../../service/api.service.dart';
import '../../../service/toast.service.dart';
import '../../supplier/add_supplier.dart';

class AddOrder extends StatefulWidget {
  final String rawmaterialId;
  final num servingSize;
  final String unit;
  final VoidCallback getUpDate;
  const AddOrder({
    super.key,
    required this.rawmaterialId,
    required this.getUpDate,
    required this.servingSize,
    required this.unit,
  });

  @override
  AddOrderState createState() => AddOrderState();
}

class AddOrderState extends State<AddOrder> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final quantityController = TextEditingController(text: '0');

  final costController = TextEditingController();

  final discountController = TextEditingController();

  final paidController = TextEditingController()..text = '0';

  final notesController = TextEditingController();

  final cashController = TextEditingController()..text = '0';

  final bankController = TextEditingController()..text = '0';

  DateTime selectedExpiryDate = DateTime.now();
  DateTime selectedDeliveryDate = DateTime.now();
  DateTime selectedPurchaseDate = DateTime.now();

  late List suppliers = [];
  late List department = [];
  late List banks = [];
  String toPoint = '';
  late Map<String, dynamic> product;
  String? status = '';
  String? supplier = '';
  String? paymentMethord = 'Bank';
  String perDiff = '';
  num total = 0;
  num totalQunaity = 0;
  bool isLoading = false;
  late String type;
  String bank = '';
  num unitCost = 0;

  @override
  void dispose() {
    quantityController.dispose();
    costController.dispose();
    discountController.dispose();
    paidController.dispose();
    notesController.dispose();
    cashController.dispose();
    bankController.dispose();
    super.dispose();
  }

  Future<void> _selectExpireyDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedExpiryDate) {
      setState(() {
        selectedExpiryDate = picked;
      });
    }
  }

  void calculatePercentage() {
    int cash = int.tryParse(cashController.text) ?? 0;
    int bank = int.tryParse(bankController.text) ?? 0;
    int totalAmountPaid = cash + bank;
    double diff = (totalAmountPaid / total) * 100;
    setState(() {
      paidController.text = totalAmountPaid.toString();
      perDiff = diff.toStringAsFixed(2);
    });
  }

  Future callDialog(debt) => showDialog(
    context: context,
    builder: (BuildContext context) {
      String message;
      if (debt < total) {
        message =
            'This Order Have An Unpaid Balance of ${debt.toString().formatToFinancial(isMoneySymbol: true)}. \nIs That correct ?';
      } else {
        message =
            'No Payment have been made for this Order. \nIs that correct ?';
      }
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false); // Dismiss the dialog
            },
          ),
          TextButton(
            child: Text("Continue"),
            onPressed: () {
              // Perform logout action
              Navigator.of(context).pop(true); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );

  int getTotalPaid() {
    int cash = int.tryParse(cashController.text) ?? 0;
    int bank = int.tryParse(bankController.text) ?? 0;
    int totalAmountPaid = cash + bank;
    return totalAmountPaid;
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDeliveryDate) {
      setState(() {
        selectedDeliveryDate = picked;
      });
    }
  }

  Future<void> _selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPurchaseDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedPurchaseDate) {
      setState(() {
        selectedPurchaseDate = picked;
      });
    }
  }

  Future<void> handleSubmit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      isLoading = true;
    });

    final bool? confirmed;

    if ((total - getTotalPaid()) > 0) {
      confirmed = await callDialog(total - getTotalPaid());

      if (!confirmed!) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }
    showToast('loading...', ToastificationType.info);

    var formData = {
      'rawmaterialId': widget.rawmaterialId,
      'quantity': totalQunaity,
      'unitCost': unitCost,
      'cost': int.tryParse(costController.text) ?? 0,
      'total': total + (int.tryParse(discountController.text) ?? 0),
      'totalPayable': total,
      'purchaseDate': selectedPurchaseDate.toString(),
      'status': status,
      'paymentMethod': paymentMethord,
      'dropOfLocation': toPoint,
      'notes': notesController.text,
      'supplier': supplier,
      'expiryDate': selectedExpiryDate.toString(),
      'cash': int.tryParse(cashController.text) ?? 0,
      'bank': int.tryParse(bankController.text) ?? 0,
      'debt': total - getTotalPaid(),
      'discount': int.tryParse(discountController.text) ?? 0,
      'deliveryDate': selectedDeliveryDate.toString(),
      'createdAt': DateTime.now().toString(),
      'moneyFrom': bank,
    };
    try {
      final dynamic response = await apiService.post('rm-purchases', formData);
      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        widget.getUpDate();
        showToast('Success', ToastificationType.success);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
      isLoading = false;
    } catch (e) {
      if (!mounted) return;
      isLoading = false;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to submit order: ${e.toString()}')),
      );
    }
  }

  Future updateSupplierList() async {
    setState(() {
      isLoading = true;
    });
    var dbsuppliers = await apiService.get('supplier?skip=${suppliers.length}');
    setState(() {
      suppliers.addAll(dbsuppliers.data);
      isLoading = false;
    });
  }

  void calculateTotal() {
    num enteredQuantity = num.tryParse(quantityController.text) ?? 0;
    num totalquantity = enteredQuantity * widget.servingSize;
    num unitprice = 0;
    num cost = num.tryParse(costController.text) ?? 0;
    num totalPrice = cost;
    if (totalquantity > 0) {
      unitprice = cost ~/ totalquantity == 0 ? 1 : totalquantity;
    }

    var discount = num.tryParse(discountController.text) ?? 0;
    setState(() {
      unitCost = unitprice;
      totalQunaity = totalquantity;
      total = totalPrice - discount;
    });
  }

  void doInitalDBCall() async {
    var result = await Future.wait([
      apiService.get('department'),
      apiService.get('supplier'),
      apiService.get('rawmaterial/${widget.rawmaterialId}'),
      apiService.get('bank'),
    ]);
    setState(() {
      department = result[0].data;
      suppliers = result[1].data;
      product = result[2].data;
      banks = result[3].data;
      supplier = '';
      isLoading = false;
    });
  }

  void selectBank(value) {
    setState(() {
      bank = value;
    });
  }

  @override
  void initState() {
    doInitalDBCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> formFields = [
      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        controller: quantityController,
        onChanged: (_) {
          calculateTotal();
        },
        decoration: InputDecoration(
          labelText: 'Quantity',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
        ),
      ),

      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        controller: costController,
        onChanged: (_) {
          calculateTotal();
        },
        decoration: InputDecoration(
          labelText: 'Cost',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Cost Cannot be Empty';
          }
          if (int.parse(value) < 1) {
            return 'Must Be Greater Than 0';
          }
          return null;
        },
      ),

      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        controller: discountController,
        onChanged: (_) {
          calculateTotal();
        },
        decoration: InputDecoration(
          labelText: 'Discount (If any)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
        ),
      ),

      DropdownButtonFormField<String>(
        initialValue: toPoint,
        decoration: InputDecoration(
          labelText: 'Drop Off Point',
          border: OutlineInputBorder(),
        ),
        onChanged: (String? newValue) {
          setState(() {
            toPoint = newValue!;
          });
        },
        items:
            [
              {'title': '', '_id': ''},
              ...department,
            ].map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value['_id'],
                child: Text(capitalizeFirstLetter(value['title'])),
              );
            }).toList(),
        validator: (value) => value == '' ? 'Please select an option' : null,
      ),

      DropdownButtonFormField<String>(
        initialValue: status,
        decoration: InputDecoration(
          labelText: 'Select Status',
          border: OutlineInputBorder(),
        ),
        onChanged: (String? newValue) {
          setState(() {
            status = newValue;
          });
        },
        items: ['', 'Delivered', 'Not Delivered'].map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          },
        ).toList(),
        validator: (value) => value == '' ? 'Please select an option' : null,
      ),

      TextFormField(
        readOnly: true,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.number,
        controller: paidController,
        decoration: InputDecoration(
          hintText: 'Enter 0 if no payment have been made',
          hintStyle: TextStyle(color: Colors.lightBlueAccent, fontSize: 10),
          suffix: Text('$perDiff %', style: TextStyle(fontSize: 15)),
          labelText: 'Amount Paid',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Amount Paid cannot be empty';
          }
          if (int.parse(value) > total) {
            return 'Amount Paid cannot be greater than Price';
          }
          return null;
        },
      ),

      // Product Id

      // paymentMethod
      DropdownButtonFormField<String>(
        initialValue: paymentMethord,
        decoration: InputDecoration(
          labelText: 'Payment Methord',
          border: OutlineInputBorder(),
        ),
        onChanged: (String? newValue) {
          setState(() {
            paymentMethord = newValue;
          });
        },
        items: ['Cash', 'Bank', 'Mixed'].map<DropdownMenuItem<String>>((
          String value,
        ) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        validator: (value) => value == null ? 'Please select an option' : null,
      ),

      AnimatedSize(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: paymentMethord == 'Mixed'
            ? Column(
                children: [
                  PriceAmount(
                    totalAmount: paidController.text,
                    controller: cashController,
                    paymentMethord: paymentMethord,
                    costController: total,
                    calculatePercentage: calculatePercentage,
                    label: 'Cash',
                    banks: banks,
                    bank: bank,
                    selectBank: selectBank,
                  ),
                  SizedBox(height: 10),
                  PriceAmount(
                    totalAmount: paidController.text,
                    controller: bankController,
                    paymentMethord: paymentMethord,
                    costController: total,
                    calculatePercentage: calculatePercentage,
                    label: 'Bank',
                    banks: banks,
                    bank: bank,
                    selectBank: selectBank,
                  ),
                ],
              )
            : paymentMethord == 'Bank'
            ? PriceAmount(
                totalAmount: paidController.text,
                controller: bankController,
                paymentMethord: paymentMethord,
                costController: total,
                calculatePercentage: calculatePercentage,
                label: 'Bank',
                banks: banks,
                bank: bank,
                selectBank: selectBank,
              )
            : paymentMethord == 'Cash'
            ? PriceAmount(
                totalAmount: paidController.text,
                controller: cashController,
                paymentMethord: paymentMethord,
                costController: total,
                calculatePercentage: calculatePercentage,
                label: 'Cash',
                banks: banks,
                bank: bank,
                selectBank: selectBank,
              )
            : SizedBox.shrink(),
      ),

      isLoading
          ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator())
          : DropdownButtonFormField<String>(
              initialValue: supplier,
              decoration: InputDecoration(
                suffix: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return AddSupplier();
                      },
                    );
                  },
                  child: Text('Add Suppler'),
                ),
                labelText: 'Supplier',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  supplier = newValue;
                });
              },
              items:
                  [
                    {"_id": '', 'name': ''},
                    ...suppliers,
                  ].map((value) {
                    return DropdownMenuItem<String>(
                      value: value['_id'],
                      child: Text(value['name']),
                    );
                  }).toList(),
              validator: (value) =>
                  value == '' ? 'Please select an option' : null,
            ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectDeliveryDate(context),
            child: const Text('Select Delivery Date'),
          ),
          Text("${selectedDeliveryDate.toLocal()}".split(' ')[0]),
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectExpireyDate(context),
            child: const Text('Select Expirey Date'),
          ),
          Text("${selectedExpiryDate.toLocal()}".split(' ')[0]),
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectPurchaseDate(context),
            child: const Text('Select Purchase Date'),
          ),
          Text("${selectedPurchaseDate.toLocal()}".split(' ')[0]),
        ],
      ),

      TextFormField(
        maxLines: 5,
        controller: notesController,
        decoration: InputDecoration(
          labelText: 'Add Notes (If any)', //change to location drop down
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Add Order', style: TextStyle(fontSize: 10)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              total.toString().formatToFinancial(isMoneySymbol: true),
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int columns = constraints.maxWidth > 600 ? 3 : 1;
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: formFields.map((field) {
                          return SizedBox(
                            width:
                                constraints.maxWidth / columns -
                                16, // Dynamic width per column
                            child: field,
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            handleSubmit(context);
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PriceAmount extends StatelessWidget {
  const PriceAmount({
    super.key,
    required this.controller,
    required this.paymentMethord,
    required this.costController,
    required this.totalAmount,
    required this.calculatePercentage,
    required this.label,
    required this.banks,
    required this.bank,
    required this.selectBank,
  });

  final TextEditingController controller;
  final String? paymentMethord;
  final num costController;
  final String? totalAmount;
  final Function calculatePercentage;
  final String label;
  final List banks;
  final String bank;
  final Function selectBank;

  @override
  Widget build(BuildContext context) {
    bool isEnabled = true;
    if (label != 'Cash' && bank == '') {
      isEnabled = false;
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            enabled: isEnabled,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            controller: controller,

            onChanged: (String v) {
              calculatePercentage();
            },
            decoration: InputDecoration(
              labelText: label,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              labelStyle: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 15,
              ),
            ),
            validator: (value) {
              if (paymentMethord == 'Cash' || paymentMethord == 'Bank') {
                if (value == null || value.isEmpty) {
                  return 'Please enter the $paymentMethord';
                }

                if (int.parse(value) > costController) {
                  return 'That\'s more than the purchase cost';
                }
              }

              if (paymentMethord == 'Mixed') {}

              return null;
            },
          ),
        ),
        if (label != 'Cash')
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: bank,
              decoration: InputDecoration(
                labelText: 'Banks',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                selectBank(newValue);
              },
              items:
                  [
                    {'_id': '', 'name': '', 'accountNumber': ''},
                    ...banks,
                  ].map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value['accountNumber'],
                      child: Text(capitalizeFirstLetter(value['name'])),
                    );
                  }).toList(),
              validator: (value) => (value == '' && label != 'Cash')
                  ? 'Please select an option'
                  : null,
            ),
          ),
      ],
    );
  }
}
