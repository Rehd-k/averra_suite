import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../components/inputs/product_finder.dart';
import '../../service/api.service.dart';

class SendFinished extends StatefulWidget {
  final num totalCost;
  final String department;
  final String itemId;
  final Function updateList;
  const SendFinished({
    super.key,
    required this.totalCost,
    required this.department,
    required this.itemId,
    required this.updateList,
  });

  @override
  State<SendFinished> createState() => _SendFinishedState();
}

class _SendFinishedState extends State<SendFinished> {
  final ApiService apiService = ApiService();
  TextEditingController productController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Map? selectedProduct;
  num totalCost = 0;
  String department = '';

  @override
  void initState() {
    totalCost = widget.totalCost;
    department = widget.department;
    return super.initState();
  }

  void onchange() {
    setState(() {});
  }

  Future<List<Map>> _fetchProducts(String query) async {
    final response = await apiService.get(
      'products?filter={"isAvailable" : true, "title": {"\$regex": "$query"}}&sort={"title": 1}&limit=20&skip=0&select=" title price quantity type sellUnits cartonAmount "',
    );
    var {"products": products, "totalDocuments": totalDocuments} =
        response.data;
    if (response.statusCode == 200) {
      return List<Map>.from(products);
    } else {
      throw Exception('Failed to load names');
    }
  }

  void selectProduct(suggestion) {
    setState(() {
      selectedProduct = suggestion;
    });
  }

  void deselectUserFromSugestion() {
    setState(() {
      selectedProduct = null;
    });
  }

  Future sendToStock() async {
    showToast('Updating ${selectedProduct?['title']}', ToastificationType.info);
    var data = {
      'productId': selectedProduct?['_id'],
      'quantity': num.parse(amountController.text),
      'price': getUnitPrice(),
      'total': totalCost,
      'cartonPrice': 0,
      'cartonQuanity': 0,
      'totalPayable': totalCost,
      'purchaseDate': DateTime.now().toIso8601String(),
      'status': 'Delivered',
      'paymentMethod': 'cash',
      'dropOfLocation': department,
      'notes': '',
      'expiryDate': DateTime.now()
          .add(const Duration(days: 2))
          .toIso8601String(),
      'cash': 0,
      'bank': 0,
      'debt': totalCost,
      'discount': 0,
      'deliveryDate': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'moneyFrom': '',
    };

    print(data);

    await apiService.post('purchases', data);
    await apiService.delete('work-in-progress/${widget.itemId}');
    widget.updateList('');
    showToast('Done', ToastificationType.info);
    Navigator.of(context).pop();
  }

  getUnitPrice() {
    print('$totalCost, ${amountController.text}');
    return totalCost ~/ num.parse(amountController.text);
  }

  @override
  void dispose() {
    productController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(selectedProduct);
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: isWide
                      ? constraints.maxWidth / 3
                      : constraints.maxWidth,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: amountController,
                    decoration: const InputDecoration(
                      label: Text('Quantity'),
                      hintText: "Type something...",
                    ),
                  ),
                ),
                SizedBox(
                  width: isWide ? constraints.maxWidth : constraints.maxWidth,
                  child: selectedProduct == null
                      ? buildProductInput(
                          productController,
                          onchange,
                          _fetchProducts,
                          selectProduct,
                        )
                      : Chip(
                          label: Text(selectedProduct?['title']),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () {
                            deselectUserFromSugestion();
                          },
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth / 2,
                      child: OutlinedButton(
                        onPressed: () {
                          if (selectedProduct != null &&
                              (int.tryParse(amountController.text) ?? 0) > 0) {
                            sendToStock();
                          }
                        },
                        child: const Text("Send"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
