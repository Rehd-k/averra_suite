import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../helpers/financial_string_formart.dart';

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
  late Map loadedUser = {};

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

  Future<void> findUser() async {
    var user = await apiService.get('user/id/${widget.id}');

    setState(() {
      loadedUser = user.data;
    });
  }

  @override
  void initState() {
    findUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(),
      body: loadedUser.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: smallScreen ? 10 : 30,
                  right: 10,
                ),
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
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
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
                                              child: CircleAvatar(
                                                child: Center(
                                                  child: Text(
                                                    getInitials(
                                                      '${loadedUser['lastName']}',
                                                      '${loadedUser['firstName']}',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  capitalizeFirstLetter(
                                                    '${loadedUser['lastName']} ${loadedUser['firstName']}',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: isBigScreen
                                                        ? 20
                                                        : 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Staff Access: ${loadedUser['role']}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Full Name : \n${loadedUser['lastName']} ${loadedUser['firstName']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Email : \n${loadedUser['email']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "Phone : \n${loadedUser['phone_number']}",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Address : \n${loadedUser['address']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Date of Birth : \n${loadedUser['DoB']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Gender : \n${loadedUser['gender']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Nationality : \n${loadedUser['nationality']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Marital Status : \n${loadedUser['marital_status']}',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Job Title : \n${loadedUser['job_title']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Department : \n${loadedUser['department']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Start Date : \n${loadedUser['start_date']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Employment Type : \n${loadedUser['employment_type']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Salary : \n${loadedUser['salary']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Work Location : \n${loadedUser['salary']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Reporting Manager : \n${loadedUser['reporting_manager']}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Text(
                                                          'Shift Schedule : \n${loadedUser['shift_schedule']}',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 8,
                                                      mainAxisSpacing: 8,
                                                    ),
                                                itemCount: selectedFiles.length,
                                                itemBuilder: (context, index) {
                                                  final file =
                                                      selectedFiles[index];
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child:
                                                            file.path
                                                                .toLowerCase()
                                                                .endsWith(
                                                                  '.pdf',
                                                                )
                                                            ? Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  size: 50,
                                                                ),
                                                              )
                                                            : Image.file(
                                                                file,
                                                                fit: BoxFit
                                                                    .cover,
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
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
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
            ),
    );
  }
}
