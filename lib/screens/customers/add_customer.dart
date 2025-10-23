import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';

class AddCustomer extends StatefulWidget {
  final dynamic updateCustomer;
  const AddCustomer({super.key, this.updateCustomer});

  @override
  AddCustomerState createState() => AddCustomerState();
}

class AddCustomerState extends State<AddCustomer> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final contactController = TextEditingController();

  final emailController = TextEditingController();

  final phoneNumberController = TextEditingController();

  final addressController = TextEditingController();

  final initiatorController = TextEditingController();

  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    initiatorController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    contactController.dispose();
    super.dispose();
  }

  void _showToast(String toastMessage, ToastificationType type) {
    toastification.show(
      title: Text(toastMessage),
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  Future<void> handleSubmit(BuildContext context) async {
    try {
      final dynamic response = await apiService.post('/customer', {
        'name': nameController.text,
        'email': emailController.text,
        'phone_number': phoneNumberController.text,
        'address': addressController.text,
        'city': cityController.text,
        'state': stateController.text,
        'zipCode': zipCodeController.text,
        'country': countryController.text,
      });

      _showToast("Done", ToastificationType.success);

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        if (widget.updateCustomer != null) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer Created Successfully'),
              // ignore: use_build_context_synchronously
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
          widget.updateCustomer!();
        }
      } else {
        throw Exception(
          'Failed to create customer: ${response.statusCode} ${response.data['message']}',
        );
      }
      // ignore: empty_catches
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          // ignore: use_build_context_synchronously
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                  keyboardType: TextInputType.phone,
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
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
                  keyboardType: TextInputType.streetAddress,
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
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
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
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
                  controller: zipCodeController,
                  decoration: InputDecoration(
                    labelText: 'Zip Code',
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
                DropdownButtonFormField<String>(
                  initialValue: stateController.text.isNotEmpty
                      ? stateController.text
                      : null,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 15,
                    ),
                  ),
                  items:
                      [
                            'Abia',
                            'Adamawa',
                            'Akwa Ibom',
                            'Anambra',
                            'Bauchi',
                            'Bayelsa',
                            'Benue',
                            'Borno',
                            'Cross River',
                            'Delta',
                            'Ebonyi',
                            'Edo',
                            'Ekiti',
                            'Enugu',
                            'FCT',
                            'Gombe',
                            'Imo',
                            'Jigawa',
                            'Kaduna',
                            'Kano',
                            'Katsina',
                            'Kebbi',
                            'Kogi',
                            'Kwara',
                            'Lagos',
                            'Nasarawa',
                            'Niger',
                            'Ogun',
                            'Ondo',
                            'Osun',
                            'Oyo',
                            'Plateau',
                            'Rivers',
                            'Sokoto',
                            'Taraba',
                            'Yobe',
                            'Zamfara',
                          ]
                          .map(
                            (state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      stateController.text = value ?? '';
                    });
                  },
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please select a state';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    handleSubmit(context);
                    if (_formKey.currentState!.validate()) {
                      // Process data
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Processing Data'),
                          duration: Duration(seconds: 1),
                        ),
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
