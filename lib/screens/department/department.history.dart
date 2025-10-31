import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../components/filter.pill.dart';
import '../../components/request.card.dart';
import '../../service/api.service.dart';
import '../../service/date_range_helper.dart';
import '../../service/token.service.dart';

class RequestModel {
  final String id;
  final DateTime date;
  final DateTime approvedDate;
  final List<Product> products;
  final String from;
  final String fromId;
  final String toId;
  final String to;
  final String initiator;
  final String completer;
  final String section;

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
    required this.approvedDate,
    required this.section,
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
      completer: json['closer'] ?? '',
      fromId: json['fromId'],
      toId: json['toId'],
      approvedDate: DateTime.parse(json['updatedAt']),
      section: json['section'],
    );
  }
}

class Product {
  final String title;
  final int quantity;
  // final double price;

  Product({required this.title, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['product']['title'],
      quantity: json['quantity'],
      // price: json['price'].toDouble(),
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
  final JwtService jwtService = JwtService();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String select = '';
  String from = '';
  String to = '';
  late List<RequestModel> _requests = [];

  late List departmentFronts = [];
  bool loading = true;

  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String? showFilter = 'all';
  String status = 'all';
  String department = 'Select';
  late List statuses = [
    {'title': "all"},
    {'title': "true"},
    {'title': "false"},
  ];

  Future<Map<String, dynamic>> fetchRequests(int page) async {
    final response = await apiService.get(
      'department-history?filter={"department":"$department","confirmed":"$status"}&skip=$page&sort={"createdAt":-1}&startDate=$startDate&endDate=$endDate',
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
      final newRequests = await fetchRequests(_requests.length);
      final List<RequestModel> newData = newRequests['data'];
      // final int totalDocuments = newRequests['totalDocuments'];
      setState(() {
        _requests.addAll(newData);
        // _currentPage++;
        _isLoading = false;
        _hasMore = newData.length < 12;

        //    newData.length < _limit && _requests.length < totalDocuments;
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

  Future<void> handleRangeChange(String select, DateTime picked) async {
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

  void handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
      // getSales();
    });
  }

  void handleSelectStatus(value) {
    setState(() {
      _requests = [];
      status = value;
    });
    _loadMore();
  }

  void handleSelectDepartment(value) {
    setState(() {
      _requests = [];
      department = value;
    });
    _loadMore();
  }

  void getDepartments() async {
    var toDepartments = [];
    var result = await apiService.get('department?active=${true}');
    for (var element in result.data) {
      if (element['access'].contains(jwtService.decodedToken?['role'])) {
        toDepartments.add(element);
      }
    }
    setState(() {
      departmentFronts = toDepartments;
      loading = false;

      _loadMore();
    });
  }

  @override
  void initState() {
    getDepartments();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {}
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
    return Column(
      children: [
        // Fixed filter row
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            // Add this wrapper
            width: double.infinity, // Make it full width
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this
              children: [
                Flexible(
                  // Replace Expanded with Flexible if needed
                  child: DateRangeHolder(
                    fromDate: startDate,
                    toDate: endDate,
                    handleRangeChange: handleRangeChange,
                    handleDateReset: handleDateReset,
                  ),
                ),

                FiltersDropdown(
                  pillIcon: Icons.pending_actions,
                  selected: status == 'true'
                      ? 'approved'
                      : status == 'false'
                      ? 'pending'
                      : 'all',
                  menuList: statuses,
                  doSelect: handleSelectStatus,
                ),

                FiltersDropdown(
                  pillIcon: Icons.pending_actions,
                  selected: department,
                  menuList: departmentFronts,
                  doSelect: handleSelectDepartment,
                ),
              ],
            ),
          ),
        ),

        // Expanded widget to allow GridView to take remaining space
        Expanded(
          child: _requests.isEmpty && !_isLoading
              ? const Center(child: Text('No requests found'))
              : GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500,
                    mainAxisExtent: 480, // width per card
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _requests.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _requests.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final request = _requests[index];
                    return RequestCard(request: request);
                  },
                ),
        ),
      ],
    );
  }
}
