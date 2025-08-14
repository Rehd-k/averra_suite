import 'package:flutter/material.dart';

import '../../../service/api.service.dart';

class AddCategory extends StatefulWidget {
  final Function()? updateCategory;
  const AddCategory({super.key, required this.updateCategory});

  @override
  AddCategoryState createState() => AddCategoryState();
}

class AddCategoryState extends State<AddCategory> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final userController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();
    userController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    try {
      final dynamic response = await apiService.post('/category', {
        'title': nameController.text,
        'description': descriptionController.text,
        'user': userController.text,
      });

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        widget.updateCategory!();
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
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name *',
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
