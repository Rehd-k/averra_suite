import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import '../../service/toast.service.dart';
import '../../service/token.service.dart';

@RoutePage()
class DepartmentRequest extends StatefulWidget {
  const DepartmentRequest({super.key});

  @override
  DepartmentRequestState createState() => DepartmentRequestState();
}

class DepartmentRequestState extends State<DepartmentRequest> {
  final ApiService apiService = ApiService();
  final JwtService jwtService = JwtService();
  List<FocusNode> focusNodes = [];
  List<TextEditingController> quantityControllers = [];

  late String departmentPoint = '';
  late Map departmentFront = {};
  late List departmentFronts = [];
  late List toDepartmentFronts = [];
  late List products = [];
  List<Map> selectedProducts = [];

  bool loading = true;
  String toPoint = '';
  String fromPoint = '';
  String fromPointName = '';
  String goodsFrom = 'finishedGoods';

  void doSearch(String query) {
    getProductsFromDepartment();
  }

  void getProductsFromDepartment() async {
    setState(() {
      departmentFront = {};
      products = [];
    });
    try {
      if (fromPoint.isNotEmpty) {
        var result = await apiService.get(
          'department/$fromPoint?select=$goodsFrom',
        );

        setState(() {
          departmentFront = result.data;
          products = result.data[goodsFrom];
          loading = false;
        });
      }
    } catch (e) {
      showToast('Error $e', ToastificationType.error);
    }
  }

  void getDepartments() async {
    var toDepartments = [];
    var result = await apiService.get('department?active=${true}');

    for (var element in result.data) {
      if (element['access'].contains(jwtService.decodedToken?['role'])) {
        toDepartments.add(element);
      }
    }
    setState(() {
      departmentFronts = result.data;
      toDepartmentFronts = toDepartments;
      loading = false;
    });
  }

  void selectTo(value) async {
    setState(() {
      toPoint = value;
    });
  }

  void selectFrom(value) async {
    String res = departmentFronts.firstWhere(
      (department) => department['_id'] == value,
      orElse: () => {'title': 'Unknown'}, // fallback in case no match
    )['title'];
    setState(() {
      fromPointName = res;
      fromPoint = value;
    });
    getProductsFromDepartment();
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
              focusNodes.removeAt(existingIndex);
            } else {
              // add product
              suggestion['toSend'] = 1;
              suggestion['product'] = suggestion['productId']['_id'];
              selectedProducts.add(suggestion);
              quantityControllers.add(
                TextEditingController(text: suggestion['toSend'].toString()),
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
        description: 'You can\'t send to the Department you are sending from',
        duretion: 5,
      );
      return;
    }

    var dataToSend = {
      'from': departmentFronts.firstWhere(
        (department) => department['_id'] == fromPoint,
        orElse: () => {'title': 'Unknown'}, // fallback in case no match
      )['title'],
      'to': departmentFronts.firstWhere(
        (department) => department['_id'] == toPoint,
        orElse: () => {'title': 'Unknown'}, // fallback in case no match
      )['title'],
      'fromId': fromPoint,
      'toId': toPoint,
      'products': selectedProducts,
      'section': goodsFrom,
    };
    for (var element in dataToSend['products']) {
      element['quantity'] = element['toSend'];
    }
    await apiService.post('department-history', dataToSend);

    setState(() {
      selectedProducts = [];
      products = [];
      toPoint = '';
      fromPoint = '';
      fromPointName = '';
      focusNodes = [];
      quantityControllers = [];
    });

    showToast('Done', ToastificationType.success);
  }

  void handleGoodsFrom(String loadWip) async {
    setState(() {
      toPoint = '';
      fromPoint = '';
      goodsFrom = loadWip;
    });
  }

  @override
  void initState() {
    getDepartments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final buttonWidth = isSmallScreen
        ? MediaQuery.of(context).size.width * 0.8
        : 400.0;
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: buttonWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            handleGoodsFrom('RawGoods');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goodsFrom == 'RawGoods'
                                ? Colors.green
                                : null,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                          child: const Text("Raw Materials"),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            handleGoodsFrom('finishedGoods');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goodsFrom == 'finishedGoods'
                                ? Colors.green
                                : null,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                          child: const Text("Finished Goods"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: fromPoint,
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
                  value: toPoint,
                  decoration: InputDecoration(
                    labelText: 'To (Select Department)',
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
                  child: Text('Send Request'),
                ),
              ),
            ],
          ),
        ),
        if (fromPoint.isEmpty)
          Expanded(child: Center(child: Text('Select A Point To Send From'))),

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
                  columnSpacing: isSmallScreen ? 133 : 200,
                  columns: [
                    DataColumn(label: Text('Product Title')),
                    DataColumn(label: Text('Quantity At Department')),
                    DataColumn(label: Text('Value')),
                    DataColumn(label: Text('Quantity To Send')),
                  ],
                  rows: products.asMap().entries.map((entry) {
                    final product = entry.value;
                    final exists = selectedProducts.any(
                      (selected) =>
                          selected['productId']['_id'] ==
                          product['productId']['_id'],
                    );
                    return DataRow(
                      cells: [
                        DataCell(Text(product['productId']['title'])),
                        DataCell(
                          Text(
                            product['quantity'].toString().formatToFinancial(
                              isMoneySymbol: false,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (product['productId']['price'] ?? product['cost'])
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
                                                        p['productId']['_id'] ==
                                                        product['productId']['_id'],
                                                  )],
                                          controller:
                                              quantityControllers[selectedProducts
                                                  .indexWhere(
                                                    (p) =>
                                                        p['productId']['_id'] ==
                                                        product['productId']['_id'],
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
