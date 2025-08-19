import 'dart:async';

import '../../service/api.service.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final bool isAvailable;
  final double cost;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.isAvailable,
    required this.cost,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      isAvailable: json['isAvailable'],
      cost: json['cost'] ?? 0,
    );
  }
}

class ProductService {
  static const int pageSize = 10;
  ApiService apiService = ApiService();

  FutureOr<List<dynamic>> fetchProducts({
    required int pageKey,
    required searchFeild,
    required Function addToCart,
    String? query,
    required Function doProductUpdate,
  }) async {
    int skip = pageKey * pageSize;

    String barcodeThing =
        'products?filter={"isAvailable" : true, "barcode":  "$query"}&sort={"title": 1}&limit=$pageSize&skip=$skip&select=" title price quantity isAvailable "';

    String queryThing =
        'products?filter={"isAvailable" : true, "title": {"\$regex": "$query"}}&sort={"title": 1}&limit=$pageSize&skip=$skip&select=" title price quantity isAvailable "';

    final response = await apiService.get(
      searchFeild == 'title' ? queryThing : barcodeThing,
    );
    final {"products": products, "totalDocuments": totalDocuments} =
        response.data;

    if (response.statusCode == 200) {
      var prod = products.map((json) => Product.fromJson(json)).toList();
      doProductUpdate(prod, totalDocuments);

      if (searchFeild == 'barcode' && prod.isNotEmpty) {
        addToCart(prod[0]);
      }
      return prod;
    } else {
      throw Exception('Failed to load products');
    }
  }

  checkAndFetchProducts(pageKey, doApiCount, productsLength) {
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
