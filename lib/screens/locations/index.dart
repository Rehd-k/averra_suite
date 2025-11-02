import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import 'add_location.dart';
import 'view_locations.dart';

@RoutePage()
class LocationIndex extends StatefulWidget {
  const LocationIndex({super.key});

  @override
  LocationIndexState createState() => LocationIndexState();
}

class LocationIndexState extends State<LocationIndex> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final locationController = TextEditingController();

  final managerController = TextEditingController();

  final contactController = TextEditingController();

  final openingController = TextEditingController();

  final closingController = TextEditingController();

  final firmNameController = TextEditingController();

  Future<void> handleSubmit() async {
    try {
      await apiService.post('location', {
        'name': nameController.text,
        'location': locationController.text,
        'manager': managerController.text,
        'openingHours': openingController.text,
        'closingHours': closingController.text,
        'firm_name': firmNameController.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added')));
      getLocationsList();
    } catch (e) {
      showToast('Error : $e', ToastificationType.error);
    }
  }

  List filteredLocations = [];
  late List locations = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "name";
  bool ascending = true;

  void filterLocations(String query) {
    setState(() {
      searchQuery = query;
      filteredLocations = locations.where((location) {
        return location.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future updateLocationList() async {
    setState(() {
      isLoading = true;
    });
    var dblocations = await apiService.get('location?skip=${locations.length}');
    setState(() {
      locations.addAll(dblocations.data);
      filteredLocations = List.from(locations);
      isLoading = false;
    });
  }

  Future getLocationsList() async {
    var dblocations = await apiService.get('location');
    setState(() {
      locations = dblocations.data;
      filteredLocations = List.from(locations);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = locations.where((product) {
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

  int getColumnIndex(String columnName) {
    switch (columnName) {
      case 'name':
        return 0;
      case 'createdAt':
        return 1;
      case 'price':
        return 2;
      case 'quantity':
        return 3;
      default:
        return 0;
    }
  }

  Future deleteLocation(String id) async {
    await apiService.delete('location/$id');
    setState(() {
      locations.removeWhere((bank) => bank['_id'] == id);
      filteredLocations = List.from(locations);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocationsList();
    filteredLocations = List.from(locations);
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    managerController.dispose();
    contactController.dispose();
    openingController.dispose();
    closingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      floatingActionButton: smallScreen
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => AddLocation(
                    handleSubmit: handleSubmit,
                    nameController: nameController,
                    locationController: locationController,
                    managerController: managerController,
                    contactController: contactController,
                    openingController: openingController,
                    closingController: closingController,
                    formKey: _formKey,
                  ),
                );
              },
              child: Icon(Icons.add_outlined),
            )
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          FilledButton.icon(
            onPressed: () => showBarModalBottomSheet(
              expand: true,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => AddLocation(
                handleSubmit: handleSubmit,
                nameController: nameController,
                locationController: locationController,
                managerController: managerController,
                contactController: contactController,
                openingController: openingController,
                closingController: closingController,
                formKey: _formKey,
              ),
            ),
            label: Text('Add Location'),
            icon: Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            smallScreen
                ? SizedBox.shrink()
                : Expanded(
                    flex: 1,
                    child: AddLocation(
                      handleSubmit: handleSubmit,
                      nameController: nameController,
                      locationController: locationController,
                      managerController: managerController,
                      contactController: contactController,
                      openingController: openingController,
                      closingController: closingController,
                      formKey: _formKey,
                    ),
                  ),
            SizedBox(width: smallScreen ? 0 : 20),
            Expanded(
              flex: 2,
              child: ViewLocations(
                deleteLocation: deleteLocation,
                filteredLocations: filteredLocations,
                searchController: searchController,
                isLoading: isLoading,
                rowsPerPage: rowsPerPage,
                sortBy: sortBy,
                ascending: ascending,
                filterLocations: filterLocations,
                getFilteredAndSortedRows: getFilteredAndSortedRows,
                getColumnIndex: getColumnIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
