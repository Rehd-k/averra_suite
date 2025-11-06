import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../service/api.service.dart';
import 'sections/customer_insight.dart';
import 'sections/financialsummary.dart';
import 'sections/inventorysummery.dart';
import 'sections/salesoverview.dart';
import 'sections/todo.dart';

@RoutePage()
class DashbaordManagerScreen extends StatefulWidget {
  final Function()? onResult;
  const DashbaordManagerScreen({super.key, this.onResult});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashbaordManagerScreen> {
  bool loading = true;
  final apiService = ApiService();
  final DateTime _fromDate = DateTime.now();
  final DateTime _toDate = DateTime.now();

  List dashboardInfo = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final results = await Future.wait([
        fetchSalesOverview(),
        fetchBestSellingProducts(),
        fetchInventorySummary(),
        fetchCustomerInsight(),
        fetchFinancialSummary(),
      ]);
      setState(() {
        dashboardInfo = results;
        loading = false;
      });
    } catch (e) {
      showToast('Error', ToastificationType.error);
    }
  }

  Future<Map> fetchSalesOverview() async {
    // Your API call for Sales Overview
    var salesInfo = await apiService.get(
      'analytics/profit-and-loss?startDate=$_fromDate&endDate=$_toDate',
    );

    return salesInfo.data;
  }

  Future<Map> fetchBestSellingProducts() async {
    // Your API call for Best Selling Products
    var bestSellingProducts = await apiService.get(
      'analytics/get-best-selling-products',
    );
    return bestSellingProducts.data;
  }

  Future<Map> fetchInventorySummary() async {
    var data = await apiService.get('analytics/inventory-summary');
    return data.data;
  }

  Future<void> fetchCustomerInsight() async {
    var data = await apiService.get('analytics/customer-summary');
    return data.data;
  }

  Future<void> fetchFinancialSummary() async {
    var data = await apiService.get('analytics/sales-data');
    return data.data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    child: Salesoverview(
                      totalSales: dashboardInfo[0]['totalRevenue'],
                      topSellingProducts: dashboardInfo[1],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(maxHeight: 400),
                    child: TodoTable(),
                  ),
                  Inventorysummery(data: dashboardInfo[2]),
                  CustomerInsight(data: dashboardInfo[3]),

                  Financialsummary(salesData: dashboardInfo[4]),
                ],
              ),
            ),
    );
  }
}
