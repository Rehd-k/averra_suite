import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/snackbar.handler.dart';
import 'package:averra_suite/screens/searving/create.servingsize.dart';
import 'package:averra_suite/screens/searving/view.servingsize.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';

@RoutePage()
class IndexServingsizeScreen extends StatefulWidget {
  const IndexServingsizeScreen({super.key});

  @override
  IndexServingsizeState createState() => IndexServingsizeState();
}

class IndexServingsizeState extends State<IndexServingsizeScreen> {
  final formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  final TextEditingController title = TextEditingController();
  final TextEditingController shortHand = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List filteredsizes = [];
  late List sizes = [];
  late Map settings = {};
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "title";
  bool ascending = true;
  bool active = true;
  String id = '';

  void handleSubmitData() async {
    showBeautifulSnackBar(
      context,
      'Adding ${title.text} to Serving Sizes',
      onAction: () {},
    );
    try {
      await apiService.post('servingsize', {
        'title': title.text,
        'shortHand': shortHand.text,
      });
      title.clear();
      shortHand.clear();

      getServingsizes();
      if (!mounted) return;
      showBeautifulSnackBar(
        context,
        'Added ${title.text} to Serving Sizes',
        onAction: () {},
      );
    } catch (e) {
      showToast('Error $e', ToastificationType.error);
    }
  }

  void getServingsizes() async {
    try {
      var allServings = await apiService.get('servingsize');
      setState(() {
        id = '';
        title.clear();
        shortHand.clear();
        sizes = allServings.data;
        filteredsizes = List.from(sizes);
        isLoading = false;
      });
    } catch (e) {
      showToast('Error $e', ToastificationType.error);
    }
  }

  void filterServings(String query) {
    setState(() {
      searchQuery = query;
      filteredsizes = sizes.where((size) {
        return size.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future deleteservingsize(String id) async {
    await apiService.delete('servingsize/$id');
    setState(() {
      sizes.removeWhere((servingsize) => servingsize['_id'] == id);
      filteredsizes = List.from(sizes);
      isLoading = false;
    });
  }

  Future updateservingsize() async {
    showBeautifulSnackBar(
      context,
      'Updating ${title.text} at Serving Sizes',
      onAction: () {},
    );
    await apiService.patch('servingsize/$id', {
      'title': title.text,
      'shortHand': shortHand.text,
    });
    getServingsizes();
    if (!mounted) return;
    showBeautifulSnackBar(
      context,
      'Updated ${title.text} at Serving Sizes',
      onAction: () {},
      type: SnackBarType.success,
    );
  }

  List getFilteredAndSortedRows() {
    List filteredservingsize = sizes.where((product) {
      return product.values.any(
        (value) =>
            value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }).toList();

    filteredservingsize.sort((a, b) {
      if (ascending) {
        return a[sortBy].toString().compareTo(b[sortBy].toString());
      } else {
        return b[sortBy].toString().compareTo(a[sortBy].toString());
      }
    });

    return filteredservingsize;
  }

  void selectForUpdate(Map<String, dynamic> servingsize) {
    setState(() {
      title.text = servingsize['title'];
      shortHand.text = servingsize['shortHand'];
      id = servingsize['id'];
    });
  }

  @override
  void initState() {
    getServingsizes();
    super.initState();
  }

  @override
  void dispose() {
    title.dispose();
    shortHand.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    if (isLoading) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      floatingActionButton: smallScreen
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: CreateServingsize(
                      formKey: formKey,
                      title: title,
                      shortHand: shortHand,
                      handleSubmitData: handleSubmitData,
                      id: id,
                      updateservingsize: updateservingsize,
                    ),
                  ),
                );
              },
              label: Text('Add Serving Size'),
              icon: Icon(Icons.add),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (!smallScreen)
            Expanded(
              flex: 1,
              child: CreateServingsize(
                formKey: formKey,
                title: title,
                shortHand: shortHand,
                handleSubmitData: handleSubmitData,
                id: id,
                updateservingsize: updateservingsize,
              ),
            ),
          SizedBox(width: smallScreen ? 0 : 20),
          Expanded(
            flex: 2,
            child: Card(
              child: ViewServingsize(
                searchController: searchController,
                isLoading: isLoading,
                sortBy: sortBy,
                ascending: ascending,
                getFilteredAndSortedRows: getFilteredAndSortedRows,
                deleteServingsize: deleteservingsize,
                filterServingsize: filterServings,
                filteredServingsize: filteredsizes,
                selectForUpdate: selectForUpdate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
