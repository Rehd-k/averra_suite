import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/inputs/customer_finder.dart';
import '../../components/inputs/product_finder.dart';
import '../../helpers/financial_string_formart.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import '../../service/invoice.pdf.dart';

@RoutePage()
class AddInvoice extends StatefulWidget {
  const AddInvoice({super.key});

  @override
  AddInvoiceState createState() => AddInvoiceState();
}

class AddInvoiceState extends State<AddInvoice> {
  List<FocusNode> focusNodes = [];
  final List<String> taxes = List.generate(10, (index) => 'Tax $index');
  final TextEditingController productController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  List<TextEditingController> quantityControllers = [];

  String? selectedCustomer;

  DateTime issueDate = DateTime.now();
  DateTime dueDate = DateTime.now();

  String referenceNumber = 'INV-001';
  String? isRecurring = 'none';
  String? selectedTemplate;
  List<Map> selectedProducts = [];
  String? discountType = '';
  double discountValue = 0;
  double receivedAmount = 0;
  ApiService apiService = ApiService(); // Assuming you have an ApiService class
  List filteredProducts = [];
  Map? selectedName;
  bool isBankLoading = true;
  List<dynamic> banks = [];
  Map? bank;

  Future<List<Map>> _fetchProducts(String query) async {
    final response = await apiService.get(
      'products?filter={"isAvailable" : true, "title": {"\$regex": "$query"}}&sort={"title": 1}&limit=20&skip=0&select=" title price quantity type cartonAmount "',
    );
    var {"products": products, "totalDocuments": totalDocuments} =
        response.data;
    if (response.statusCode == 200) {
      return List<Map>.from(products);
    } else {
      throw Exception('Failed to load names');
    }
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

  void updateQuantity(int index, int? newQuantity) {
    setState(() {
      if (newQuantity! <= selectedProducts[index]['remaining']) {
        selectedProducts[index]['quantity'] = newQuantity;
        selectedProducts[index]['total'] =
            selectedProducts[index]['quantity'] *
            selectedProducts[index]['price'];
        quantityControllers[index].text = newQuantity.toString();
      } else {
        toastification.show(
          title: Text('Nope Finished'),
          type: ToastificationType.info,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }

      if (newQuantity == 0) {
        selectedProducts.removeAt(index);
        quantityControllers.removeAt(index);
      }
    });
  }

  void handleSave(String shouldShare) async {
    // Validate required fields
    if (selectedName == null ||
        selectedProducts.isEmpty ||
        referenceNumber.isEmpty) {
      toastification.show(
        title: Text('Error'),
        description: Text('Please fill in all required fields.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    toastification.show(
      title: Text('Loading...'),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
    );

    Map<String, dynamic> info = {
      'customer': selectedName?['_id'],
      'issuedDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'invoiceNumber': referenceNumber.toLowerCase(),
      'recurring': isRecurring,
      'items': selectedProducts,
      'discount': _calculateDiscount(),
      'totalAmount': _calculateDueAmount(),
      // 'createdAt': DateTime.now().toIso8601String(),
      'bank': bank?['_id'],
      'tax': 0, //add selected tax values later,
      'previouslyPaidAmount': receivedAmount,
      'note': noteController.text == ''
          ? 'Thank you for your business'
          : noteController.text,
    };

    var response = await apiService.post('invoice', info);
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      shouldShare == 'share' ? sharePdf(response) : null;
      toastification.show(
        title: Text('Invoice Created Successfully'),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> sharePdf(invoice) async {
    final file = await generateInvoicePdf(invoice);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: "Here's your invoice",
        subject: "Invoice",
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    updateBankList();

    quantityControllers = List.generate(
      selectedProducts.length,
      (index) => TextEditingController(
        text: selectedProducts[index]['quantity'].toString(),
      ),
    );

    // Initialize random reference number
    referenceNumber =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().padLeft(10, '0').substring(0, 10)}';
  }

  Future updateBankList() async {
    setState(() {
      isBankLoading = true;
    });
    var dbbanks = await apiService.get('banks?skip=${banks.length}');
    setState(() {
      banks = dbbanks.data;
      if (banks.isNotEmpty) {
        bank = banks[0];
      }
      isBankLoading = false;
    });
  }

  _onFieldUnfocus(int index, String value) {
    int? newQty = int.tryParse(value);
    if (newQty == null || newQty < 1) {
      newQty = 1;
    } else if (newQty > selectedProducts[index]['remaining']) {
      newQty = selectedProducts[index]['remaining'];
    }
    if (newQty != selectedProducts[index]['quantity']) {
      updateQuantity(index, newQty);
    } else {
      // To update the text if user enters invalid value
      quantityControllers[index].text = newQty.toString();
    }
  }

  selectUserFromSugestion(suggestion) {
    setState(() {
      selectedName = suggestion;
      nameController.clear();
    });
  }

  void updateBankByAccountNumber(String accountNumber) {
    final matchingBank = banks.firstWhere(
      (bank) => bank['accountNumber'] == accountNumber,
      orElse: () => {},
    );
    setState(() {
      bank = matchingBank;
    });
  }

  deselectUserFromSugestion() {
    setState(() {
      selectedName = null;
    });
  }

  onchange() {
    setState(() {});
  }

  selectProduct(suggestion) {
    suggestion['quantity'] > 0
        ? setState(() {
            final existingIndex = selectedProducts.indexWhere(
              (product) => product['_id'] == suggestion['_id'],
            );
            if (existingIndex != -1) {
              selectedProducts.removeAt(existingIndex);
              quantityControllers.removeAt(existingIndex);
              focusNodes.removeAt(existingIndex);
            } else {
              suggestion['quantity'] = 1;
              suggestion['total'] =
                  suggestion['quantity'] * suggestion['price'];
              selectedProducts.add(suggestion);
              quantityControllers.add(
                TextEditingController(text: suggestion['quantity'].toString()),
              );
              final node = FocusNode();
              node.addListener(() {
                if (!node.hasFocus) {
                  final idx = focusNodes.indexOf(node);
                  if (idx != -1) {
                    _onFieldUnfocus(idx, quantityControllers[idx].text);
                  }
                }
              });
              focusNodes.add(node);
            }
            productController.clear();
          })
        : toastification.show(
            title: Text('Out Of Stock'),
            type: ToastificationType.info,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 3),
          );
  }

  @override
  void dispose() {
    productController.dispose();
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return SingleChildScrollView(
      child: Padding(
        padding: smallScreen
            ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0)
            : const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Create Invoice',
                  style: TextStyle(
                    fontSize: smallScreen ? 20 : 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            // First Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Form
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            // Customer Dropdown
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 3
                                  : constraints.maxWidth,
                              child: buildNameInput(
                                selectedName,
                                nameController,
                                _fetchNames,
                                selectUserFromSugestion,
                                deselectUserFromSugestion,
                                onchange,
                              ),
                            ),
                            // Issue Date
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 3.5
                                  : constraints.maxWidth,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Issue Date',
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() => issueDate = date);
                                  }
                                },
                                controller: TextEditingController(
                                  text: issueDate.toString().split(' ')[0],
                                ),
                              ),
                            ),
                            // Due Date
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 3.5
                                  : constraints.maxWidth,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Due Date',
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() => dueDate = date);
                                  }
                                },
                                controller: TextEditingController(
                                  text: dueDate.toString().split(' ')[0],
                                ),
                              ),
                            ),
                            // Reference Number
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 3
                                  : constraints.maxWidth,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Reference Number',
                                ),
                                readOnly: true,
                                initialValue: referenceNumber,
                              ),
                            ),

                            // Recurring Dropdown
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 3
                                  : constraints.maxWidth,
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Recurring',
                                ),
                                value: isRecurring,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'none',
                                    child: Text('None'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'daily',
                                    child: Text('Daily'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'weekly',
                                    child: Text('Weekly'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'monthly',
                                    child: Text('Monthly'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'quarterly',
                                    child: Text('Quarterly'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'bi-yearly',
                                    child: Text('Bi-Yearly'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'yearly',
                                    child: Text('Yearly'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    isRecurring = value;
                                    selectedTemplate = value;
                                  });
                                },
                              ),
                            ),

                            // Bank Dropdown
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 3.5
                                  : constraints.maxWidth,
                              child: isBankLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : DropdownButtonFormField<String>(
                                      value: bank?['accountNumber'],
                                      decoration: InputDecoration(
                                        labelText: 'Select Bank',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      items: [
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

                            // Invoice Template
                            SizedBox(
                              width: isWide
                                  ? constraints.maxWidth / 4
                                  : constraints.maxWidth,
                              child: SizedBox(),
                            ),
                            // Products Dropdown
                            SizedBox(
                              width: constraints.maxWidth,
                              child: buildProductInput(
                                productController,
                                onchange,
                                _fetchProducts,
                                selectProduct,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Table
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 100,
                        maxHeight: 500,
                      ),
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: !smallScreen ? 140 : 90,
                            dataRowMinHeight: 48,
                            columns: const [
                              DataColumn(label: Text('Product')),
                              DataColumn(label: Text('Quantity')),
                              DataColumn(label: Text('Unit Price')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: selectedProducts.asMap().entries.map((entry) {
                              final index = entry.key;
                              final product = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text(product['title'])),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                          ),
                                          onPressed: () {
                                            updateQuantity(
                                              index,
                                              product['quantity'] - 1,
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: TextFormField(
                                            focusNode: focusNodes[index],
                                            controller:
                                                quantityControllers[index],
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                          ),
                                          onPressed: () {
                                            updateQuantity(
                                              index,
                                              product['quantity'] + 1,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      product['price']
                                          .toString()
                                          .formatToFinancial(
                                            isMoneySymbol: true,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      product['total']
                                          .toString()
                                          .formatToFinancial(
                                            isMoneySymbol: true,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () =>
                                              selectedProducts.remove(product),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            !smallScreen
                ? Row(
                    children: [
                      // Second Card
                      Expanded(child: discountNote(smallScreen)),

                      const SizedBox(width: 16),
                      // Third Card
                      Expanded(child: totals()),
                    ],
                  )
                : Column(
                    children: [
                      // Second Card
                      discountNote(smallScreen),
                      const SizedBox(height: 16),
                      // Third Card
                      totals(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Card totals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Subtotal, Discount, Total
            Row(
              children: [
                const Text('Subtotal:'),
                const Spacer(),
                Text(
                  _calculateSubtotal().toString().formatToFinancial(
                    isMoneySymbol: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Discount:'),
                const Spacer(),
                Text(
                  _calculateDiscount().toString().formatToFinancial(
                    isMoneySymbol: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Total:'),
                const Spacer(),
                Text(
                  _calculateTotal().toString().formatToFinancial(
                    isMoneySymbol: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tax

            // Row(children: [
            //   const Text('Tax: '),
            //   const Spacer(),
            //   Expanded(
            //     child: DropdownButtonFormField<String>(
            //       decoration: const InputDecoration(labelText: 'Tax'),
            //       items: taxes.map((e) {
            //         return DropdownMenuItem(value: e, child: Text(e));
            //       }).toList(),
            //       onChanged: (value) {},
            //     ),
            //   )
            // ]),

            // const SizedBox(height: 10),
            // Grand Total
            Row(
              children: [
                const Text('Grand Total: '),
                const Spacer(),
                Text(
                  _calculateGrandTotal().toString().formatToFinancial(
                    isMoneySymbol: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Received Amount
            Row(
              children: [
                const Text('Received Amount: '),
                const Spacer(),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Received Amount',
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        setState(() => receivedAmount = parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Due Amount
            Divider(),
            Row(
              children: [
                Text(
                  'Due Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  _calculateDueAmount().toString().formatToFinancial(
                    isMoneySymbol: true,
                  ),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    handleSave('');
                  },
                  label: Text('Save'),
                  icon: Icon(Icons.send_outlined),
                ),
                // OutlinedButton.icon(
                //     onPressed: () {
                //       handleSave('share');
                //     },
                //     label: Text('Save And Send'),
                //     icon: Icon(Icons.send_and_archive_outlined))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card discountNote(isSmallScreen) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Discount Section
            !isSmallScreen
                ? Row(
                    // spacing: 4,
                    children: [
                      // Discount Type
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Discount Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '',
                              child: Text('Select A Discount'),
                            ),
                            DropdownMenuItem(
                              value: 'fixed',
                              child: Text('Fixed'),
                            ),
                            DropdownMenuItem(
                              value: 'percentage',
                              child: Text('Percentage'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => discountType = value),
                        ),
                      ),

                      // Discount Value
                      Expanded(
                        child: TextFormField(
                          enabled: discountType == '' ? false : true,
                          decoration: const InputDecoration(
                            labelText: 'Discount Value',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              setState(() => discountValue = parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 120,
                    child: Column(
                      children: [
                        // Discount Type
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Discount Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'fixed',
                              child: Text('Fixed'),
                            ),
                            DropdownMenuItem(
                              value: 'percentage',
                              child: Text('Percentage'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => discountType = value),
                        ),
                        Spacer(),
                        // Discount Value
                        TextFormField(
                          enabled: discountType == '' ? false : true,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Discount Value',
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              setState(() => discountValue = parsed);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 10),

            Row(children: [Text('Note')]),
            const SizedBox(height: 5),
            // WYSIWYG Input
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Additional Notes'),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSubtotal() {
    return selectedProducts.fold(0, (sum, product) => sum + product['total']);
  }

  double _calculateDiscount() {
    if (discountType == 'percentage') {
      return _calculateSubtotal() * (discountValue / 100);
    } else if (discountType == 'fixed') {
      return discountValue;
    }
    return 0;
  }

  double _calculateTotal() {
    return _calculateSubtotal() - _calculateDiscount();
  }

  double _calculateGrandTotal() {
    // Add tax logic here if needed
    return _calculateTotal();
  }

  double _calculateDueAmount() {
    return _calculateGrandTotal() - receivedAmount;
  }
}
