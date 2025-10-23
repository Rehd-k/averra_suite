import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';

class CreateDepartment extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController title;
  final TextEditingController description;
  final bool active;
  final String type;
  final Function updateActive;
  final Function handleSubmitData;
  final Function setType;
  final Map settings;
  final Function addOrRemoveAccess;
  const CreateDepartment({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.active,
    required this.updateActive,
    required this.handleSubmitData,
    required this.type,
    required this.setType,
    required this.settings,
    required this.addOrRemoveAccess,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 50, left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: title,
                decoration: InputDecoration(
                  labelText: 'Title *',
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
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: description,
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
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(
                  labelText: 'Select Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setType(newValue);
                },
                items: ['Store', 'Dispensary'].map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select an option' : null,
              ),

              SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Active'),
                value: active,
                onChanged: (bool value) {
                  updateActive();
                },
              ),
              SizedBox(height: 10),
              MultiSelectContainer(
                items: settings['roles']!.map<MultiSelectCard>((entry) {
                  return MultiSelectCard(value: entry, label: entry);
                }).toList(),
                onChange: (allSelectedItems, selectedItem) {
                  addOrRemoveAccess(selectedItem);
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    handleSubmitData();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
