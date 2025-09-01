import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../helpers/financial_string_formart.dart';
import '../../service/api.service.dart';
import 'cart_section.dart';
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
  String storeId = '';
  List stores = [];

  late final _pagingController = PagingController<int, dynamic>(
    getNextPageKey: (state) => ProductService().checkAndFetchProducts(
      apiCount,
      doApiCount,
      localproducts.length,
    ),
    fetchPage: (pageKey) => ProductService().fetchProducts(
      storeId: storeId,
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

  voidDoApiCheck(productsCount, totalProductsAmount) {
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
          (item) => item['_id'] == product.id,
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
            '_id': product.id,
            'title': product.title,
            'price': product.price,
            'quantity': 1,
            'total': product.price,
            'cost': product.cost,
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
      cart.removeWhere((item) => item['_id'] == productId);
    });
  }

  void decrementCartQuantity(String productId) {
    setState(() {
      int cartIndex = cart.indexWhere((item) => item['_id'] == productId);
      if (cartIndex != -1) {
        if (cart[cartIndex]['quantity'] > 1) {
          cart[cartIndex]['quantity']--;
          cart[cartIndex]['total'] =
              cart[cartIndex]['quantity'] * cart[cartIndex]['price'];

          //  handle increase Product Qunaity
        } else {
          removeFromCart(productId);
        }
      }
    });
  }

  void incrementCartQuantity(String productId) {
    setState(() {
      int cartIndex = cart.indexWhere((item) => item['_id'] == productId);
      if (cartIndex != -1) {
        if (cart[cartIndex]['quantity'] < cart[cartIndex]['maxQuantity']) {
          cart[cartIndex]['quantity']++;
          cart[cartIndex]['total'] =
              cart[cartIndex]['quantity'] * cart[cartIndex]['price'];

          // hadnel Decreace Product Quanity
        }
      }
    });
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    setState(() {
      int index = cart.indexWhere((item) => item['_id'] == productId);
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var savedCart = prefs.getString('cart') ?? '[]';
      List cartArray = jsonDecode(savedCart);
      setState(() {
        cartArray.add(cart);
        savedCarts = cartArray;
        cart = [];
      });
      String cartJson = jsonEncode(cartArray);
      await prefs.setString('cart', cartJson);
    }
  }

  void loadCartFromStorage(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storageCart = savedCarts.elementAt(index);
    setState(() {
      cart = List<Map<String, dynamic>>.from(storageCart);
      savedCarts.removeAt(index);
      prefs.setString('cart', json.encode(savedCarts));
    });
  }

  void getCartsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var carts = prefs.getString('cart');

    if (carts != null) {
      var cartsArray = jsonDecode(carts);
      setState(() {
        savedCarts = List.from(cartsArray);
      });
    } else {
      savedCarts = [];
    }
  }

  void removeCartFromStorage(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCarts.removeAt(index);
      prefs.setString('cart', json.encode(savedCarts));
    });
  }

  void emptycart() {
    setState(() {
      cart = [];
    });
  }

  void handleSubmited() async {
    emptycart();
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
    getStores();
  }

  void getStores() async {
    var result = await apiService.get('store?type=dispensary');
    setState(() {
      stores = result.data;
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
                      value: storeId,
                      decoration: InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          storeId = newValue!;
                        });
                        _onSearchChanged();
                      },
                      items:
                          [
                            {'title': '', '_id': ''},
                            ...stores,
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
            ...savedCarts.asMap().entries.map((res) {
              int index = res.key; // Get the index
              // String value = res.value;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: savedCartsIcon(index),
              );
            }),
          ],
        ),

        floatingActionButton: smallScreen
            ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height * 0.98,
                      child: CartSection(
                        isSmallScreen: smallScreen,
                        saveCart: saveCartToStorage,
                        emptyCart: emptycart,
                        cart: cart,
                        cartTotal: getCartTotal(),
                        decrementCartQuantity: decrementCartQuantity,
                        incrementCartQuantity: incrementCartQuantity,
                        removeFromCart: removeFromCart,
                        handleComplete: handleSubmited,
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
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : null,
        body: Padding(
          padding: EdgeInsets.only(top: 8.0, right: smallScreen ? 0 : 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
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
                              style: Theme.of(context).textTheme.titleMedium,
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
                    storeId == '' && isLoading
                        ? Center(child: Text('Select Dispensary to Sell From'))
                        : ProductGrid(
                            pagingController: _pagingController,
                            smallScreen: smallScreen,
                            addToCart: addToCart,
                          ),
                  ],
                ),
              ),

              // Grid view
              SizedBox(width: 10),
              smallScreen
                  ? SizedBox.shrink()
                  : CartSection(
                      isSmallScreen: smallScreen,
                      cart: cart,
                      cartTotal: getCartTotal(),
                      decrementCartQuantity: decrementCartQuantity,
                      incrementCartQuantity: incrementCartQuantity,
                      removeFromCart: removeFromCart,
                      saveCart: saveCartToStorage,
                      emptyCart: emptycart,
                      handleComplete: handleSubmited,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  InkWell savedCartsIcon(int index) {
    return InkWell(
      onTap: () {
        loadCartFromStorage(index);
      },
      child: Stack(
        clipBehavior: Clip.none, // Ensures the close icon is not clipped
        alignment: Alignment.topRight,
        children: [
          CircleAvatar(
            radius: 16, // Increased size for visibility

            child: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 16, // Adjust icon size
            ),
          ),
          Positioned(
            right: -4, // Adjust position
            top: -4, // Adjust position
            child: InkWell(
              onTap: () {
                removeCartFromStorage(index);
              },
              child: CircleAvatar(
                radius: 8, // Small red circle
                backgroundColor: Colors.red, // Red background
                child: Icon(
                  Icons.close,
                  size: 10, // Adjust size of X icon
                  color: Colors.white, // White color for X icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
