import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../components/tables/custom_data_table.dart';

@RoutePage()
class SupplierDetailsScreen extends StatefulWidget {
  final String supplierId;
  const SupplierDetailsScreen({super.key, required this.supplierId});

  @override
  SupplierDetailsState createState() => SupplierDetailsState();
}

class SupplierDetailsState extends State<SupplierDetailsScreen> {
  String supplierId = '';
  final ApiService apiService = ApiService();
  late Map supplierDetails = {};
  late List recentOrders;
  List orderHistory = [];
  @override
  void initState() {
    supplierId = widget.supplierId;
    getVendorDetails();
    getVendorOrders();
    super.initState();
  }

  Future<void> getVendorDetails() async {
    var vendor = await apiService.get('supplier/$supplierId');
    setState(() {
      supplierDetails = vendor.data;
    });
  }

  Future<void> getVendorOrders() async {
    var vendor = await apiService.get(
      'purchases/vendors?filter={"supplier" : "$supplierId"}&select=" totalPayable debt status purchaseDate productId"',
    );
    for (var i = 0; i < vendor.data.length; i++) {
      orderHistory.add({
        'product': vendor.data[i]['productId']['title'],
        'totalPayable': vendor.data[i]['totalPayable'],
        'purchaseDate': vendor.data[i]['purchaseDate'],
        'totalPaid': (vendor.data[i]['totalPayable'] - vendor.data[i]['debt']),
        'status': vendor.data[i]['status'],
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Supplier Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            label: Text('Edit'),
            icon: Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            spacing: 60,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('Supplier Summary'),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: supplierDetails.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : Card(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Supplier Name',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        SizedBox(width: 60),
                                        Text(
                                          capitalizeFirstLetter(
                                            supplierDetails['name'],
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Status',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        SizedBox(width: 100),
                                        Icon(
                                          Icons.mode_standby,
                                          color: Colors.green,
                                          size: 10,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          capitalizeFirstLetter(
                                            supplierDetails['status'],
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Main Contact',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        SizedBox(width: 60),

                                        SizedBox(width: 5),
                                        Text(
                                          capitalizeFirstLetter(
                                            supplierDetails['contactPerson'],
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Address',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        SizedBox(width: 80),

                                        SizedBox(width: 5),
                                        Text(
                                          capitalizeFirstLetter(
                                            supplierDetails['address'],
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Contact Information',
                            style: TextStyle(fontSize: smallScreen ? 10 : 14),
                          ),
                          smallScreen
                              ? IconButton.filledTonal(
                                  onPressed: () {},
                                  icon: Icon(Icons.add, size: 12),
                                  tooltip: 'Add New Contact',
                                )
                              : ElevatedButton.icon(
                                  onPressed: () {},
                                  label: Text(
                                    'Add New Contact',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  icon: Icon(Icons.add),
                                ),
                        ],
                      ),
                    ),
                    CustomDataTable(
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 300,
                            child: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text(
                              'Phone',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text(
                              'Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                      data: [],
                      cellBuilder: (supplier) => [
                        DataCell(
                          SizedBox(
                            width: 200,
                            child: Text(
                              capitalizeFirstLetter(supplier['name']),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 200,
                            child: Text(
                              supplier['email'],
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              supplier['phone_number']
                                  .toString()
                                  .formatToFinancial(isMoneySymbol: true),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              supplier['role'].toString().formatToFinancial(
                                isMoneySymbol: true,
                              ),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text('Resent Orders'),
                    ),
                    CustomDataTable(
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Product Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Total Amount',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Total Paid',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                      data: orderHistory,
                      cellBuilder: (supplier) => [
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              supplier['product'],
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              supplier['totalPayable']
                                  .toString()
                                  .formatToFinancial(isMoneySymbol: true),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              supplier['totalPaid']
                                  .toString()
                                  .formatToFinancial(isMoneySymbol: true),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              supplier['status'],
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              formatBackendTime(supplier['purchaseDate']),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
