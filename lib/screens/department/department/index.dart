import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/tables/gen_big_table/big_table_source.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../service/api.service.dart';
import 'create.department.dart';
import 'view.department.dart';

@RoutePage()
class DepartmentIndex extends StatefulWidget {
  const DepartmentIndex({super.key});

  @override
  DepartmentIndexState createState() => DepartmentIndexState();
}

class DepartmentIndexState extends State<DepartmentIndex> {
  final formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List filtereddepartments = [];
  late List departments = [];
  late Map settings = {};
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "title";
  bool ascending = true;
  bool active = true;
  String type = 'Store';
  List<String> access = [];

  void updateActive() {
    if (active) {
      setState(() {
        active = false;
      });
    } else {
      setState(() {
        active = true;
      });
    }
  }

  void setType(value) {
    setState(() {
      type = value;
    });
  }

  void handleSubmitData() async {
    doShowToast('loading...', ToastificationType.info);
    try {
      await apiService.post('department', {
        'title': title.text,
        'description': description.text,
        'type': type,
        'access': access,
      });
      doShowToast('New Department Added', ToastificationType.success);
      title.clear();
      description.clear();
      setState(() {
        type = 'Store';
        active = true;
      });
      getDepartments();
    } catch (e) {
      doShowToast('Error $e', ToastificationType.error);
    }
  }

  void addOrRemoveAccess(value) async {
    if (access.contains(value)) {
      access.remove(value);
    } else {
      access.add(value);
    }
  }

  void getDepartments() async {
    try {
      var allDepartment = await Future.wait([
        apiService.get('department'),
        apiService.get('settings'),
      ]);
      setState(() {
        departments = allDepartment[0].data;
        settings = allDepartment[1].data[0];
        filtereddepartments = List.from(departments);
        isLoading = false;
      });
    } catch (e) {
      doShowToast('Error $e', ToastificationType.error);
    }
  }

  void filterDepartments(String query) {
    setState(() {
      searchQuery = query;
      filtereddepartments = departments.where((department) {
        return department.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future deletedepartment(String id) async {
    await apiService.delete('department/$id');
    setState(() {
      departments.removeWhere((department) => department['_id'] == id);
      filtereddepartments = List.from(departments);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = departments.where((product) {
      return product.values.any(
        (value) =>
            value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }).toList();

    filteredCategories.sort((a, b) {
      if (ascending) {
        return a[sortBy].toString().compareTo(b[sortBy].toString());
      } else {
        return b[sortBy].toString().compareTo(a[sortBy].toString());
      }
    });

    return filteredCategories;
  }

  @override
  void initState() {
    getDepartments();
    super.initState();
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      body: Row(
        children: [
          if (!smallScreen)
            Expanded(
              flex: 1,
              child: CreateDepartment(
                formKey: formKey,
                title: title,
                description: description,
                active: active,
                type: type,
                setType: setType,
                updateActive: updateActive,
                handleSubmitData: handleSubmitData,
                settings: settings,
                addOrRemoveAccess: addOrRemoveAccess,
              ),
            ),
          SizedBox(width: smallScreen ? 0 : 20),
          Expanded(
            flex: 2,
            child: ViewDepartments(
              searchController: searchController,
              isLoading: isLoading,
              sortBy: sortBy,
              ascending: ascending,
              getFilteredAndSortedRows: getFilteredAndSortedRows,
              deleteDepartment: deletedepartment,
              filteredDepartments: filtereddepartments,
              filterDepartment: filterDepartments,
            ),
          ),
        ],
      ),
    );
  }
}
