import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../service/api.service.dart';

@RoutePage()
class AddSupplier extends StatefulWidget {
  const AddSupplier({super.key});

  @override
  AddSupplierState createState() => AddSupplierState();
}

class AddSupplierState extends State<AddSupplier> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final contactController = TextEditingController();

  final emailController = TextEditingController();

  final phoneNumberController = TextEditingController();

  final addressController = TextEditingController();

  final initiatorController = TextEditingController();
  final _notesController = TextEditingController();
  final contactPerson = TextEditingController();

  String status = 'active';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    initiatorController.dispose();
    _notesController.dispose();
    contactPerson.dispose();
    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    showToast('Loading...', ToastificationType.info);
    await apiService.post('/supplier', {
      'name': nameController.text,
      'email': emailController.text,
      'phone_number': phoneNumberController.text,
      'address': addressController.text,
      'status': status,
      'note': _notesController.text,
      'contactPerson': contactPerson.text,
    });
    showToast('Created', ToastificationType.success);

    nameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    addressController.clear();
    _notesController.clear();
  }

  handleStatusChange(value) {
    status = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black12),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine how many cards per row based on screen width
                    double maxWidth = constraints.maxWidth;
                    int cardsPerRow;

                    if (maxWidth >= 900) {
                      cardsPerRow = 2; // large screen
                    } else if (maxWidth >= 600) {
                      cardsPerRow = 2; // medium screen
                    } else {
                      cardsPerRow = 1; // small screen
                    }

                    // Card width calculation with spacing
                    double spacing = 16.0;
                    double cardWidth =
                        (maxWidth - (spacing * (cardsPerRow - 1))) /
                        cardsPerRow;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name *',
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
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: 'Status',
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
                            value: status,
                            items: [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Inactive'),
                              ),
                            ],

                            onChanged: (value) {
                              handleStatusChange(value);
                            },
                          ),
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: contactPerson,
                            decoration: InputDecoration(
                              labelText: 'Contact Person',
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
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
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
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: TextFormField(
                            keyboardType: TextInputType.streetAddress,
                            controller: addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
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
                        ),

                        SizedBox(
                          child: TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Add notes...",
                              labelText: "Notes",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              handleSubmit(context);
                              if (_formKey.currentState!.validate()) {
                                // Process data
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Processing Data')),
                                );
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
