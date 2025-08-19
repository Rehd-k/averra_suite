import 'package:flutter/material.dart';

import '../../service/api.service.dart';

class AddExpenses extends StatefulWidget {
  final dynamic updateExpenses;
  const AddExpenses({super.key, this.updateExpenses});

  @override
  AddExpensesState createState() => AddExpensesState();
}

class AddExpensesState extends State<AddExpenses> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final categoryController = TextEditingController();

  final descriptionController = TextEditingController();

  final amountController = TextEditingController();

  final amountPaidController = TextEditingController();

  final paidController = TextEditingController();

  @override
  void dispose() {
    categoryController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    amountPaidController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    try {
      final dynamic response = await apiService.post('/expense', {
        'category': categoryController.text,
        'description': descriptionController.text,
        'amount': amountController.text,
        'amountPaid': amountPaidController.text,
        'paid': paidController.text,
        'createdAt': DateTime.now().toString(),
      });

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        if (widget.updateExpenses != null) {
          widget.updateExpenses!();
        }
      } else {}
      // ignore: empty_catches
    } catch (e) {}
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
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category *',
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
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description *',
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
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount *',
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
                  controller: amountPaidController,
                  decoration: InputDecoration(
                    labelText: 'Amount Paid *',
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
                ElevatedButton(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
