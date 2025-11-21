import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';

@RoutePage()
class AddUser extends StatefulWidget {
  final Function()? updateUserList;
  final bool? isGod;
  const AddUser({super.key, this.updateUserList, this.isGod});

  @override
  AddUserState createState() => AddUserState();
}

class AddUserState extends State<AddUser> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  File? selectedFile;

  final username = TextEditingController();

  final firstName = TextEditingController();

  final lastName = TextEditingController();

  final password = TextEditingController();

  final address = TextEditingController();

  final email = TextEditingController();

  final role = TextEditingController();

  final gender = TextEditingController();

  final dob = TextEditingController();

  final nationality = TextEditingController();

  final maritalStatus = TextEditingController();

  final jobTitle = TextEditingController();

  final department = TextEditingController();

  final reportingManager = TextEditingController();

  final shiftSchedule = TextEditingController();

  final phoneNumber = TextEditingController();

  String selectedSupervisor = '';

  late List branches = [];
  late List departments = [];
  late List supervisors = [];
  late String locations;
  late FocusNode usernameFocus;
  bool showForm = false;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    password.dispose();
    role.dispose();
    gender.dispose();
    nationality.dispose();
    maritalStatus.dispose();
    shiftSchedule.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getLocations();
    if (widget.isGod != true) {
      getDepartments();
      getSupervisors();
    }
  }

  void getSupervisors() async {
    var responce = await apiService.get(
      'user?filter={"role" : "supervisor"}&select=" username "',
    );
    setState(() {
      showForm = true;
      supervisors = responce.data;
      supervisors.insert(0, {'_id': 'all', 'username': 'Select Supervisor'});
    });
  }

  void getLocations() async {
    var responce = await apiService.get('/location');
    setState(() {
      showForm = true;
      branches = responce.data;
      branches.insert(0, {'_id': 'all', 'name': 'All Locations'});
    });
  }

  void getDepartments() async {
    var responce = await apiService.get('/department');
    setState(() {
      departments = responce.data;
    });
  }

  void handleAddLocation(String location) {
    setState(() {
      locations = location;
    });
  }

  void handleSelectedSupervisor(String res) {
    setState(() {
      selectedSupervisor = res;
    });
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      title: Text('Loading'),
      description: Text(message),
      type: type,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  void handleSubmit(BuildContext context) async {
    _showToast('Adding User', ToastificationType.info);
    if (widget.isGod == true) {
      await apiService.post('user/godadd', {
        'firstName': firstName.text,
        'lastName': lastName.text,
        'username': username.text,
        'password': password.text,
        'role': widget.isGod == true ? 'god' : role.text,
        'location': 'all',
        'email': email.text,
        'phone_number': phoneNumber.text,
      });
      _showToast('User Added Successfully', ToastificationType.success);
    } else {
      await apiService.post('/auth/register', {
        'firstName': firstName.text,
        'lastName': lastName.text,
        'username': username.text,
        'password': password.text,
        'role': role.text,
        'location': locations,
        'email': email.text,
        'shiftSchedule': shiftSchedule.text,
        'department': department.text,
        'phone_number': phoneNumber.text,
        'reporting_manager': selectedSupervisor,
      });
      _showToast('User Added Successfully', ToastificationType.success);
    }
  }

  Future<void> uploadStaffFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  void removeFile() {
    setState(() {
      selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isGod == true ? AppBar() : null,
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine how many cards per row based on screen width
                      double maxWidth = constraints.maxWidth;
                      int cardsPerRow;

                      if (maxWidth >= 900) {
                        cardsPerRow = 4; // large screen
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

                      return Form(
                        key: _formKey,
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: TextFormField(
                                controller: firstName,
                                decoration: InputDecoration(
                                  labelText: 'First Name *',
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
                                    return 'Please enter the first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: TextFormField(
                                controller: lastName,
                                decoration: InputDecoration(
                                  labelText: 'Last Name *',
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
                                    return 'Please enter the first name';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: TextFormField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
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
                                controller: username,
                                decoration: InputDecoration(
                                  labelText: 'Username',
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
                                controller: phoneNumber,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number *',
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
                                    return 'Please enter a Phone Number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: TextFormField(
                                controller: password,
                                decoration: InputDecoration(
                                  labelText: 'Password',
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
                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: InputDecoration(
                                  labelText: 'Department',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: departments
                                    .map<
                                      DropdownMenuItem<Map<String, dynamic>>
                                    >((branch) {
                                      return DropdownMenuItem<
                                        Map<String, dynamic>
                                      >(
                                        value:
                                            branch, // Assuming 'id' is the key for the value
                                        child: Text(
                                          capitalizeFirstLetter(
                                            branch['title'],
                                          ),
                                        ), // Assuming 'name' is the key for the display text
                                      );
                                    })
                                    .toList(),
                                onChanged: (value) {
                                  department.text = value?['_id']!;
                                },
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: DropdownButtonFormField<String>(
                                initialValue: 'waiter', // 👈 initial value
                                onChanged: (value) {
                                  role.text = value ?? '';
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    [
                                      'admin',
                                      'accountant',
                                      'bar',
                                      'cashier',
                                      'chef',
                                      'manager',
                                      'staff',
                                      'supervisor',
                                      'store keeper',
                                      'waiter',
                                    ].map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(
                                          capitalizeFirstLetter(category),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Location',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: branches.map<DropdownMenuItem<String>>((
                                  branch,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: branch['name']
                                        .toString(), // Assuming 'id' is the key for the value
                                    child: Text(
                                      branch['name'],
                                    ), // Assuming 'name' is the key for the display text
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  handleAddLocation(value!);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a location';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Reporting Supervisor',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: supervisors.map<DropdownMenuItem<String>>((
                                  branch,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: branch['username']
                                        .toString(), // Assuming 'id' is the key for the value
                                    child: Text(
                                      branch['username'],
                                    ), // Assuming 'name' is the key for the display text
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  handleSelectedSupervisor(value!);
                                },
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: TextFormField(
                                controller: address,
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
                              width: cardWidth,
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Select Date',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () => _selectDate(context),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: ['male', 'female']
                                    .map<DropdownMenuItem<String>>((branch) {
                                      return DropdownMenuItem<String>(
                                        value: branch
                                            .toString(), // Assuming 'id' is the key for the value
                                        child: Text(
                                          capitalizeFirstLetter(branch),
                                        ), // Assuming 'name' is the key for the display text
                                      );
                                    })
                                    .toList(),
                                onChanged: (value) {
                                  gender.text = value!;
                                },
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: TextFormField(
                                controller: jobTitle,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  labelText: 'Job Title',
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
                                controller: shiftSchedule,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  labelText: 'Shift Shedule',
                                  helperText:
                                      'Monday - Friday (08:00AM - 06:00Pm)',
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
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Nationality',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: ['Nigeria'].map<DropdownMenuItem<String>>((
                                  branch,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: branch
                                        .toString(), // Assuming 'id' is the key for the value
                                    child: Text(
                                      capitalizeFirstLetter(branch),
                                    ), // Assuming 'name' is the key for the display text
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  nationality.text = value!;
                                },
                              ),
                            ),

                            SizedBox(
                              width: cardWidth,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Marital Status',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: ['Married', 'Single']
                                    .map<DropdownMenuItem<String>>((branch) {
                                      return DropdownMenuItem<String>(
                                        value: branch
                                            .toString(), // Assuming 'id' is the key for the value
                                        child: Text(
                                          capitalizeFirstLetter(branch),
                                        ), // Assuming 'name' is the key for the display text
                                      );
                                    })
                                    .toList(),
                                onChanged: (value) {
                                  maritalStatus.text = value!;
                                },
                              ),
                            ),

                            if (selectedFile == null)
                              SizedBox(
                                width: cardWidth,
                                child: Center(
                                  child: FilledButton.tonalIcon(
                                    icon: Icon(Icons.add),
                                    onPressed: uploadStaffFiles,
                                    label: Text('Add New'),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                width: cardWidth,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.file(
                                        selectedFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => removeFile(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleSubmit(context);
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
