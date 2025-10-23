import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../helpers/financial_string_formart.dart';
import '../../service/api.service.dart';

class AddProducts extends StatefulWidget {
  final String? barcode;
  final Function onClose;
  const AddProducts({super.key, this.barcode, required this.onClose});

  @override
  AddProductsState createState() => AddProductsState();
}

class AddProductsState extends State<AddProducts> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

  final categoryController = TextEditingController();

  final priceController = TextEditingController();

  final roqController = TextEditingController();

  final quantityController = TextEditingController();

  final descriptionController = TextEditingController();

  final brandController = TextEditingController();

  final supplierController = TextEditingController();

  final weightController = TextEditingController();

  final unitController = TextEditingController();

  final barcodeController = TextEditingController();

  final imageUrlController = TextEditingController();

  bool isAvailableController = true;

  bool sellUnits = true;

  final typeQuantityController = TextEditingController();

  final soldController = TextEditingController();

  final userController = TextEditingController();

  final servingPriceController = TextEditingController();

  final StringBuffer buffer = StringBuffer();

  final ApiService apiServices = ApiService();

  int quantity = 0;

  String servingSize = '';

  List<String> categories = [''];

  List<String> servingSizes = [''];

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    priceController.dispose();
    roqController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    brandController.dispose();
    supplierController.dispose();
    weightController.dispose();
    unitController.dispose();
    barcodeController.dispose();
    imageUrlController.dispose();
    typeQuantityController.dispose();
    soldController.dispose();
    servingPriceController.dispose();

    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final dynamic response = await apiServices.post('/products', {
        'title': titleController.text,
        'category': categoryController.text,
        'price': priceController.text,
        'roq': roqController.text,
        'description': descriptionController.text,
        'brand': brandController.text,
        'weight': weightController.text,
        'unit': unitController.text,
        'barcode': barcodeController.text,
        'isAvailable': isAvailableController,
        'sellUnits': sellUnits,
        'servingQuantity': int.tryParse(typeQuantityController.text),
        'servingPrice': int.tryParse(servingPriceController.text),
        'type': servingSize,
      });

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        setState(() {
          servingSize = '';
        });

        doShowToast('Added', ToastificationType.success);
        widget.onClose();
        _formKey.currentState!.reset();
      } else {
        doShowToast('Error', ToastificationType.error);
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    barcodeController.text = widget.barcode ?? '';
    super.initState();
    fetchDbData();
  }

  Future<void> fetchDbData() async {
    final response = await Future.wait([
      apiServices.get('category?sort={"title" : "1"}'),
      apiServices.get('servingsize?sort={"title" : "1"}'),
    ]);

    final List<dynamic> cat = response[0].data;
    final List<dynamic> serving = response[1].data;
    setState(() {
      categories.addAll(cat.map((e) => e['title'].toString()).toList());
      servingSizes.addAll(serving.map((e) => e['title'].toString()).toList());
    });
  }

  void doShowToast(String toastMessage, ToastificationType type) {
    toastification.show(
      title: Text(toastMessage),
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            widget.onClose();
          },
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.refresh_outlined),
            tooltip: 'Reset Form',
            onPressed: () {
              _formKey.currentState?.reset();
              titleController.clear();
              categoryController.clear();
              priceController.clear();
              roqController.clear();
              quantityController.clear();
              descriptionController.clear();
              brandController.clear();
              supplierController.clear();
              weightController.clear();
              unitController.clear();
              barcodeController.clear();
              imageUrlController.clear();
              soldController.clear();
              servingPriceController.clear();
              setState(() {
                isAvailableController = true;
                servingSize = '';
                sellUnits = true;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              // Collect barcode characters
              buffer.write(event.character ?? '');
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                final scannedData = buffer.toString().trim();

                barcodeController.text = scannedData;
                buffer.clear();
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
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
                          return 'Please enter the product name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: categoryController.text.isNotEmpty
                          ? categoryController.text
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),
                      ),
                      isExpanded: false,
                      items: categories
                          .where((c) => c.isNotEmpty)
                          .map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          categoryController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: servingSize,
                      decoration: InputDecoration(
                        labelText: 'Product Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),
                      ),
                      items: servingSizes
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type == ''
                                    ? ''
                                    : type[0].toUpperCase() + type.substring(1),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          servingSize = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    if (servingSize != 'unit')
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: typeQuantityController,
                        decoration: InputDecoration(
                          labelText:
                              'Quantity in ${capitalizeFirstLetter(servingSize)} *',
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
                            return 'Please enter $servingSize Quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return '$servingSize Quantity must be a number';
                          }
                          if (int.parse(value) < 1) {
                            return '$servingSize Quantity cannot be less than 1';
                          }
                          return null;
                        },
                      ),
                    if (servingSize != 'unit') SizedBox(height: 10),
                    if (servingSize != 'unit')
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: servingPriceController,
                        decoration: InputDecoration(
                          labelText:
                              '${capitalizeFirstLetter(servingSize)} Selling Price *',
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
                          if ((value == null || value.isEmpty)) {
                            return 'Please enter $servingSize Price';
                          }
                          if (int.tryParse(value) == null) {
                            return '$servingSize Price must be a number';
                          }
                          if (int.parse(value) < 1) {
                            return '$servingSize Quantity cannot be less than 1';
                          }
                          return null;
                        },
                      ),
                    if (servingSize != 'unit') SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Unit Selling Price *',
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
                          return 'Please enter Price';
                        }
                        if (int.parse(value) < 0) {
                          return 'Price cant be 0 or less';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: roqController,
                      decoration: InputDecoration(
                        labelText: 'Re-Order Quantity *',
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
                          return 'Please enter Re-Order Quantity';
                        }
                        if (int.parse(value) < 1) {
                          return 'Re-Order Quantity cannot be less than 1';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
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
                    SizedBox(height: 10),
                    TextFormField(
                      controller: brandController,
                      decoration: InputDecoration(
                        labelText: 'Brand',
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
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight',
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
                    SizedBox(height: 10),
                    DropdownMenu(
                      width: double.infinity,
                      initialSelection: '',
                      controller: unitController,

                      requestFocusOnTap: true,
                      label: const Text('Units'),
                      // onSelected: (ColorLabel? color) {
                      //   setState(() {
                      //     selectedColor = color;
                      //   });
                      // },
                      dropdownMenuEntries:
                          [
                            'kg',
                            'g',
                            'lb',
                            'oz',
                            'l',
                            'ml',
                            'unit',
                          ].map<DropdownMenuEntry<String>>((category) {
                            return DropdownMenuEntry(
                              value: category,
                              label: category,
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Product Id *',
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(flex: 5, child: Text('Is Available ')),

                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('True'),
                                leading: Radio<bool>(
                                  value: true,
                                  groupValue: isAvailableController,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isAvailableController = value!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('False'),
                                leading: Radio<bool>(
                                  value: false,
                                  groupValue: isAvailableController,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isAvailableController = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Divider(),
                    if (servingSize != 'unit')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(flex: 5, child: Text('Sell In Units ')),

                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('True'),
                                  leading: Radio<bool>(
                                    value: true,
                                    groupValue: sellUnits,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        sellUnits = value!;
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('False'),
                                  leading: Radio<bool>(
                                    value: false,
                                    groupValue: sellUnits,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        sellUnits = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ElevatedButton(
                      onPressed: () {
                        handleSubmit(context);
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
