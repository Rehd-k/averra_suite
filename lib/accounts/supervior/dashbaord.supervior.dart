import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../components/tables/small.products.table.dart';
import 'sections/top.dart';

@RoutePage()
class DashbaordSuperviorScreen extends StatefulWidget {
  const DashbaordSuperviorScreen({super.key});

  @override
  DashbaordSuperviorState createState() => DashbaordSuperviorState();
}

class DashbaordSuperviorState extends State<DashbaordSuperviorScreen> {
  bool isLoading = true;
  bool hasError = false;
  ApiService apiService = ApiService();
  DateTime dateTime = DateTime.now();
  late List<Map<String, dynamic>> dashboardData;

  Future<void> getDashbaordData() async {
    Future.wait([
          getBestSellingProducts(),
          getProfitOrLossData(),
          fetchInventorySummary(),
          getSuppliersData(),
        ])
        .then((value) {
          setState(() {
            isLoading = false;
            dashboardData = (value).cast<Map<String, dynamic>>();
          });
        })
        .catchError((error) {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        });
  }

  Future getBestSellingProducts() async {
    var products = await apiService.get('analytics/get-best-selling-products');
    return products.data;
  }

  Future getProfitOrLossData() async {
    var profitOrLoss = await apiService.get(
      'analytics/profit-and-loss?startDate=${dateTime.toIso8601String()}&endDate=${dateTime.toIso8601String()}',
    );
    return profitOrLoss.data;
  }

  Future<Map> fetchInventorySummary() async {
    var data = await apiService.get('analytics/inventory-summary');
    return data.data;
  }

  Future<void> getSuppliersData() async {
    var data = await apiService.get('supplier/dashbaord');
    return data.data;
  }

  @override
  void initState() {
    getDashbaordData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasError
        ? const Center(child: Text('An error occurred while fetching data'))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Top(
                  topValues: {
                    ...dashboardData[1],
                    'lowStock': dashboardData[2]['lowStockCount'],
                    'inventoryValue': dashboardData[2]['totalValue'],
                    'activeSupliers':
                        dashboardData[3]['statusSummary']['active'],
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      'Top 5 Products By Purchasd Volume',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                if (!isLoading)
                  Row(
                    children: [
                      Expanded(
                        flex: !isBigScreen ? 1 : 4,
                        child: SmallProductsTable(
                          products: dashboardData[0]['topSellingToday'],
                        ),
                      ),

                      if (isBigScreen)
                        Expanded(
                          flex: 2,
                          // child: SupplierTable(suppliers: res['topSuppliers']),
                          child: SizedBox(),
                        ),
                    ],
                  ),
              ],
            ),
          );
  }
}
