import 'package:auto_route/auto_route.dart';
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

  void handleSubmitData() async {
    showToast('loading...', ToastificationType.info);
    try {
      await apiService.post('servingsize', {
        'title': title.text,
        'shortHand': shortHand.text,
      });
      showToast('New Serving Added', ToastificationType.success);
      title.clear();
      shortHand.clear();

      getServingsizes();
    } catch (e) {
      showToast('Error $e', ToastificationType.error);
    }
  }

  void getServingsizes() async {
    try {
      var allServings = await apiService.get('servingsize');
      setState(() {
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
      body: Row(
        children: [
          if (!smallScreen)
            Expanded(
              flex: 1,
              child: CreateServingsize(
                formKey: formKey,
                title: title,
                shortHand: shortHand,
                handleSubmitData: handleSubmitData,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
