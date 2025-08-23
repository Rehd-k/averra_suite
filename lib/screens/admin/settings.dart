import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';

@RoutePage()
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final firmName = TextEditingController();

  final roles = TextEditingController();

  @override
  void dispose() {
    firmName.dispose();
    roles.dispose();
    super.dispose();
  }

  _showToast(String message, ToastificationType type) {
    toastification.show(
      title: Text('Loading'),
      description: Text(message),
      type: type,
    );
  }

  void handleSubmit(BuildContext context) async {
    _showToast('Adding Setting', ToastificationType.info);

    await apiService.post('settings', {
      'firm_name': firmName.text,
      'roles': roles.text.split(','),
    });
    _showToast('Setting Added', ToastificationType.success);
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
              children: <Widget>[
                TextFormField(
                  controller: firmName,
                  decoration: InputDecoration(
                    labelText: 'Firm Name *',
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
                      return 'Please enter the first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: roles,
                  decoration: InputDecoration(
                    labelText: 'roles *',
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
                      return 'Please enter the first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      handleSubmit(context);
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
