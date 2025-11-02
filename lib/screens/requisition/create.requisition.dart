import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

@RoutePage()
class CreateRequisition extends StatefulWidget {
  const CreateRequisition({super.key});

  @override
  CreateRequisitionState createState() => CreateRequisitionState();
}

class CreateRequisitionState extends State<CreateRequisition> {
  ApiService apiService = ApiService();
  final TextEditingController productController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final JsonEncoder jsonEncoder = JsonEncoder();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> selectedProducts = [];
  Map<String, dynamic>? selectedProduct;
  String searchFeild = 'title';
  String searchQuery = '';
  num skip = 0;
  num limit = 10;
  num totalBalance = 0;

  Future<List<Map>> getProducts(String query) async {
    var sorting = jsonEncoder.convert({"title": 'asc'});
    var response = await Future.wait([
      apiService.get(
        'products?filter={"$searchFeild" : {"\$regex" : "${query.toLowerCase()}"}}&skip=$skip&limit=$limit&sort=$sorting',
      ),
      apiService.get(
        'rawmaterial?filter={"$searchFeild" : {"\$regex" : "${query.toLowerCase()}"}}&skip=$skip&limit=$limit&sort=$sorting',
      ),
    ]);

    var {'products': products, 'totalDocuments': totalDocuments} =
        response[0].data;

    var {'materials': materials, 'totalDocuments': totalmaterialsDocuments} =
        response[1].data;
    products.addAll(materials);
    return List<Map>.from(products);
  }

  void selectProductFromSugestion(dynamic suggestion, dynamic modelState) {
    var exists = selectedProducts.firstWhere(
      (element) => element['productId'] == suggestion['_id'],
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
    if (costController.text.isEmpty || num.parse(costController.text) < 1) {
      showToast('Cost Value is not Valid', ToastificationType.info);
      return;
    }

    var item = {
      'productId': selectedProduct?['_id'],
      'product_title': selectedProduct?['title'],
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

  Future<void> save(String type) async {
    Map<String, dynamic>? dataToSave;
    if (selectedProducts.isEmpty) {
      return;
    }
    if (type == 'branch') {
      var result = await apiService.get('location');
      List<dynamic> locations = result.data;

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
        'from': selectedLocation['name'],
        'products': selectedProducts,
        'totalCost': totalBalance,
      };
    } else {
      dataToSave = {
        'notes': noteController.text,
        'from': type,
        'products': selectedProducts,
        'totalCost': totalBalance,
      };
    }
    await apiService.post('reqisition', dataToSave);
    showToast('Done', ToastificationType.success);
    setState(() {
      selectedProducts = [];
      totalBalance = 0;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    productController.dispose();
    costController.dispose();
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;

    return Scaffold(
      floatingActionButton: smallScreen
          ? FloatingActionButton.small(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                buildProductsInput(
                                  selectedProduct,
                                  productController,
                                  getProducts,
                                  selectProductFromSugestion,
                                  deselectProductFromSugestion,
                                  onchange,
                                  setModalState,
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
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
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
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
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
                                      addToList(setModalState);
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
                        );
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.add, size: 10),
            )
          : null,
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
                              return 'Cost Cannot be Empty';
                            }
                            if (int.parse(value) < 1) {
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
                                    save('branch');
                                  },
                                  child: Text(
                                    'From Branch',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    save('new purchase');
                                  },
                                  child: Text(
                                    'New Request',
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

Widget buildProductsInput(
  dynamic selectedProduct,
  TextEditingController productController,
  dynamic fetchProducts,
  dynamic selectUserFromSugestion,
  dynamic deselectUserFromSugestion,
  dynamic onchange,
  dynamic setModalState,
) {
  return selectedProduct == null
      ? Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: productController,
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      onchange(setModalState);
                    },
                  ),
                ),
              ],
            ),
            if (productController.text.isNotEmpty)
              FutureBuilder<List<Map>>(
                future: fetchProducts(productController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'No suggestions',
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  } else {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.map((suggestion) {
                        return ListTile(
                          title: Text(
                            suggestion['title'] ??
                                suggestion['productId']['title'],
                            style: TextStyle(fontSize: 10),
                          ),
                          subtitle: Text(
                            suggestion['category'] ?? '',
                            style: TextStyle(fontSize: 10),
                          ),
                          trailing: Text(
                            suggestion['quantity'].toString().formatToFinancial(
                              isMoneySymbol: false,
                            ),
                            style: TextStyle(fontSize: 10),
                          ),
                          onTap: () {
                            selectUserFromSugestion(suggestion, setModalState);
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
          label: Text(
            selectedProduct?['title'] ?? selectedProduct?['productId']['title'],
            style: TextStyle(fontSize: 10),
          ),
          deleteIcon: Icon(Icons.close, size: 10),
          onDeleted: () {
            deselectUserFromSugestion(setModalState);
          },
        );
}

class LocationPickerModal extends StatelessWidget {
  final List<dynamic> locations;

  const LocationPickerModal({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600
        ? 4
        : 2; // 4 on big screens, 2 on small

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: locations.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5, // pill-like
        ),
        itemBuilder: (_, index) {
          final location = locations[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, location); // return the selected item
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                location['name'] ?? 'Unnamed',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
