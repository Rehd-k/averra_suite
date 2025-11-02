import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../../../service/api.service.dart';
import '../../service/token.service.dart';

@RoutePage()
class SendProducts extends StatefulWidget {
  const SendProducts({super.key});

  @override
  SendProductsState createState() => SendProductsState();
}

class SendProductsState extends State<SendProducts> {
  final ApiService apiService = ApiService();
  final JwtService jwtService = JwtService();
  List<FocusNode> focusNodes = [];
  List<FocusNode> priceFocusNodes = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> priceControllers = [];

  late String departmentPoint = '';
  late Map departmentFront = {};
  late List departmentFronts = [];
  late List products = [];
  List<Map> selectedProducts = [];

  bool loading = true;
  String toPoint = '';
  String fromPoint = '';
  String fromPointName = '';

  void doSearch(String query) {
    getProductsFromDepartment(query);
  }

  void getProductsFromDepartment(dynamic query) async {
    try {
      var result = await apiService.get(
        'department/$fromPoint?select=finishedGoods',
      );
      setState(() {
        departmentFront = result.data;
        products = result.data['finishedGoods'];
        loading = false;
      });
    } catch (e) {
      showToast('Error $e', ToastificationType.error);
    }
  }

  void getDepartments() async {
    var toDepartments = [];
    var res = await apiService.get('department?active=${true}');

    for (var element in res.data) {
      if (element['access'].contains(jwtService.decodedToken?['role'])) {
        toDepartments.add(element);
      }
    }
    setState(() {
      departmentFronts = toDepartments;
      loading = false;
    });
  }

  void selectTo(dynamic value) async {
    setState(() {
      toPoint = value;
    });
  }

  void selectFrom(dynamic value) async {
    String res = departmentFronts.firstWhere(
      (department) => department['_id'] == value,
      orElse: () => {'title': 'Unknown'}, // fallback in case no match
    )['title'];
    setState(() {
      fromPointName = res;
      fromPoint = value;
    });
    getProductsFromDepartment('');
  }

  void updateQuantity(int index, int? newQuantity) {
    setState(() {
      if (newQuantity! <= selectedProducts[index]['quantity']) {
        selectedProducts[index]['toSend'] = newQuantity;
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

  void _onFieldUnfocus(int index, String value) {
    int? newQty = int.tryParse(value);
    if (newQty == null || newQty < 1) {
      newQty = 1;
    } else if (newQty > selectedProducts[index]['quantity']) {
      newQty = selectedProducts[index]['quantity'];
    }

    updateQuantity(index, newQty);
  }

  void updatePrice(int index, int? newPrice) {
    setState(() {
      if (newPrice != null && newPrice >= 1) {
        selectedProducts[index]['price'] = newPrice;
        priceControllers[index].text = newPrice.toString();
      } else {
        toastification.show(
          title: Text('Invalid price'),
          type: ToastificationType.info,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    });
  }

  void _onPriceFieldUnfocus(int index, String value) {
    int? newPrice = int.tryParse(value);
    if (newPrice == null || newPrice < 1) {
      newPrice = selectedProducts[index]['price']; // fallback to old value
    }
    updatePrice(index, newPrice);
  }

  void selectProduct(Map<String, dynamic> suggestion) {
    suggestion['quantity'] > 0
        ? setState(() {
            final existingIndex = selectedProducts.indexWhere(
              (product) => product['_id'] == suggestion['_id'],
            );

            if (existingIndex != -1) {
              // remove product
              selectedProducts.removeAt(existingIndex);
              quantityControllers.removeAt(existingIndex);
              priceControllers.removeAt(existingIndex);
              focusNodes.removeAt(existingIndex);
              priceFocusNodes.removeAt(existingIndex);
            } else {
              // add product
              suggestion['toSend'] = 1;
              suggestion['product'] = suggestion['productId']['_id'];
              selectedProducts.add(suggestion);
              quantityControllers.add(
                TextEditingController(text: suggestion['toSend'].toString()),
              );
              priceControllers.add(
                TextEditingController(text: suggestion['price'].toString()),
              );

              // Quantity focus node
              final qtyNode = FocusNode();
              qtyNode.addListener(() {
                if (!qtyNode.hasFocus) {
                  final idx = focusNodes.indexOf(qtyNode);
                  if (idx != -1) {
                    _onFieldUnfocus(idx, quantityControllers[idx].text);
                  }
                }
              });
              focusNodes.add(qtyNode);

              // Price focus node
              final priceNode = FocusNode();
              priceNode.addListener(() {
                if (!priceNode.hasFocus) {
                  final idx = priceFocusNodes.indexOf(priceNode);
                  if (idx != -1) {
                    _onPriceFieldUnfocus(idx, priceControllers[idx].text);
                  }
                }
              });
              priceFocusNodes.add(priceNode);
            }
          })
        : showToast('Out Of Stock', ToastificationType.info);
  }

  void handleSubmit() async {
    if (toPoint.isEmpty) {
      showToast(
        'lol, stop',
        ToastificationType.warning,
        description: 'Select A Department to Send To',
        duretion: 5,
      );
      return;
    }

    if (toPoint == fromPoint) {
      showToast(
        'lol, stop',
        ToastificationType.warning,
        description: 'You can\'t send to a Department you are sending from',
        duretion: 5,
      );
      return;
    }
    await apiService.post(
      'department/move-stock?senderId=$fromPoint&receiverId=$toPoint&from=finishedGoods',
      {'body': selectedProducts},
    );

    setState(() {
      selectedProducts = [];
      products = [];
      toPoint = '';
      fromPoint = '';
      fromPointName = '';
      focusNodes = [];
      priceFocusNodes = [];
      quantityControllers = [];
      priceControllers = [];
    });

    showToast('Done', ToastificationType.success);
  }

  @override
  void initState() {
    getDepartments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  initialValue: fromPoint,
                  decoration: InputDecoration(
                    labelText: 'From (Select Department)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    selectFrom(newValue);
                  },
                  items:
                      [
                        {'title': '', '_id': ''},
                        ...departmentFronts,
                      ].map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value['_id'],
                          child: Text(value['title']),
                        );
                      }).toList(),
                  validator: (value) =>
                      value == null ? 'Please select an option' : null,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  initialValue: toPoint,
                  decoration: InputDecoration(
                    labelText: 'To (Select Point)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    selectTo(newValue);
                  },
                  items:
                      [
                        {'title': '', '_id': ''},
                        ...departmentFronts,
                      ].map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value['_id'],
                          child: Text(value['title']),
                        );
                      }).toList(),
                  validator: (value) =>
                      value == null ? 'Please select an option' : null,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(label: Text('Search Product')),
                  onChanged: (value) {
                    doSearch(value);
                  },
                ),
              ),

              SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                    ),
                  ),
                  onPressed: () {
                    handleSubmit();
                  },
                  child: Text('Done'),
                ),
              ),
            ],
          ),
        ),
        if (fromPoint.isEmpty)
          Expanded(
            child: Center(child: Text('Select A Department To Send From')),
          ),

        if (fromPoint.isNotEmpty && products.isEmpty)
          Expanded(
            child: Center(child: Text('No Products at the $fromPointName')),
          ),
        if (products.isNotEmpty && fromPoint.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: smallScreen ? 100 : 183,
                  columns: [
                    DataColumn(label: Text('Product Title')),
                    DataColumn(label: Text('Quantity At Department')),
                    DataColumn(label: Text('Value')),
                    DataColumn(label: Text('Quantity To Send')),
                    // DataColumn(label: Text('At Price')),
                  ],
                  rows: products.asMap().entries.map((entry) {
                    final product = entry.value;
                    final exists = selectedProducts.any(
                      (selected) => selected['_id'] == product['_id'],
                    );
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            capitalizeFirstLetter(
                              product['productId']['title'],
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              product['quantity'].toString().formatToFinancial(
                                isMoneySymbol: false,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            product['productId']['price']
                                .toString()
                                .formatToFinancial(isMoneySymbol: true),
                          ),
                        ),
                        DataCell(
                          exists
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2.0,
                                        ),
                                        child: TextFormField(
                                          focusNode:
                                              focusNodes[selectedProducts
                                                  .indexWhere(
                                                    (p) =>
                                                        p['_id'] ==
                                                        product['_id'],
                                                  )],
                                          controller:
                                              quantityControllers[selectedProducts
                                                  .indexWhere(
                                                    (p) =>
                                                        p['_id'] ==
                                                        product['_id'],
                                                  )],
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
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        selectProduct(product);
                                      },
                                      icon: Icon(Icons.remove_circle),
                                    ),
                                  ],
                                )
                              : IconButton(
                                  onPressed: () {
                                    selectProduct(product);
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                        ),

                        // DataCell(
                        //   exists
                        //       ? Padding(
                        //           padding: const EdgeInsets.symmetric(
                        //             vertical: 2.0,
                        //           ),
                        //           child: TextFormField(
                        //             focusNode:
                        //                 priceFocusNodes[selectedProducts
                        //                     .indexWhere(
                        //                       (p) => p['_id'] == product['_id'],
                        //                     )],
                        //             controller:
                        //                 priceControllers[selectedProducts
                        //                     .indexWhere(
                        //                       (p) => p['_id'] == product['_id'],
                        //                     )],
                        //             textAlign: TextAlign.center,
                        //             keyboardType: TextInputType.number,
                        //             inputFormatters: [
                        //               FilteringTextInputFormatter.digitsOnly,
                        //             ],
                        //             decoration: InputDecoration(
                        //               border: OutlineInputBorder(
                        //                 borderSide: BorderSide(
                        //                   width: 0,
                        //                   style: BorderStyle.none,
                        //                 ),
                        //               ),
                        //               isDense: true,
                        //               contentPadding: EdgeInsets.symmetric(
                        //                 vertical: 8,
                        //               ),
                        //             ),
                        //           ),
                        //         )
                        //       : Text(
                        //           product['price'].toString().formatToFinancial(
                        //             isMoneySymbol: true,
                        //           ),
                        //         ),
                        // ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
