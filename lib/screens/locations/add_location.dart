import 'package:flutter/material.dart';

class AddLocation extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;

  final TextEditingController locationController;

  final TextEditingController managerController;

  final TextEditingController contactController;

  final TextEditingController openingController;

  final TextEditingController closingController;
  final Function handleSubmit;

  const AddLocation(
      {super.key,
      required this.nameController,
      required this.locationController,
      required this.managerController,
      required this.contactController,
      required this.openingController,
      required this.closingController,
      required this.formKey,
      required this.handleSubmit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.blue)),
                    labelStyle: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 15),
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
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      labelStyle: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 15),
                    )),
                SizedBox(height: 10),
                TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: managerController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      labelStyle: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 15),
                    )),
                SizedBox(height: 10),
                TextFormField(
                    keyboardType: TextInputType.streetAddress,
                    controller: openingController,
                    decoration: InputDecoration(
                      labelText: 'Opening Hours',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      labelStyle: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 15),
                    )),
                SizedBox(height: 10),
                TextFormField(
                    keyboardType: TextInputType.streetAddress,
                    controller: closingController,
                    decoration: InputDecoration(
                      labelText: 'Closing Hours',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      labelStyle: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 15),
                    )),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    handleSubmit();
                    if (formKey.currentState!.validate()) {
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
