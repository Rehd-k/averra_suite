import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../helpers/snackbar.handler.dart';
import '../../../service/api.service.dart';
import 'add_category.dart';
import 'view_category.dart';

@RoutePage()
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryIndexState createState() => CategoryIndexState();
}

class CategoryIndexState extends State<CategoryScreen> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  List filteredCategories = [];
  late List categories = [];
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "title";
  bool ascending = true;

  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit(BuildContext context) async {
    if (!mounted) return;
    showBeautifulSnackBar(
      context,
      'Adding ${nameController.text} to categories',
      onAction: () {},
    );
    var res = await apiService.post('category', {
      'title': nameController.text,
      'description': descriptionController.text,
    });
    setState(() {
      categories.add(res.data);
      filteredCategories = List.from(categories);
    });

    if (!mounted) return;
    showBeautifulSnackBar(
      // ignore: use_build_context_synchronously
      context,
      'Added ${nameController.text} to categories',
      onAction: () {},
      type: SnackBarType.success,
    );
  }

  // Search logic
  void filterProducts(String query) {
    setState(() {
      filteredCategories = categories.where((category) {
        return category.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future getProductsList() async {
    var dbcategories = await apiService.get('category');
    setState(() {
      categories = dbcategories.data;
      filteredCategories = List.from(categories);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = categories.where((product) {
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
      case 'title':
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

  void onRowsPerPageChangedParent(int newValue) {
    setState(() {
      rowsPerPage = newValue;
    });
  }

  void onSortChangedParent(String column, bool asc) {
    setState(() {
      sortBy = column;
      ascending = asc;
    });
  }

  // The updateCategory handler expected by AddCategory (adjust signature as needed)
  void updateCategoryParent(Map<String, dynamic> newCategory) {
    // update parent's category list and call setState
  }

  @override
  void initState() {
    super.initState();
    getProductsList();
    filteredCategories = List.from(categories);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          smallScreen
              ? SizedBox.shrink()
              : Expanded(
                  flex: 1,
                  child: AddCategory(
                    formKey: _formKey,
                    nameController: nameController,
                    descriptionController: descriptionController,
                    onSubmit: (BuildContext context) {
                      handleSubmit(context);
                    },
                  ),
                ),
          SizedBox(width: smallScreen ? 0 : 20),
          Expanded(
            flex: 2,
            child: ViewCategory(
              rowsPerPage: rowsPerPage,
              onRowsPerPageChanged: (int p1) {
                onRowsPerPageChangedParent(p1);
              },
              sortBy: sortBy,
              ascending: ascending,
              getColumnIndex: (String p1) => getColumnIndex(p1),
              onSortChanged: (String p1, bool p2) {
                onSortChangedParent(p1, p2);
              },
              filterProducts: (String p1) {
                filterProducts(p1);
              },
              getFilteredAndSortedRows: () => getFilteredAndSortedRows(),
              searchController: SearchController(),
              updateCategory: (Map<String, dynamic> p1) {
                updateCategoryParent(p1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
