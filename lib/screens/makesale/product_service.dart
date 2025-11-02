import 'dart:async';

import '../../service/api.service.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final double cost;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.cost,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product']['_id'],

      title: json['product']['title'],

      price: json['product']['sellUnits']
          ? (json['product']['price'] as num).toDouble()
          : (json['product']['servingPrice'] as num).toDouble(),

      quantity: json['product']['sellUnits']
          ? json['product']['quantity']
          : json['product']['quantity'] ~/ json['product']['servingSize'],

      cost: json['product']['cost'] ?? 0,
    );
  }
}

class ProductService {
  static const int pageSize = 10;
  ApiService apiService = ApiService();

  FutureOr<List<dynamic>> fetchProducts({
    required String departmentId,
    required int pageKey,
    required searchFeild,
    required Function addToCart,
    String? query,
    required Function doProductUpdate,
  }) async {
    int skip = pageKey * pageSize;

    String barcodeThing =
        'department/for-sell?filter={"isAvailable" : true, "barcode":  "$query"}&sort={"title": 1}&limit=$pageSize&skip=$skip&select=" title price quantity isAvailable type servingQuantity "';

    String queryThing =
        'department/for-sell/$departmentId?searchQuery=$query&limit=$pageSize&skip=$skip';

    final response = await apiService.get(
      searchFeild == 'title' ? queryThing : barcodeThing,
    );

    var result = response.data;

    if (response.statusCode == 200) {
      var prod = result['finishedGoods']
          .map((json) => Product.fromJson(json))
          .toList();
      doProductUpdate(prod, result['total']);

      if (searchFeild == 'barcode' && prod.isNotEmpty) {
        addToCart(prod[0]);
      }
      return prod;
    } else {
      throw Exception('Failed to load products');
    }
  }

  dynamic checkAndFetchProducts(dynamic pageKey, doApiCount, productsLength) {
    if (pageKey < 1) {
      doApiCount();
      return pageKey;
    } else {
      if (productsLength < 10) {
        return null;
      } else {
        doApiCount();
        return pageKey;
      }
    }
  }
}
