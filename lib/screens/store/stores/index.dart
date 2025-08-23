import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/tables/gen_big_table/big_table_source.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../service/api.service.dart';
import 'create.store.dart';
import 'view.stores.dart';

@RoutePage()
class StoreIndex extends StatefulWidget {
  const StoreIndex({super.key});

  @override
  StoreIndexState createState() => StoreIndexState();
}

class StoreIndexState extends State<StoreIndex> {
  final formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List filteredstores = [];
  late List stores = [];
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
      await apiService.post('store', {
        'title': title.text,
        'description': description.text,
        'type': type,
        'access': access,
      });
      doShowToast('New Store Added', ToastificationType.success);
      title.clear();
      description.clear();
      setState(() {
        type = 'Store';
        active = true;
      });
      getStores();
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

  void getStores() async {
    try {
      var allStore = await Future.wait([
        apiService.get('store'),
        apiService.get('settings'),
      ]);
      setState(() {
        stores = allStore[0].data;
        settings = allStore[1].data[0];
        filteredstores = List.from(stores);
        isLoading = false;
      });
    } catch (e) {
      doShowToast('Error $e', ToastificationType.error);
    }
  }

  void filterStores(String query) {
    setState(() {
      searchQuery = query;
      filteredstores = stores.where((store) {
        return store.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future deletestore(String id) async {
    await apiService.delete('store/$id');
    setState(() {
      stores.removeWhere((store) => store['_id'] == id);
      filteredstores = List.from(stores);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = stores.where((product) {
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
    getStores();
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
              child: CreateStore(
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
            child: ViewStores(
              searchController: searchController,
              isLoading: isLoading,
              sortBy: sortBy,
              ascending: ascending,
              getFilteredAndSortedRows: getFilteredAndSortedRows,
              deleteStore: deletestore,
              filteredStores: filteredstores,
              filterStore: filterStores,
            ),
          ),
        ],
      ),
    );
  }
}
