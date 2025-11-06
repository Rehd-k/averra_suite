import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../components/tables/suppliers.table.dart';

@RoutePage()
class SuppliersDashbaordScreen extends StatefulWidget {
  const SuppliersDashbaordScreen({super.key});

  @override
  SuppliersDashbaordState createState() => SuppliersDashbaordState();
}

class SuppliersDashbaordState extends State<SuppliersDashbaordScreen> {
  final ApiService apiService = ApiService();
  late Map res = {};
  bool isLoading = true;

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  Future<void> getDetails() async {
    var response = await apiService.get('supplier/dashbaord');
    setState(() {
      res = response.data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Supplier Managment',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
            style: ButtonStyle(),
            onPressed: () {
              // AddUser()
              // context.router.push();
            },
            label: Text('Add New', style: TextStyle(fontSize: 10)),
            icon: Icon(Icons.add, size: 10),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: res.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    smallScreen
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Active Suppliers',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Text(
                                          res['statusSummary']['active']
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Inactive Suppliers',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Text(
                                          res['statusSummary']['inactive']
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Active Suppliers',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Text(
                                          res['statusSummary']['active']
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Inactive Suppliers',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Text(
                                          res['statusSummary']['inactive']
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: Text(
                        'Top 5 Suppliers By Purchasd Volume',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (!isLoading)
                          Expanded(
                            flex: smallScreen ? 1 : 4,
                            child: SupplierTable(
                              suppliers: res['topSuppliers'],
                            ),
                          ),
                        if (!isLoading)
                          if (!smallScreen)
                            Expanded(
                              flex: 2,
                              child: SizedBox(),

                              // SupplierTable(
                              //   suppliers: res['latestAdditions'],
                              // ),
                            ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: Text(
                        'Latest Suppliers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: smallScreen ? 1 : 4,
                          child: SupplierTable(
                            suppliers: res['latestAdditions'],
                          ),
                        ),
                        if (!smallScreen) Expanded(flex: 2, child: SizedBox()),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
