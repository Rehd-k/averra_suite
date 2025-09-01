import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import '../../app_router.gr.dart';
import '../../components/tables/gen_big_table/big_table_source.dart';
import '../../service/api.service.dart';
import '../../service/products.excel.dart';
import '../../service/token.service.dart';
import 'add_products.dart';
import 'table_column.dart';
import 'view_products.dart';

@RoutePage()
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  ProductsIndexState createState() => ProductsIndexState();
}

class ProductsIndexState extends State<ProductsScreen> {
  final apiService = ApiService();
  final StringBuffer buffer = StringBuffer();
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _scannerFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();

  final categoryController = TextEditingController();
  final List<ColumnDefinition> _columnDefinitions = columnDefinitionMaps
      .map((map) => ColumnDefinition.fromMap(map))
      .toList();
  final JsonEncoder jsonEncoder = JsonEncoder();
  bool isLoading = true;
  List categories = [];
  String selectedCategory = "";
  String searchFeild = 'title';
  String initialSort = 'title';
  List<TableDataModel> selectedRows = [];
  String _searchQuery = '';
  String? barcodeHolder;
  bool _scannerActive = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    getCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerFocusNode.requestFocus();
    });
    super.initState();
  }

  void _submitSearch() {
    // Trigger rebuild only if the query actually changed
    if (_searchQuery != _searchController.text.trim()) {
      setState(() {
        _searchQuery = _searchController.text.trim();
        // The setState call will trigger didUpdateWidget in the child table
      });
    }
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_searchQuery != _searchController.text) {
          setState(() {
            _searchQuery = _searchController.text;
          });
        }
      });
    }
  }

  setSelectedField(String field) {
    setState(() {
      searchFeild = field;
    });
  }

  setSelectedCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  handleSelectedRows(List<TableDataModel> selected) {
    setState(() {
      selectedRows = selected;
    });
  }

  handleShowModal(barcode) {
    showModalBottomSheet(
      enableDrag: true,
      // Close the modal when tapping outside or inside AddProducts
      isDismissible: true,
      // Pass a callback to AddProducts to close the modal on click
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 1,
        padding: const EdgeInsets.all(8.0),
        child: AddProducts(
          barcode: barcode,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
      isScrollControlled: true,
      context: context,
    );
  }

  void getCategories() async {
    var dbCategories = await apiService.get('category');
    setState(() {
      categories = dbCategories.data;
      isLoading = false;
    });
  }

  checkProductExistence(barcode) async {
    var dbproducts = await apiService.get(
      'products?filter={"barcode" : {"\$regex" : "$barcode"}}',
    );

    var {'products': products, 'totalDocuments': _} = dbproducts.data;

    if (products.length < 1) {
      if (JwtService().decodedToken?['role'] != 'admin') {
        doShowToast('Product Dossnt Exist', ToastificationType.info);
      } else {
        barcodeHolder = barcode;
        handleShowModal(barcode);
      }
    } else {
      setState(() {
        searchFeild = 'barcode';
        _searchQuery = barcode;
      });
    }
  }

  @override
  void dispose() {
    categoryController.dispose();
    _scannerFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _toggleFocus() {
    setState(() {
      _scannerActive = !_scannerActive;
      if (_scannerActive) {
        _scannerFocusNode.requestFocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, actions: []),
      body: KeyboardListener(
        focusNode: _scannerFocusNode,
        onKeyEvent: (event) async {
          if (!_scannerActive) return;
          if (event is KeyDownEvent) {
            // Collect barcode characters
            buffer.write(event.character ?? '');
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              final scannedData = buffer.toString().trim();
              buffer.clear();
              await checkProductExistence(scannedData);
            }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            header(context, smallScreen),
            Expanded(
              flex: 1,
              child: ViewProducts(
                searchFeild: searchFeild,
                searchQuery: _searchQuery,
                categoryController: categoryController,
                isLoading: isLoading,
                apiService: apiService,
                categories: categories,
                setSelectField: setSelectedField,
                submitSearch: _submitSearch,
                onSearchChanged: _onSearchChanged,
                setSelectedCategory: setSelectedCategory,
                columnDefinitions: _columnDefinitions,
                selectedCategory: selectedCategory,
                initialSort: initialSort,
                selectedRows: selectedRows,
                handleSelectedRows: handleSelectedRows,
                jsonEncoder: jsonEncoder,
                searchController: _searchController,
                rowsPerPage: rowsPerPage,
                actions: [
                  DropdownButton(
                    elevation: 0,
                    hint: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    icon: Icon(Icons.filter_alt_outlined, size: 10),
                    // value: 'all',
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                        value: 'low stock',
                        child: Text('Low Stock'),
                      ),
                      DropdownMenuItem(
                        value: 'no   stock',
                        child: Text('No Stock'),
                      ),
                    ],
                    onChanged: (v) {},
                  ),
                  SizedBox(width: 4),
                  if (!smallScreen)
                    if (JwtService().decodedToken!['role'] != 'cashier')
                      IconButton(
                        onPressed: () {
                          handleShowModal(barcodeHolder);
                        },
                        tooltip: 'Add New Product',
                        icon: Icon(Icons.add_box_outlined),
                      ),

                  if (!smallScreen)
                    IconButton(
                      onPressed: () {
                        createExcelFile();
                      },
                      tooltip: 'Extract to Excel',
                      icon: Icon(Icons.dataset_outlined),
                    ),

                  if (!smallScreen)
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Print Result',
                      icon: Icon(Icons.print_outlined),
                    ),

                  if (!smallScreen)
                    IconButton(
                      onPressed: () {
                        context.router.push(SendProducts());
                      },
                      tooltip: 'Send Products',
                      icon: Icon(Icons.send_outlined),
                    ),

                  if (smallScreen)
                    PopupMenuButton<int>(
                      padding: const EdgeInsets.all(1),
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Add Product",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => {handleShowModal(barcodeHolder)},
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_note_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Extract To Excel",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => {createExcelFile()},
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Print Table",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {},
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.show_chart_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Send Product",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => context.router.push(SendProducts()),
                          ),
                        ];
                      },
                      elevation: 2,
                    ),
                ],

                tableHeader: IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  tooltip: 'Refresh Table',
                  icon: Icon(Icons.refresh_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding header(BuildContext context, bool smallScreen) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: DropdownMenu<String>(
                  width: double.infinity,
                  initialSelection: searchFeild,
                  onSelected: (value) {
                    setState(() {
                      searchFeild = value ?? "";
                    });
                  },
                  dropdownMenuEntries: dropDownMaps
                      .map(
                        (field) => DropdownMenuEntry<String>(
                          value: field['field'],
                          label: field['name'],
                        ),
                      )
                      .toList(),
                  hintText: 'Search Field',
                ),
              ),

              SizedBox(width: smallScreen ? 5 : 10),
              Expanded(
                flex: 4,
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitSearch(),
                  onChanged: (_) => _onSearchChanged(),
                  onEditingComplete: () {
                    // Optional: return to scanner after search
                    if (_scannerActive) {
                      _scannerFocusNode.requestFocus();
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownMenu<String>(
                  width: double.infinity,
                  initialSelection: selectedCategory.isEmpty
                      ? null
                      : selectedCategory,
                  onSelected: (value) {
                    setState(() {
                      selectedCategory = value ?? "";
                    });
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry<String>(value: '', label: ''),
                    ...categories.map(
                      (category) => DropdownMenuEntry<String>(
                        value: category['title'],
                        label: category['title'],
                      ),
                    ),
                  ],
                  hintText: 'Select Category',
                ),
              ),
              SizedBox(width: smallScreen ? 5 : 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(
                    _scannerActive ? Icons.search : Icons.barcode_reader,
                  ),
                  label: Text(
                    _scannerActive ? "Switch to Search" : "Switch to Scanner",
                  ),
                  onPressed: _toggleFocus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
