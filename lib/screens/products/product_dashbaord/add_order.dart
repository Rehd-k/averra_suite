import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../helpers/financial_string_formart.dart';

import '../../../service/api.service.dart';
import '../../supplier/add_supplier.dart';

class AddOrder extends StatefulWidget {
  final String productId;
  final VoidCallback getUpDate;
  final String type;
  const AddOrder({
    super.key,
    required this.productId,
    required this.getUpDate,
    required this.type,
  });

  @override
  AddOrderState createState() => AddOrderState();
}

class AddOrderState extends State<AddOrder> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final quanitityController = TextEditingController();

  final priceController = TextEditingController();

  final discountController = TextEditingController();

  final shippingAddressController = TextEditingController();

  final paidController = TextEditingController();

  final paymentMethodController = TextEditingController();

  final notesController = TextEditingController();

  final initiatorController = TextEditingController();

  final cashController = TextEditingController()..text = '0';

  final transferController = TextEditingController()..text = '0';

  final cardController = TextEditingController()..text = '0';

  final cartonPrice = TextEditingController();

  DateTime selectedExpiryDate = DateTime.now();

  DateTime selectedDeliveryDate = DateTime.now();

  DateTime selectedPurchaseDate = DateTime.now();

  late List suppliers = [];

  String? status = 'Not Delivered';

  String? supplier = '';

  String? paymentMethord = 'Transfer';

  String perDiff = '';

  bool isSuppliersLoading = true;

  int total = 0;

  bool isLoading = false;

  @override
  void dispose() {
    quanitityController.dispose();
    priceController.dispose();
    discountController.dispose();
    shippingAddressController.dispose();
    paidController.dispose();
    paymentMethodController.dispose();
    notesController.dispose();
    initiatorController.dispose();
    cartonPrice.dispose();
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
    int card = int.tryParse(cardController.text) ?? 0;
    int transfer = int.tryParse(transferController.text) ?? 0;
    int totalAmountPaid = cash + card + transfer;
    double diff = (totalAmountPaid / total) * 100;
    setState(() {
      paidController.text = totalAmountPaid.toString();
      perDiff = diff.toStringAsFixed(2);
    });
  }

  int getTotalPaid() {
    int cash = int.tryParse(cashController.text) ?? 0;
    int card = int.tryParse(cardController.text) ?? 0;
    int transfer = int.tryParse(transferController.text) ?? 0;
    int totalAmountPaid = cash + card + transfer;
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
    isLoading = true;

    var formData = {
      'initiator': initiatorController.text,
      'productId': widget.productId,
      'quantity': int.tryParse(quanitityController.text) ?? 0,
      'price': int.tryParse(priceController.text) ?? 0,
      'total': total + (int.tryParse(discountController.text) ?? 0),
      'totalPayable': total,
      'purchaseDate': selectedPurchaseDate.toString(),
      'status': status,
      'paymentMethod': paymentMethodController.text,
      'shippingAddress': shippingAddressController.text,
      'notes': notesController.text,
      'supplier': supplier,
      'expiryDate': selectedExpiryDate.toString(),
      'transfer': int.tryParse(transferController.text) ?? 0,
      'cash': int.tryParse(cashController.text) ?? 0,
      'card': int.tryParse(cardController.text) ?? 0,
      'debt': total - getTotalPaid(),
      'discount': int.tryParse(discountController.text) ?? 0,
      'deliveryDate': selectedDeliveryDate.toString(),
      'createdAt': DateTime.now().toString(),
      'cartonPrice': int.tryParse(cartonPrice.text) ?? 0,
    };
    try {
      final dynamic response = await apiService.post('purchases', formData);

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        widget.getUpDate();

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

  Future getSuppliersList() async {
    var dbsuppliers = await apiService.get('supplier');

    setState(() {
      suppliers = dbsuppliers.data;
      supplier = suppliers.isNotEmpty ? suppliers[0]['_id'] : '';
      isSuppliersLoading = false;
    });
  }

  Future updateSupplierList() async {
    setState(() {
      isSuppliersLoading = true;
    });
    var dbsuppliers = await apiService.get('supplier?skip=${suppliers.length}');
    setState(() {
      suppliers.addAll(dbsuppliers.data);
      isSuppliersLoading = false;
    });
  }

  void calculateTotal() {
    var quant = int.tryParse(quanitityController.text) ?? 0;
    var price = int.tryParse(priceController.text) ?? 0;
    var discount = int.tryParse(discountController.text) ?? 0;
    setState(() {
      total = (quant * price) - discount;
    });
  }

  @override
  void initState() {
    getSuppliersList();
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
        controller: quanitityController,
        onChanged: (_) {
          calculateTotal();
        },
        decoration: InputDecoration(
          labelText: 'Quanitity *',
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
            return 'Please enter the Quanitity';
          }
          if (int.parse(value) < 1) {
            return 'Quanitity cannot be less than 1';
          }
          return null;
        },
      ),

      widget.type != 'unit'
          ? TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: cartonPrice,
              onChanged: (_) {
                calculateTotal();
              },
              decoration: InputDecoration(
                hintText: "Put 0 if it's free",
                hintStyle: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 10,
                ),
                labelText: '${widget.type} Purchase Price *',
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
                  return '${widget.type} Price cannot be empty';
                }
                return null;
              },
            )
          : SizedBox.shrink(),

      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        controller: priceController,
        onChanged: (_) {
          calculateTotal();
        },
        decoration: InputDecoration(
          hintText: "Put 0 if it's free",
          hintStyle: TextStyle(color: Colors.lightBlueAccent, fontSize: 10),
          labelText: 'Purchase Price *',
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
            return ' cannot be empty';
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

      TextFormField(
        controller: shippingAddressController,
        decoration: InputDecoration(
          labelText: 'Shipping Address', //change to location drop down
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
        value: status,
        decoration: InputDecoration(
          labelText: 'Select Status',
          border: OutlineInputBorder(),
        ),
        onChanged: (String? newValue) {
          setState(() {
            status = newValue;
          });
        },
        items: ['Delivered', 'Not Delivered'].map<DropdownMenuItem<String>>((
          String value,
        ) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        validator: (value) => value == null ? 'Please select an option' : null,
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

      // paymentMethodController
      DropdownButtonFormField<String>(
        value: paymentMethord,
        decoration: InputDecoration(
          labelText: 'Payment Methord',
          border: OutlineInputBorder(),
        ),
        onChanged: (String? newValue) {
          setState(() {
            paymentMethord = newValue;
          });
        },
        items: ['Cash', 'Card', 'Transfer', 'Mixed']
            .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            })
            .toList(),
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
                    priceController: total,
                    calculatePercentage: calculatePercentage,
                    label: 'Cash',
                  ),
                  SizedBox(height: 10),
                  PriceAmount(
                    totalAmount: paidController.text,
                    controller: cardController,
                    paymentMethord: paymentMethord,
                    priceController: total,
                    calculatePercentage: calculatePercentage,
                    label: 'Card',
                  ),
                  SizedBox(height: 10),
                  PriceAmount(
                    totalAmount: paidController.text,
                    controller: transferController,
                    paymentMethord: paymentMethord,
                    priceController: total,
                    calculatePercentage: calculatePercentage,
                    label: 'Transfer',
                  ),
                ],
              )
            : paymentMethord == 'Transfer'
            ? PriceAmount(
                totalAmount: paidController.text,
                controller: transferController,
                paymentMethord: paymentMethord,
                priceController: total,
                calculatePercentage: calculatePercentage,
                label: 'Transfer',
              )
            : paymentMethord == 'Card'
            ? PriceAmount(
                totalAmount: paidController.text,
                controller: cardController,
                paymentMethord: paymentMethord,
                priceController: total,
                calculatePercentage: calculatePercentage,
                label: 'Card',
              )
            : paymentMethord == 'Cash'
            ? PriceAmount(
                totalAmount: paidController.text,
                controller: cashController,
                paymentMethord: paymentMethord,
                priceController: total,
                calculatePercentage: calculatePercentage,
                label: 'Cash',
              )
            : SizedBox.shrink(),
      ),

      isSuppliersLoading
          ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator())
          : DropdownButtonFormField<String>(
              value: supplier,
              decoration: InputDecoration(
                suffix: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return AddSupplier(updateSupplier: updateSupplierList);
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
              items: suppliers.map((value) {
                return DropdownMenuItem<String>(
                  value: value['_id'],
                  child: Text(value['name']),
                );
              }).toList(),
              validator: (value) =>
                  value == null ? 'Please select an option' : null,
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
        title: Text('Add Order'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              total.toString().formatToFinancial(isMoneySymbol: true),
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
                          handleSubmit(context);
                          if (_formKey.currentState!.validate()) {
                            // Process data
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')),
                            );
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
    required this.priceController,
    required this.totalAmount,
    required this.calculatePercentage,
    required this.label,
  });

  final TextEditingController controller;
  final String? paymentMethord;
  final int priceController;
  final String? totalAmount;
  final Function calculatePercentage;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
        labelStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 15),
      ),
      validator: (value) {
        if (paymentMethord == 'Cash' ||
            paymentMethord == 'Card' ||
            paymentMethord == 'Transfer') {
          if (value == null || value.isEmpty) {
            return 'Please enter the $paymentMethord';
          }

          if (int.parse(value) > priceController) {
            return 'That\'s more than the purchase price';
          }
        }

        if (paymentMethord == 'Mixed') {}

        return null;
      },
    );
  }
}
