import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:toastification/toastification.dart';

import '../../components/tables/gen_big_table/big_table_source.dart';
import '../../service/api.service.dart';
import '../../service/gateway.service.dart';

class AddBank extends StatefulWidget {
  final dynamic updateBank;
  const AddBank({super.key, this.updateBank});

  @override
  AddBankState createState() => AddBankState();
}

class AddBankState extends State<AddBank> {
  final GatewayService gatewayService = GatewayService();
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  late List settings;
  List<String> access = [];
  bool loading = true;
  final nameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    accountNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getSettings();
    super.initState();
  }

  Future<void> handleSubmit(BuildContext context) async {
    try {
      final dynamic response = gatewayService.createBank(
        nameController.text,
        accountNameController.text,
        accountNumberController.text,
        access,
      );

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        if (widget.updateBank != null) {
          widget.updateBank!();
        }
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  void getSettings() async {
    try {
      var allDepartment = await apiService.get('location');
      setState(() {
        settings = allDepartment.data;
        loading = false;
      });
    } catch (e) {
      doShowToast('Error $e', ToastificationType.error);
    }
  }

  void addOrRemoveAccess(dynamic value) async {
    if (access.contains(value)) {
      access.remove(value);
    } else {
      access.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name *',
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
                      return 'Please enter a bank name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: accountNameController,
                  decoration: InputDecoration(
                    labelText: 'Account Name *',
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
                      return 'Please enter Account Name';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                ),

                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: accountNumberController,
                  decoration: InputDecoration(
                    labelText: 'Account Number',
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
                    if (value != null || value!.isNotEmpty) {
                      if (int.parse(value).isNaN) {
                        return 'Please enter a Valid Account Number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a Valid Account Number';
                      }
                      return null;
                    } else {
                      return 'Please enter Account Number';
                    }
                  },
                  textCapitalization: TextCapitalization.characters,
                ),

                SizedBox(height: 10),
                if (!loading)
                  MultiSelectContainer(
                    items: settings.map<MultiSelectCard>((entry) {
                      return MultiSelectCard(
                        value: entry['name'],
                        label: entry['name'],
                      );
                    }).toList(),
                    onChange: (allSelectedItems, selectedItem) {
                      addOrRemoveAccess(selectedItem);
                    },
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      handleSubmit(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
