import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/token.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../helpers/financial_string_formart.dart';
import '../../service/api.service.dart';
import 'cart_section.dart';
import 'orders.section.dart';
import 'product_grid.dart';
import 'product_service.dart';

@RoutePage()
class MakeSaleScreen extends StatefulWidget {
  final Function()? onResult;
  const MakeSaleScreen({super.key, this.onResult});

  @override
  MakeSaleIndexState createState() => MakeSaleIndexState();
}

class MakeSaleIndexState extends State<MakeSaleScreen> {
  ApiService apiService = ApiService();
  Timer? _debounce;
  final FocusNode _scannerFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  final StringBuffer buffer = StringBuffer();
  String _searchQuery = '';
  bool isLoading = true;
  int numberOfProducts = 0;
  int apiCount = 0;
  List savedCarts = [];
  String searchFeild = 'title';
  List<dynamic> localproducts = [];
  bool _scannerActive = false;
  String departmentId = '';
  List departments = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String cartId = '';

  late final _pagingController = PagingController<int, dynamic>(
    getNextPageKey: (state) => ProductService().checkAndFetchProducts(
      apiCount,
      doApiCount,
      localproducts.length,
    ),
    fetchPage: (pageKey) => ProductService().fetchProducts(
      departmentId: departmentId,
      pageKey: pageKey,
      query: _searchQuery,
      doProductUpdate: voidDoApiCheck,
      searchFeild: searchFeild,
      addToCart: addToCart,
    ),
  );

  void doApiCount() {
    apiCount++;
  }

  Future<void> updateAllSettled() async {
    if (cartId != '') {
      await apiService.patch('cart/confirm/$cartId', {'status': 'settled'});
      getCartsFromStorage();
    }
    setState(() {
      cart = [];
      cartId = '';
    });
  }

  Future<void> updateSingleSettled() async {
    await apiService.patch('cart/update/$cartId', {
      "_id": cartId,
      "cart": cart,
      "total": getCartTotal(),
    });
    setState(() {
      cart = [];
    });
  }

  void voidDoApiCheck(List<dynamic> productsCount, totalProductsAmount) {
    localproducts = productsCount;
    setState(() {
      numberOfProducts = totalProductsAmount;
    });
  }

  List<Map<String, dynamic>> cart = [];

  // Handle Product qunaity

  void _toggleFocus() {
    setState(() {
      _scannerActive = !_scannerActive;
      if (_scannerActive) {
        searchFeild = 'barcode';
        _scannerFocusNode.requestFocus();
      } else {
        searchFeild = 'title';
        _searchFocusNode.requestFocus();
      }
    });
  }

  void addToCart(Product product) {
    if (product.quantity > 0) {
      setState(() {
        int existingIndex = cart.indexWhere(
          (item) => item['productId'] == product.id,
        );
        if (existingIndex != -1) {
          if (cart[existingIndex]['quantity'] <
              cart[existingIndex]['maxQuantity']) {
            cart[existingIndex]['quantity']++;
            cart[existingIndex]['total'] =
                cart[existingIndex]['quantity'] * cart[existingIndex]['price'];
            // updateFilteredProductsCount(product.id, product);
          }
        } else {
          // Add new product to cart

          cart.add({
            'productId': product.id,
            'title': product.title,
            'price': product.price,
            'quantity': 1,
            'total': product.price,
            'cost': product.cost,
            'from': departmentId,
            'maxQuantity': product.quantity,
          });
          // updateFilteredProductsCount(product.id, product);
        }
      });
    }
  }

  void removeFromCart(String productId) {
    setState(() {
      //  Handle Add Product Qunaity
      cart.removeWhere((item) => item['productId'] == productId);
    });
  }

  void decrementCartQuantity(String productId) {
    setState(() {
      int cartIndex = cart.indexWhere((item) => item['productId'] == productId);
      if (cartIndex != -1) {
        if (cart[cartIndex]['quantity'] > 1) {
          cart[cartIndex]['quantity']--;
          cart[cartIndex]['total'] =
              cart[cartIndex]['quantity'] * cart[cartIndex]['price'];
          cart[cartIndex]['settled'] = false;
          //  handle increase Product Qunaity
        } else {
          removeFromCart(productId);
        }
      }
    });
  }

  void incrementCartQuantity(String productId) {
    setState(() {
      int cartIndex = cart.indexWhere((item) => item['productId'] == productId);
      if (cartIndex != -1) {
        if (cart[cartIndex]['quantity'] < cart[cartIndex]['maxQuantity']) {
          cart[cartIndex]['quantity']++;
          cart[cartIndex]['total'] =
              cart[cartIndex]['quantity'] * cart[cartIndex]['price'];
          cart[cartIndex]['settled'] = false;
        }
      }
    });
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    setState(() {
      int index = cart.indexWhere((item) => item['productId'] == productId);
      if (index != -1) {
        // Ensure quantity doesn't exceed available stock
        newQuantity = min(newQuantity, cart[index]['maxQuantity']);
        // Ensure quantity is at least 1
        newQuantity = max(1, newQuantity);

        cart[index]['quantity'] = newQuantity;
        cart[index]['total'] = cart[index]['quantity'] * cart[index]['price'];
      }
    });
  }

  double getCartTotal() {
    return cart.fold(0, (sum, item) => sum + item['total']);
  }

  void saveCartToStorage() async {
    if (cart.isNotEmpty) {
      var res = await apiService.post('cart', {
        "cart": cart,
        "total": getCartTotal(),
      });
      setState(() {
        savedCarts.add(res.data);
        cart = [];
      });
    }
  }

  void loadCartFromStorage(String id) async {
    var res = await apiService.get('cart/$id');

    // Normalize response to a Map (handle case where API returns a list)
    var data = res.data;
    if (data is List && data.isNotEmpty) {
      data = data.first;
    }

    // If products are nested inside "from", flatten them into a single "products" list
    if (data is Map && data.containsKey('from')) {
      final List<Map<String, dynamic>> flattened = [];

      for (final group in (data['from'] as List<dynamic>)) {
        if (group is Map && group.containsKey('products')) {
          for (final p in (group['products'] as List<dynamic>)) {
            if (p is Map) {
              final int quantity = (p['quantity'] is int)
                  ? p['quantity']
                  : (int.tryParse('${p['quantity']}') ?? 1);
              final num price = p['price'] ?? 0;
              flattened.add({
                'productId': p['productId'] ?? p['_id'] ?? '',
                'title': p['title'] ?? '',
                'price': price,
                'quantity': quantity,
                'total': p['total'] ?? (price * quantity),
                'cost': p['cost'] ?? 0,
                'from': p['from'] ?? group['department'] ?? '',
                'maxQuantity': p['maxQuantity'] ?? 1000,
                // Preserve any other fields if needed
                ...p,
              });
            }
          }
        }
      }

      // Ensure the response has a "products" key that the rest of the code expects
      data['products'] = flattened;
      // Put normalized data back on res.data if it's mutable
      if (res is Map) {
        // no-op
      } else {
        res.data = data;
      }
    }
    setState(() {
      cartId = id;
      cart = List<Map<String, dynamic>>.from(res.data['products']);
    });
  }

  void getCartsFromStorage() async {
    var res = await apiService.get(
      'cart?filter={"initiator" : "${JwtService().decodedToken?['username']}", "status" : "pending"}&startDate=$startDate&endDate=$endDate',
    );
    savedCarts = res.data;
  }

  void removeCartFromStorage(String id) async {
    await apiService.delete('cart/$id');
    setState(() {
      savedCarts.removeWhere((res) => res['_id'] == id);
    });
  }

  Future<void> emptycart() async {
    setState(() {
      cart = [];
      cartId = '';
    });
  }

  void handleSubmited() async {
    await updateAllSettled();
    // await getProductsList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scannerFocusNode.dispose();
    _searchFocusNode.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerFocusNode.requestFocus();
    });
    getCartsFromStorage();
    getdepartments();
  }

  void getdepartments() async {
    var result = await apiService.get('department?type=dispensary');
    setState(() {
      departments = result.data;
      isLoading = false;
    });
  }

  void _onSearchChanged() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      localproducts = [];
      apiCount = 0;
      _searchQuery = searchController.text;
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    final key = GlobalKey<ExpandableFabState>();
    return KeyboardListener(
      focusNode: _scannerFocusNode,
      onKeyEvent: (event) async {
        if (!_scannerActive) return;

        if (event is KeyDownEvent) {
          // Collect barcode characters

          buffer.write(event.character ?? '');
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            searchController.text = buffer.toString().trim();
            _onSearchChanged();
            buffer.clear();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            SizedBox(
              width: 200,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      initialValue: departmentId,
                      decoration: InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          departmentId = newValue!;
                        });
                        if (newValue != '') {
                          _onSearchChanged();
                        }
                      },
                      items:
                          [
                            {'title': '', '_id': ''},
                            ...departments,
                          ].map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value['_id'],
                              child: Text(
                                capitalizeFirstLetter(value['title']),
                              ),
                            );
                          }).toList(),
                      validator: (value) =>
                          value == '' ? 'Please select an option' : null,
                    ),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              icon: Icon(_scannerActive ? Icons.search : Icons.barcode_reader),
              label: Text(
                _scannerActive ? "Switch to Search" : "Switch to Scanner",
              ),
              onPressed: _toggleFocus,
            ),

            TextButton(
              child: Text('Orders : ${savedCarts.length.toString()}'),
              onPressed: () {
                {
                  final state = key.currentState;
                  if (state != null) {
                    state.toggle();
                  }
                }
              },
            ),
          ],
        ),
        floatingActionButtonLocation: ExpandableFab.location,

        floatingActionButton: ExpandableFab(
          distance: 50,
          key: key,
          type: ExpandableFabType.up,
          children: [
            FloatingActionButton.small(
              heroTag: null,
              child: const Icon(Icons.list_alt_outlined),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setModalState) => OrdersSection(
                      ordersSections: savedCarts,
                      loadCartFromStorage: (id) {
                        loadCartFromStorage(id);
                        setModalState(() {});
                      },
                      removeCartFromStorage: (id) {
                        removeCartFromStorage(id);
                        setModalState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
            if (smallScreen)
              FloatingActionButton.small(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setModalState) => Container(
                        padding: const EdgeInsets.all(8.0),
                        height: MediaQuery.of(context).size.height * 0.98,
                        child: CartSection(
                          isSmallScreen: smallScreen,
                          saveCart: () {
                            saveCartToStorage();
                            setModalState(() {});
                          },
                          emptyCart: () {
                            emptycart();
                            setModalState(() {});
                          },
                          cart: cart,
                          cartTotal: getCartTotal(),
                          decrementCartQuantity: (product) {
                            decrementCartQuantity(product);
                            setModalState(() {});
                          },
                          incrementCartQuantity: (product) {
                            incrementCartQuantity(product);
                            setModalState(() {});
                          },
                          removeFromCart: (product) {
                            removeFromCart(product);
                            setModalState(() {});
                          },
                          handleComplete: handleSubmited,
                          cartId: cartId,
                          updateSingleSettled: updateSingleSettled,
                        ),
                      ),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 40),
                    if (cart.isNotEmpty)
                      Positioned(
                        child: Container(
                          alignment: Alignment.center,
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.only(top: 8.0, right: smallScreen ? 0 : 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              departmentId != ''
                  ? Expanded(
                      flex: smallScreen ? 1 : 3,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$numberOfProducts Products',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    autofocus: true,
                                    controller: searchController,
                                    onChanged: (value) {
                                      _onSearchChanged();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      prefixIcon: Icon(Icons.search),
                                      suffixIcon: InkWell(
                                        child: Icon(Icons.close),
                                        onTap: () {
                                          _onSearchChanged();
                                          searchController.text = '';
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ProductGrid(
                            pagingController: _pagingController,
                            smallScreen: smallScreen,
                            addToCart: addToCart,
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      flex: smallScreen ? 1 : 3,
                      child: Center(
                        child: Text('Select Dispensary to Sell From'),
                      ),
                    ),
              // Grid view
              SizedBox(width: 10),
              smallScreen
                  ? SizedBox.shrink()
                  : CartSection(
                      cartId: cartId,
                      isSmallScreen: smallScreen,
                      cart: cart,
                      cartTotal: getCartTotal(),
                      decrementCartQuantity: decrementCartQuantity,
                      incrementCartQuantity: incrementCartQuantity,
                      removeFromCart: removeFromCart,
                      saveCart: saveCartToStorage,
                      emptyCart: emptycart,
                      handleComplete: handleSubmited,
                      updateSingleSettled: updateSingleSettled,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
