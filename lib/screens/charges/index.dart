import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../service/api.service.dart';
import 'addcharge.dart';
import 'viewcharges.dart';

@RoutePage()
class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key});

  @override
  ChargesScreenState createState() => ChargesScreenState();
}

class ChargesScreenState extends State<ChargesScreen> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  final amountController = TextEditingController();

  Future<void> handleSubmit() async {
    try {
      final dynamic response = await apiService.post('/charges', {
        'title': titleController.text,
        'description': descriptionController.text,
        'amount': amountController.text,
      });

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        getChargesList();
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  List filteredCharges = [];
  late List charges = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "title";
  bool ascending = true;

  void filterCharges(String query) {
    setState(() {
      searchQuery = query;
      filteredCharges = charges.where((charge) {
        return charge.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future getChargesList() async {
    // doShowToast('Updating charges...', ToastificationType.info);
    setState(() {
      isLoading = true;
    });
    var dbcharges = await apiService.get('charges');

    setState(() {
      charges = dbcharges.data;
      filteredCharges = List.from(charges);
      isLoading = false;
    });
  }

  Future deleteCharge(String id) async {
    await apiService.delete('charges/$id');
    setState(() {
      charges.removeWhere((bank) => bank['_id'] == id);
      filteredCharges = List.from(charges);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = charges.where((product) {
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
    super.initState();
    getChargesList();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Addcharge(
              formKey: _formKey,
              titleController: titleController,
              descriptionController: descriptionController,
              amountController: amountController,
              handleSubmit: handleSubmit,
            ),
          );
        },
        child: Icon(Icons.add_outlined),
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
                    child: Addcharge(
                      formKey: _formKey,
                      titleController: titleController,
                      descriptionController: descriptionController,
                      amountController: amountController,
                      handleSubmit: handleSubmit,
                    ),
                  ),
            SizedBox(width: smallScreen ? 0 : 20),
            Expanded(
              flex: 2,
              child: Viewcharges(
                filteredCharges: filteredCharges,
                searchController: searchController,
                isLoading: isLoading,
                sortBy: sortBy,
                ascending: ascending,
                filterCharges: filterCharges,
                getFilteredAndSortedRows: getFilteredAndSortedRows,
                deleteCharge: deleteCharge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
