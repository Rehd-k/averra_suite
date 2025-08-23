import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';

class RequestModel {
  final DateTime date;
  final List<Product> products;
  final String from;
  final String to;
  final String initiator;
  final String completer;

  RequestModel({
    required this.date,
    required this.products,
    required this.from,
    required this.to,
    required this.initiator,
    required this.completer,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      date: DateTime.parse(json['date']),
      products: (json['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      from: json['from'],
      to: json['to'],
      initiator: json['initiator'],
      completer: json['completer'],
    );
  }
}

class Product {
  final String title;
  final int quantity;
  final double price;

  Product({required this.title, required this.quantity, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}

@RoutePage()
class StoreHistory extends StatefulWidget {
  const StoreHistory({super.key});

  @override
  StoreHistoryState createState() => StoreHistoryState();
}

class StoreHistoryState extends State<StoreHistory> {
  ApiService apiService = ApiService();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String select = '';
  String from = '';
  String to = '';
  final List<RequestModel> _requests = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  fetchRequests(int page) async {
    final response = await apiService.get(
      '/store-history?filter={"from" : {"\$regex" : "${from.toLowerCase()}"}, "to" : {"\$regex" : "${to.toLowerCase()}"}}&skip=$page&sort={"createdAt":-1}&startDate=$startDate&endDate=$endDate',
    );
    var {'history': history, 'totalDocuments': totalDocuments} = response.data;
    final data = history;
    return {
      'data': (data).map((json) => RequestModel.fromJson(json)).toList(),
      'totalDocuments': totalDocuments,
    };
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final newRequests = await fetchRequests(_currentPage);

      setState(() {
        _requests.addAll(newRequests['data']);
        _currentPage++;
        _isLoading = false;
        _hasMore =
            newRequests.length ==
            newRequests['totalDocuments']; // Stop if fewer than limit
      });
    } catch (e) {
      setState(() => _isLoading = false);

      showToast(
        'Error:',
        description: '$e',
        ToastificationType.error,
        duretion: 5,
      );
    }
  }

  @override
  void initState() {
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request History'), actions: []),
      body: _requests.isEmpty && !_isLoading
          ? const Center(child: Text('No requests found'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _requests.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _requests.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final request = _requests[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${request.date.toLocal()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('From: ${request.from}'),
                        Text('To: ${request.to}'),
                        Text('Initiator: ${request.initiator}'),
                        Text('Completer: ${request.completer}'),
                        const SizedBox(height: 8),
                        ExpansionTile(
                          title: const Text('Products'),
                          children: request.products
                              .map(
                                (product) => ListTile(
                                  title: Text(product.title),
                                  subtitle: Text(
                                    'Quantity: ${product.quantity} | Price: \$${product.price.toStringAsFixed(2)}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
