import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../app_router.gr.dart';
import '../../helpers/financial_string_formart.dart';

import '../../service/api.service.dart';
import '../../service/defaultprinter.service.dart';
import '../../service/printer.service.dart';
import '../../service/receipt_holder.dart';
import '../customers/add_customer.dart';

@RoutePage()
class CheckoutScreen extends StatefulWidget {
  final double total;
  final List cart;
  final Function handleComplete;
  final Map? selectedBank;
  final Map? selectedUser;
  final num? discount;
  final String? invoiceId;

  const CheckoutScreen({
    super.key,
    required this.total,
    required this.cart,
    required this.handleComplete,
    this.selectedBank,
    this.selectedUser,
    this.discount,
    this.invoiceId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ApiService apiService = ApiService();

  String selectedPaymentMethod = 'cash';
  Map? bank;

  final TextEditingController cashController = TextEditingController();
  final TextEditingController transferController = TextEditingController();
  final TextEditingController cardController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final PrinterService _printerService = PrinterService();

  Map? selectedName;
  bool isChargesLoading = true;
  double amountPaid = 0;
  double balance = 0;
  double discount = 0;
  bool isBankLoading = true;
  Map charge = {};
  late dynamic charges;
  List<Map> selectedCharges = [];
  late double total;
  bool isPaid = false;
  late Map newTransaction;

  // Mock bank data - replace with your backend data
  List<dynamic> banks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _printerService.startScan();
    });
    total = widget.total;
    fetchCharges();
    if (widget.selectedUser != null) {
      selectedName = widget.selectedUser;
    }

    if (widget.discount != null) {
      discountController.text = widget.discount.toString();
      discount = widget.discount!.toDouble();
    }

    if (widget.selectedBank != null) {
      bank = widget.selectedBank;
      selectedPaymentMethod = 'transfer';
    }
    updateBankList();
    _updateAmountPaid();
  }

  Future updateBankList() async {
    if (widget.selectedBank == null) {
      setState(() {
        isBankLoading = true;
      });
      var dbbanks = await apiService.get('bank?skip=${banks.length}');
      setState(() {
        banks = dbbanks.data;
        if (banks.isNotEmpty) {
          bank = banks[0];
        }

        isBankLoading = false;
      });
    } else {
      setState(() {
        banks.add(widget.selectedBank);
      });
    }
  }

  doShowToast(String toastMessage, ToastificationType type) {
    toastification.show(
      title: Text(toastMessage),
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  void fetchCharges() async {
    var response = await apiService.get('charges');

    setState(() {
      charges = response.data;
      isChargesLoading = false;
      if (charges.isNotEmpty) {
        charge = charges[0];
      }
    });
  }

  void _updateAmountPaid() {
    setState(() {
      discount = double.tryParse(discountController.text) ?? 0;
      amountPaid =
          (double.tryParse(cashController.text) ?? 0) +
          (double.tryParse(transferController.text) ?? 0) +
          (double.tryParse(cardController.text) ?? 0.0) +
          discount;
      balance = total - amountPaid;
    });
  }

  void handleSubit() async {
    // Validate total amount matches
    if (amountPaid < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Amount paid must equal or exceed total amount'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Validate bank is selected for transfer payment
    if ((selectedPaymentMethod == 'transfer' ||
            selectedPaymentMethod == 'mixed') &&
        double.tryParse(transferController.text) != null &&
        double.parse(transferController.text) > 0 &&
        bank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a bank for transfer payment'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    var paymentData = {
      'total': total,
      'discount': discount,
      'paymentMethod': selectedPaymentMethod,
      'cash': double.tryParse(cashController.text) ?? 0,
      'transfer': double.tryParse(transferController.text) ?? 0,
      'card': double.tryParse(cardController.text) ?? 0,
      'bank': bank?['_id'],
      'products': widget.cart,
      'customer': selectedName?['_id'],
      'charges': selectedCharges,
      'transactionDate': DateTime.now().toString(),
      'invoiceId': widget.invoiceId,
    };
    // Capture the context before the async gap
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    var responce = await apiService.post('sales', paymentData);

    // Check if widget is still mounted before showing message
    if (!mounted) return;

    // Use captured scaffoldMessenger
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Payment processed successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    if (widget.invoiceId != null) {
      widget.handleComplete(widget.invoiceId, responce.data);
    } else {
      widget.handleComplete();
    }
    setState(() {
      isPaid = true;
      newTransaction = responce.data;
    });
  }

  Future<List<Map>> _fetchNames(String query) async {
    final response = await apiService.get(
      'customer?filter={"nameOrPhonenumber": "${nameController.text}"}',
    );
    if (response.statusCode == 200) {
      return List<Map>.from(response.data);
    } else {
      throw Exception('Failed to load names');
    }
  }

  void _showAddCustomerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddCustomer(updateCustomer: _fetchNames);
      },
    );
  }

  void saveReceipt() async {
    await apiService.get('sales/send-whatsapp/${newTransaction['_id']}');
  }

  void updateBankByAccountNumber(String accountNumber) {
    if (accountNumber.isNotEmpty) {
      final matchingBank = banks.firstWhere(
        (bank) => bank['accountNumber'] == accountNumber,
        orElse: () => null,
      );
      if (matchingBank != null) {
        setState(() {
          bank = matchingBank;
        });
      }
    }
  }

  @override
  void dispose() {
    _printerService.dispose();
    cashController.dispose();
    transferController.dispose();
    cardController.dispose();
    discountController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(fontSize: 10)),
        leading: IconButton(
          onPressed: () {
            if (widget.invoiceId != null) {
              context.router.replaceAll([ViewInvoices()]);
            } else {
              context.router.replaceAll([MakeSaleRoute()]);
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          final padding = isDesktop ? 32.0 : 16.0;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(padding),
                constraints: BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildPaymentMethodCard(context, isDesktop),
                                    SizedBox(height: 10),
                                    _buildChargesList(),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(child: _buildSummaryCard(context)),
                            ],
                          )
                        : Column(
                            children: [
                              _buildPaymentMethodCard(context, isDesktop),
                              SizedBox(height: 20),
                              _buildSummaryCard(context),
                              _buildChargesList(),
                            ],
                          ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: isDesktop
                          ? constraints.maxWidth / 2
                          : double.infinity,
                      height: 50,
                      child: isPaid
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    final profile =
                                        await CapabilityProfile.load();
                                    _printerService.printData(
                                      _printerService.printers.firstWhere(
                                        (printer) =>
                                            printer.name == getDefaultPrinter(),
                                        orElse: () =>
                                            _printerService.printers[0],
                                      ),
                                      generateReceipt(
                                        PaperSize.mm58,
                                        profile,
                                        newTransaction,
                                        {},
                                      ),
                                    );
                                  },
                                  child: Text('Print Receipt'),
                                ),
                                // OutlinedButton(
                                //     onPressed: () {
                                //       saveReceipt();
                                //     },
                                //     child: Text('Send Receipt'))
                              ],
                            )
                          : ElevatedButton(
                              onPressed: balance == 0
                                  ? () {
                                      handleSubit();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: balance == 0
                                    ? null
                                    : Colors.red,
                                disabledBackgroundColor: Colors.red,
                              ),
                              child: Text('Complete Payment'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameInput() {
    return selectedName == null
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      tooltip: 'Add new Customer',
                      onPressed: _showAddCustomerBottomSheet,
                      icon: Icon(Icons.person_add_alt_1_outlined),
                    ),
                  ),
                ],
              ),
              if (nameController.text.isNotEmpty)
                FutureBuilder<List<Map>>(
                  future: _fetchNames(nameController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('No suggestions'),
                      );
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion['name']),
                            subtitle: Text(suggestion['phone_number']),
                            trailing: Text(
                              suggestion['total_spent']
                                  .toString()
                                  .formatToFinancial(isMoneySymbol: true),
                            ),
                            onTap: () {
                              setState(() {
                                selectedName = suggestion;
                                nameController.clear();
                              });
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
            ],
          )
        : Chip(
            label: Text(selectedName?['name']),
            deleteIcon: widget.selectedUser == null
                ? Icon(Icons.close)
                : Icon(Icons.check_box_outlined),
            onDeleted: () {
              setState(() {
                if (widget.selectedUser == null) {
                  selectedName = null;
                } else {}
              });
            },
          );
  }

  Widget _buildPaymentInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: (label == 'Transfer' || label == 'Card') && bank == null
                  ? 'Select bank first'
                  : '',
              child: TextField(
                controller: controller,
                enabled:
                    !((label == 'Transfer' || label == 'Card') && bank == null),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  _updateAmountPaid();
                },
                decoration: InputDecoration(
                  labelText: '$label Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefix: Text('₦ '),
                ),
              ),
            ),
          ),
          if (label == 'Transfer' || label == 'Card') ...[
            SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: bank?['accountNumber'],
                decoration: InputDecoration(
                  labelText: 'Select Bank',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text('Select Bank')),
                  ...banks.map(
                    (bank) => DropdownMenuItem(
                      value: bank['accountNumber'],
                      child: Text(bank['name']!),
                    ),
                  ),
                ],
                onChanged: (value) {
                  updateBankByAccountNumber(value!);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Charges:', style: Theme.of(context).textTheme.titleSmall),
                isChargesLoading
                    ? SizedBox(child: CircularProgressIndicator())
                    : SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<Map>(
                          isExpanded: true,
                          value: charge[0],
                          items: charges
                              .map<DropdownMenuItem<Map>>(
                                (charge) => DropdownMenuItem<Map>(
                                  value: charge,
                                  child: Text(
                                    '${charge['title']} (₦${charge['amount'].toString()})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (selectedCharge) {
                            setState(() {
                              if (selectedCharge != null) {
                                // Add charge amount to total
                                charge = selectedCharge;
                                selectedCharges.add(selectedCharge);
                                total += selectedCharge['amount'];
                                _updateAmountPaid();
                              } else {
                                charge = {};
                              }
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                          ),
                          hint: Text('Select Charge'),
                        ),
                      ),
              ],
            ),
            SizedBox(height: 10),
            _buildSummaryRow('Total Amount:', total, context),
            SizedBox(height: 10),
            _buildSummaryRow('Amount Paid:', amountPaid, context),
            Divider(),
            SizedBox(height: 10),
            _buildDiscountRow(context),
            SizedBox(height: 10),
            _buildSummaryRow('Balance:', balance, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        Text(amount.toStringAsFixed(2).formatToFinancial(isMoneySymbol: true)),
      ],
    );
  }

  Widget _buildDiscountRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Discount:', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(
          width: 150,
          child: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (value) => _updateAmountPaid(),
            decoration: InputDecoration(
              prefix: Text('₦ '),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'mixed', child: Text('Mixed Payment')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            SizedBox(height: 20),
            if (selectedPaymentMethod == 'cash' ||
                selectedPaymentMethod == 'mixed')
              Column(children: [_buildPaymentInput('Cash', cashController)]),
            if (selectedPaymentMethod == 'transfer' ||
                selectedPaymentMethod == 'mixed')
              Column(
                children: [_buildPaymentInput('Transfer', transferController)],
              ),
            if (selectedPaymentMethod == 'card' ||
                selectedPaymentMethod == 'mixed')
              Column(children: [_buildPaymentInput('Card', cardController)]),
            _buildNameInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChargesList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: selectedCharges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // two per row
        childAspectRatio: 5, // adjust as needed for your card size
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _buildCharge(selectedCharges[index], index);
      },
    );
  }

  Widget _buildCharge(Map charge, index) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${charge['title']}'),
          Row(
            children: [
              Text(
                charge['amount'].toString().formatToFinancial(
                  isMoneySymbol: true,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    total -= selectedCharges[index]['amount'];
                    selectedCharges.removeAt(index);
                    _updateAmountPaid();
                  });
                },
                icon: Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
