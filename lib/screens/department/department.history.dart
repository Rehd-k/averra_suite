import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import '../../service/date_range_helper.dart';
import 'department.request.dart';

class RequestModel {
  final String id;
  final DateTime date;
  final List<Product> products;
  final String from;
  final String fromId;
  final String toId;
  final String to;
  final String initiator;
  final String completer;

  RequestModel({
    required this.fromId,
    required this.toId,
    required this.id,
    required this.date,
    required this.products,
    required this.from,
    required this.to,
    required this.initiator,
    required this.completer,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['_id'],
      date: DateTime.parse(json['createdAt']),
      products: (json['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      from: json['from'],
      to: json['to'],
      initiator: json['initiator'],
      completer: json['completer'] ?? '',
      fromId: json['fromId'],
      toId: json['toId'],
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
class DepartmentHistory extends StatefulWidget {
  const DepartmentHistory({super.key});

  @override
  DepartmentHistoryState createState() => DepartmentHistoryState();
}

class DepartmentHistoryState extends State<DepartmentHistory> {
  ApiService apiService = ApiService();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String select = '';
  String from = '';
  String to = '';
  final List<RequestModel> _requests = [];
  int _currentPage = 0;
  static const int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  Future<Map<String, dynamic>> fetchRequests(int page) async {
    final response = await apiService.get(
      'department-history?filter={"from" : {"\$regex" : "${from.toLowerCase()}"}, "to" : {"\$regex" : "${to.toLowerCase()}"}}&skip=$page&sort={"createdAt":-1}&startDate=$startDate&endDate=$endDate',
    );

    final data = response.data;
    final history = data['history'] as List<dynamic>;
    final totalDocuments = data['totalDocuments'] as int;
    return {
      'data': history.map((json) => RequestModel.fromJson(json)).toList(),
      'totalDocuments': totalDocuments,
    };
  }

  void sendProducts(RequestModel data) async {
    await apiService.post(
      'department/move-stock?senderId=${data.fromId}&receiverId=${data.toId}',
      {'body': data.products},
    );
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final newRequests = await fetchRequests(_currentPage);
      final List<RequestModel> newData = newRequests['data'];
      final int totalDocuments = newRequests['totalDocuments'];
      setState(() {
        _requests.addAll(newData);
        _currentPage++;
        _isLoading = false;
        _hasMore =
            newData.length == _limit && _requests.length < totalDocuments;
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

  handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
      });
    }
  }

  handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
      // getSales();
    });
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
    // Determine crossAxisCount based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 2 : 1;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Request History'),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return DepartmentRequest();
                },
              );
            },
            icon: Icon(Icons.request_quote),
          ),
        ],
      ),
      body: _requests.isEmpty && !_isLoading
          ? const Center(child: Text('No requests found'))
          : GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.2,
              ),
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

      // Column(
      //   children: [
      //     // Fixed filter row
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Row(
      //         children: [
      //           DateRangeHolder(
      //             fromDate: startDate,
      //             toDate: endDate,
      //             handleRangeChange: handleRangeChange,
      //             handleDateReset: handleDateReset,
      //           ),
      //           // Add other filters here if needed (e.g., TextField for 'from'/'to')
      //         ],
      //       ),
      //     ),
      //     // Scrollable grid

      //   ],
      // ),
    );
  }
}
