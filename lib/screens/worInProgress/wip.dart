import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import '../../service/toast.service.dart';
import '../../service/token.service.dart';

@RoutePage()
class Wip extends StatefulWidget {
  const Wip({super.key});

  @override
  WipState createState() => WipState();
}

class WipState extends State<Wip> {
  final ApiService apiService = ApiService();
  final JwtService jwtService = JwtService();
  TextEditingController controller = TextEditingController();
  List<FocusNode> focusNodes = [];
  List<FocusNode> priceFocusNodes = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> priceControllers = [];

  late String departmentPoint = '';
  late Map departmentFront = {};
  late List departmentFronts = [];
  late List products = [];
  List<Map> selectedProducts = [];
  late List wipProgress = [];

  bool loading = true;
  String toPoint = '';
  String process = '';
  String fromPoint = '';
  String fromPointName = '';
  String toPointName = '';
  bool isWip = false;

  void doSearch(String query) {
    getProductsFromDepartment();
  }

  void getProductsFromDepartment() async {
    if (fromPoint != '') {
      try {
        var result = await apiService.get(
          'department/$fromPoint?select=RawGoods',
        );
        setState(() {
          departmentFront = result.data;
          products = result.data['RawGoods'];
          loading = false;
        });
      } catch (e) {
        showToast('Error $e', ToastificationType.error);
      }
    }
  }

  void getDepartments() async {
    List toDepartments = [];
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

  void selectTo(String value) async {
    String res = departmentFronts.firstWhere(
      (department) => department['_id'] == value,
      orElse: () => {'title': 'Unknown'},
    )['title'];

    setState(() {
      toPoint = value;
      toPointName = res;
    });
  }

  void selectProcess(String value) async {
    setState(() {
      process = value;
    });
  }

  void selectFrom(String value) async {
    String res = departmentFronts.firstWhere(
      (department) => department['_id'] == value,
      orElse: () => {'title': 'Unknown'}, // fallback in case no match
    )['title'];

    if (isWip) {
      var result = await apiService.get(
        'work-in-progress?filter={"at" : "$value" }&select=title at',
      );
      setState(() {
        wipProgress = result.data['workInProgress'];
        fromPointName = res;
        fromPoint = value;
      });
    }

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

  void updatePrice(int index, int? newPrice) {
    setState(() {
      if (newPrice != null && newPrice >= 1) {
        selectedProducts[index]['unitCost'] = newPrice;
        priceControllers[index].text = newPrice.toString();
      } else {
        toastification.show(
          title: Text('Invalid cost'),
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
      newPrice = selectedProducts[index]['cost']; // fallback to old value
    }
    updatePrice(index, newPrice);
  }

  void selectProduct(Map suggestion) {
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
              // suggestion['product'] = suggestion['product'];
              selectedProducts.add(suggestion);
              quantityControllers.add(
                TextEditingController(text: suggestion['toSend'].toString()),
              );
              priceControllers.add(
                TextEditingController(text: suggestion['unitCost'].toString()),
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
    selectedProducts.map((item) {
      final cost = item['toSend'] * item['unitCost'];
      item['cost'] = cost;
      return item;
    }).toList();
    await apiService.post(
      'department/move-stock?senderId=$fromPoint&receiverId=$toPoint&from=RawGoods',
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

  void handleIsWIP(bool loadWip) async {
    setState(() {
      toPoint = '';
      fromPoint = '';
      isWip = loadWip;
    });
  }

  void sendToWorkInProgress(String title) async {
    selectedProducts.map((item) {
      item['quantity'] = item['toSend'];
      final cost = item['toSend'] * item['unitCost'];
      item['cost'] = cost;
      return item;
    }).toList();

    var newWorkInProgress = {
      'title': title,
      'at': fromPoint,
      'rawGoods': selectedProducts,
    };
    await apiService.post('work-in-progress', newWorkInProgress);

    setState(() {
      selectedProducts = [];
      products = [];
      toPoint = '';
      fromPoint = '';
      fromPointName = '';
      process = '';
      controller.text = '';
    });

    showToast('Done', ToastificationType.success);
  }

  @override
  void initState() {
    isWip = true;
    if (jwtService.decodedToken?['role'] == 'chef') {
      setState(() {
        isWip = true;
      });
    }
    getDepartments();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final buttonWidth = isSmallScreen
        ? MediaQuery.of(context).size.width * 0.8
        : 400.0;
    return Column(
      children: [
        if (!['bar', 'chef'].contains(jwtService.decodedToken?['role']))
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
                              handleIsWIP(false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isWip ? null : Colors.green,
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
                              handleIsWIP(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isWip ? Colors.green : null,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                            child: const Text("W.I.P"),
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
                  initialValue: fromPoint,
                  decoration: InputDecoration(
                    labelText: 'From (Select Department)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    selectFrom(newValue!);
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
            SizedBox(width: isSmallScreen ? 0 : 20),
            isWip
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: process,
                        decoration: InputDecoration(
                          labelText: 'Select Process',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          selectProcess(newValue!);
                        },
                        items:
                            [
                              {'title': '', '_id': ''},
                              ...wipProgress,
                            ].map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value['title'],
                                child: Text(value['title']),
                              );
                            }).toList(),
                        validator: (value) =>
                            value == null ? 'Please select an option' : null,
                      ),
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: toPoint,
                        decoration: InputDecoration(
                          labelText: 'To (Select Department)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          selectTo(newValue!);
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

              SizedBox(width: isSmallScreen ? 5 : 20),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                    ),
                  ),
                  onPressed: () {
                    if (fromPoint.isNotEmpty) {
                      if (isWip) {
                        if (process.isEmpty) {
                          showTextInputDialog(context, controller);
                        } else {
                          sendToWorkInProgress(process);
                        }
                      } else {
                        handleSubmit();
                      }
                    } else {
                      showToast('Just Dey Play', ToastificationType.info);
                    }
                  },
                  child: Text(
                    'Send ${toPoint.isEmpty ? '' : 'To ${capitalizeFirstLetter(toPointName)}'}',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (fromPoint.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(child: Text('Select A Point To Send From')),
          ),

        if (fromPoint.isNotEmpty && products.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(child: Text('No Products at the $fromPointName')),
          ),
        if (products.isNotEmpty && fromPoint.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 133,
              columns: [
                DataColumn(label: Text('Product Title')),
                DataColumn(label: Text('Quantity At Department')),
                DataColumn(label: Text('Value')),
                DataColumn(label: Text('Quantity To Send')),
                DataColumn(label: Text('At Cost')),
              ],
              rows: products.asMap().entries.map((entry) {
                final product = entry.value;
                final exists = selectedProducts.any(
                  (selected) => selected['_id'] == product['_id'],
                );
                return DataRow(
                  cells: [
                    DataCell(Text(capitalizeFirstLetter(product['title']))),
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
                        product['cost'].toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
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
                                                    p['_id'] == product['_id'],
                                              )],
                                      controller:
                                          quantityControllers[selectedProducts
                                              .indexWhere(
                                                (p) =>
                                                    p['_id'] == product['_id'],
                                              )],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
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
                    DataCell(
                      exists
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: TextFormField(
                                focusNode:
                                    priceFocusNodes[selectedProducts.indexWhere(
                                      (p) => p['_id'] == product['_id'],
                                    )],
                                controller:
                                    priceControllers[selectedProducts
                                        .indexWhere(
                                          (p) => p['_id'] == product['_id'],
                                        )],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              (product['unitCost'])
                                  .toString()
                                  .formatToFinancial(isMoneySymbol: true),
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<String?> showTextInputDialog(BuildContext context, controller) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Process"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Type something..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                sendToWorkInProgress(controller.text);
                Navigator.pop(context, controller.text); // return text
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
