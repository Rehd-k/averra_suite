import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ViewUser extends StatefulWidget {
  final String id;
  const ViewUser({super.key, required this.id});

  @override
  ViewUserState createState() => ViewUserState();
}

class ViewUserState extends State<ViewUser> {
  final ApiService apiService = ApiService();
  List<File> selectedFiles = [];

  bool isUploading = false;
  Future<void> uploadStaffFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  // Add this new method for uploading files
  Future<void> submitFiles() async {
    setState(() {
      isUploading = true;
    });

    try {
      FormData formData = FormData();

      for (var file in selectedFiles) {
        String fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      // Replace with your API endpoint
      final response = await apiService.post(
        'user/multiple',
        formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            // Add any required headers like authorization
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Files uploaded successfully')));
        setState(() {
          selectedFiles.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading files: $e')));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // Add this method to remove a file
  void removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: smallScreen ? 10 : 30, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Member Details',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'View and manage staff member information.',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  double spacing = 5;

                  double bigSide;
                  double smallSide;

                  bool isBigScreen;

                  if (maxWidth >= 900) {
                    bigSide = (maxWidth * 0.7) - spacing;
                    smallSide = (maxWidth * 0.3) - spacing;
                    isBigScreen = true;
                  } else {
                    bigSide = maxWidth;
                    smallSide = maxWidth;
                    isBigScreen = false;
                  }
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: bigSide,
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: isBigScreen ? 100 : 50,
                                      width: isBigScreen ? 100 : 50,
                                      child: CircleAvatar(),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sophia Clark',
                                          style: TextStyle(
                                            fontSize: isBigScreen ? 20 : 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Staff ID: 12345',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Personal Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Full Name : \nIkenna Kelvin',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Email : \ncoolmirth35@gmail.com',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Phone : \n08120766716',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Address : \n123 Elm Street, Anytown, USA',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Date of Birth : \n1994-05-15',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Gender : \nFemale',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Nationality : \nAmerican',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Marital Status : \nSingle',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Role & Employment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Job Title : \nSenior Analyst',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Department : \nFinance',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Start Date : \n2020-08-01',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Employment Type : \nFull-time',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Salary : \n₦85,000',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Work Location : \nHeadquarters',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Reporting Manager : \nEthan Bennett',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  'Shift Schedule : \nMonday to Friday, 9 AM - 5 PM',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: smallSide,
                        child: Column(
                          children: [
                            Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Documents',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  if (selectedFiles.isEmpty) ...[
                                    Center(
                                      child: FilledButton.tonalIcon(
                                        icon: Icon(Icons.add),
                                        onPressed: uploadStaffFiles,
                                        label: Text('Add New'),
                                      ),
                                    ),
                                  ] else ...[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                            ),
                                        itemCount: selectedFiles.length,
                                        itemBuilder: (context, index) {
                                          final file = selectedFiles[index];
                                          return Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child:
                                                    file.path
                                                        .toLowerCase()
                                                        .endsWith('.pdf')
                                                    ? Center(
                                                        child: Icon(
                                                          Icons.picture_as_pdf,
                                                          size: 50,
                                                        ),
                                                      )
                                                    : Image.file(
                                                        file,
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
                                                  onPressed: () =>
                                                      removeFile(index),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          FilledButton.tonalIcon(
                                            icon: Icon(Icons.add),
                                            onPressed: uploadStaffFiles,
                                            label: Text('Add More'),
                                          ),
                                          FilledButton.icon(
                                            icon: isUploading
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Icon(Icons.upload),
                                            onPressed: isUploading
                                                ? null
                                                : submitFiles,
                                            label: Text('Upload'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
