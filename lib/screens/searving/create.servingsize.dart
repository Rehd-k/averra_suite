import 'package:flutter/material.dart';

class CreateServingsize extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController title;
  final TextEditingController shortHand;
  final Function handleSubmitData;
  final String id;
  final Function updateservingsize;

  const CreateServingsize({
    super.key,
    required this.formKey,
    required this.title,
    required this.shortHand,
    required this.handleSubmitData,
    required this.id,
    required this.updateservingsize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
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
                controller: shortHand,
                decoration: InputDecoration(
                  labelText: 'Short Hand',
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
              id == ''
                  ? ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          handleSubmitData();
                        }
                      },
                      child: Text('Submit'),
                    )
                  : OutlinedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          updateservingsize();
                        }
                      },
                      child: Text('Update'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
