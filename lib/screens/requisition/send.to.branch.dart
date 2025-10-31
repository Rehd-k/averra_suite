import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/token.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import '../../service/toast.service.dart';
import 'create.requisition.dart';

@RoutePage()
class SendToBranchScreen extends StatefulWidget {
  const SendToBranchScreen({super.key});

  @override
  SendToBranchState createState() => SendToBranchState();
}

class SendToBranchState extends State<SendToBranchScreen> {
  ApiService apiService = ApiService();
  JwtService jwtService = JwtService();
  late String selectedDepartment = '';
  late String selectedLocation = '';
  late List departmentFronts = [];
  final TextEditingController productController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final JsonEncoder jsonEncoder = JsonEncoder();
  List<dynamic> products = [];
  List<Map<String, dynamic>> selectedProducts = [];
  Map<String, dynamic>? selectedProduct;
  bool loading = true;
  String searchFeild = 'title';
  String searchQuery = '';
  String fromPoint = '';
  num skip = 0;
  num limit = 10;
  num totalBalance = 0;

  void getProductsFromDepartment(String query) async {
    try {
      var result = await apiService.get('department/for-both/$query');
      setState(() {
        products = result.data['finishedGoods'];
        products.addAll(result.data['RawGoods']);
        loading = false;
      });
    } catch (e) {
      showToast('Error $e', ToastificationType.error);
    }
  }

  Future<void> save() async {
    Map<String, dynamic>? dataToSave;
    if (selectedProducts.isEmpty) {
      return;
    }

    var result = await apiService.get('location');
    List<dynamic> locations = result.data;

    // Find location in locations with currentLocation as its name
    // locations.removeWhere((loc) => loc['name'] == currentLocation);

    // if (locations.isEmpty) {
    //   showToast('No Other Branches', ToastificationType.error);
    //   return;
    // }

    // Open modal and wait for selection
    final selectedLocation = await showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      builder: (_) => LocationPickerModal(locations: locations),
    );

    if (selectedLocation == null) {
      return;
    }
    dataToSave = {
      'notes': noteController.text,
      'to': selectedLocation['name'],
      'products': selectedProducts,
      'totalCost': totalBalance,
      'approved': true,
    };
    await apiService.post('reqisition', dataToSave);
    showToast('Done', ToastificationType.success);
    setState(() {
      selectedProducts = [];
      totalBalance = 0;
    });
  }

  void getDepartments() async {
    var res = await apiService.get('department?active=${true}&type=store');
    setState(() {
      departmentFronts = res.data;
      loading = false;
    });
  }

  void selectFrom(String? value) async {
    setState(() {
      selectedProduct = null;
      costController.clear();
      quantityController.clear();
      selectedDepartment = value ?? '';
    });
    if (value != '') {
      getProductsFromDepartment(selectedDepartment);
    }
  }

  Future<List<Map>> getProducts(String title) async {
    var filteredProducts = products
        .where((product) => product['productId']['title'].contains(title))
        .toList();
    return List<Map>.from(filteredProducts);
  }

  void selectProductFromSugestion(suggestion, modelState) {
    var exists = selectedProducts.firstWhere(
      (element) => element['productId'] == suggestion['productId']['_id'],
      orElse: () => {},
    );
    if (exists.isEmpty) {
      setState(() {
        selectedProduct = suggestion;
        productController.clear();
      });
      if (modelState != null) {
        modelState(() {});
      }
    } else {
      showToast('Already Added', ToastificationType.error);
    }
  }

  void deselectProductFromSugestion(dynamic modelState) {
    setState(() {
      selectedProduct = null;
    });
    if (modelState != null) {
      modelState(() {});
    }
  }

  void onchange(dynamic modelState) {
    setState(() {});
    if (modelState != null) {
      modelState(() {});
    }
  }

  void removeFromList(Map suggestion) {
    var index = selectedProducts.indexWhere(
      (element) => element['productId'] == suggestion['productId'],
    );
    setState(() {
      totalBalance -= suggestion['cost'];
      selectedProducts.removeAt(index);
    });
  }

  void addToList(dynamic modelState) {
    if (selectedProduct == null) {
      showToast('Select Product First', ToastificationType.info);
      return;
    }
    if (quantityController.text.isEmpty ||
        num.parse(quantityController.text) < 1) {
      showToast('Quantity Value is not Valid', ToastificationType.info);
      return;
    }
    if (num.parse(quantityController.text) > selectedProduct?['quantity']) {
      showToast(
        'Entered Quantity Is More Than Avialeble Quantity At Store',
        ToastificationType.info,
      );
      return;
    }
    if (costController.text.isEmpty || num.parse(costController.text) < 1) {
      showToast('Cost Value is not Valid', ToastificationType.info);
      return;
    }

    var item = {
      'productId': selectedProduct?['productId']['_id'],
      'product_title': selectedProduct?['productId']['title'],
      'from': selectedDepartment,
      'fromName': departmentFronts.firstWhere(
        (element) => element['_id'] == selectedDepartment,
        orElse: () => {},
      ),
      'cost': num.tryParse(costController.text) ?? 0,
      'quantity': num.tryParse(quantityController.text) ?? 0,
    };
    setState(() {
      selectedProducts.add(item);
      totalBalance += item['cost'];
      selectedProduct = null;
      costController.clear();
      quantityController.clear();
    });
    if (modelState != null) {
      modelState(() {});
    }
  }

  void emptyList() {
    setState(() {
      selectedProducts = [];
      totalBalance = 0;
    });
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!smallScreen)
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: loading
                              ? Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<String>(
                                  initialValue: selectedDepartment,
                                  decoration: InputDecoration(
                                    labelText: 'From',
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
                                          child: Text(
                                            capitalizeFirstLetter(
                                              value['title'],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  validator: (value) => value == ''
                                      ? 'Please select an option'
                                      : null,
                                ),
                        ),

                        SizedBox(height: 20),
                        buildProductsInput(
                          selectedProduct,
                          productController,
                          getProducts,
                          selectProductFromSugestion,
                          deselectProductFromSugestion,
                          onchange,
                          null,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity Cannot be Empty';
                            }
                            if (int.parse(value) < 1) {
                              return 'Must Be Greater Than 0';
                            }
                            if (num.parse(value) >
                                num.parse(selectedProduct?['quantity'])) {
                              return 'Must Be Greater Than 0';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: costController,
                          decoration: InputDecoration(
                            labelText: 'Cost',
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

                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              addToList(null);
                            },
                            child: Text(
                              'Add To List',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    selectedProducts.length
                                        .toString()
                                        .formatToFinancial(
                                          isMoneySymbol: false,
                                        ),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    ' Items',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Cost :',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    totalBalance.toString().formatToFinancial(
                                      isMoneySymbol: true,
                                    ),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: smallScreen ? 330 : 385,
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: smallScreen ? 100 : 160,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'Product Name',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Quantity',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Cost',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Remove',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                    rows: selectedProducts.map<DataRow>((item) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              item['product_title'] ?? '',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item['quantity']
                                                  .toString()
                                                  .formatToFinancial(
                                                    isMoneySymbol: false,
                                                  ),
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item['cost']
                                                      ?.toString()
                                                      .formatToFinancial(
                                                        isMoneySymbol: true,
                                                      ) ??
                                                  '',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton.filledTonal(
                                              onPressed: () {
                                                removeFromList(item);
                                              },
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                size: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                controller: noteController,
                                minLines:
                                    4, // The initial number of lines to display
                                maxLines:
                                    4, // Allows the TextField to expand as needed, or set a specific max number of lines
                                decoration: InputDecoration(
                                  hintText: 'Notes',
                                  border:
                                      OutlineInputBorder(), // Optional: Adds a border around the text field
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    emptyList();
                                  },
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    save();
                                  },
                                  child: Text(
                                    'Send',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
