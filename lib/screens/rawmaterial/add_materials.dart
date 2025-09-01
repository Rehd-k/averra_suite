import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../helpers/financial_string_formart.dart';
import '../../service/api.service.dart';

class AddRawMaterial extends StatefulWidget {
  final String? barcode;
  final Function onClose;
  const AddRawMaterial({super.key, this.barcode, required this.onClose});

  @override
  AddRawMaterialState createState() => AddRawMaterialState();
}

class AddRawMaterialState extends State<AddRawMaterial> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

  final categoryController = TextEditingController();

  final roqController = TextEditingController();

  final quantityController = TextEditingController();

  final descriptionController = TextEditingController();

  final barcodeController = TextEditingController();

  final servingSizeController = TextEditingController();

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
    roqController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final dynamic response = await apiServices.post('rawmaterial', {
        'title': titleController.text,
        'category': categoryController.text,
        'servingSize': int.tryParse(quantityController.text) ?? 1,
        'unit': servingSizeController.text,
        'roq': roqController.text,
        'description': descriptionController.text,
        'barcode': barcodeController.text,
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

  doShowToast(String toastMessage, ToastificationType type) {
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
              roqController.clear();
              quantityController.clear();
              servingSizeController.clear();
              descriptionController.clear();
              barcodeController.clear();
              setState(() {
                servingSize = '';
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
                      value: categoryController.text.isNotEmpty
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
                    DropdownMenu(
                      width: double.infinity,
                      initialSelection: '',
                      controller: servingSizeController,

                      requestFocusOnTap: true,
                      label: const Text('Serving Size'),
                      onSelected: (String? size) {
                        setState(() {
                          servingSize = size!;
                        });
                      },
                      dropdownMenuEntries: servingSizes
                          .map<DropdownMenuEntry<String>>((serving) {
                            return DropdownMenuEntry(
                              value: serving,
                              label: serving,
                            );
                          })
                          .toList(),
                    ),
                    if (servingSize != '') SizedBox(height: 10),
                    if (servingSize != '')
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: quantityController,
                        decoration: InputDecoration(
                          hint: Text('Leave Empty if Unknown'),
                          labelText:
                              '${capitalizeFirstLetter(servingSize)} Quantity',
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
                    SizedBox(height: 20),
                    Divider(),
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
