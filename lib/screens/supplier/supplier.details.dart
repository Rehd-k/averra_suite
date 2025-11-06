import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../components/tables/custom_data_table.dart';
import 'add_contacts.dart';
import 'order.history.dart';

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
  DateTime startDate = DateTime(2005);
  DateTime endDate = DateTime.now();
  late Map supplierDetails = {};
  late List recentOrders;
  List orderHistory = [];
  List cashflow = [];

  @override
  void initState() {
    supplierId = widget.supplierId;
    getVendorDetails();
    getVendorOrders();
    getCashFlow();
    super.initState();
  }

  Future<void> getVendorDetails() async {
    var vendor = await apiService.get('supplier/$supplierId');
    setState(() {
      supplierDetails = vendor.data;
    });
  }

  Future<void> updateSupplier() async {
    // Replace this with your database save logic
    await apiService.patch('supplier/${widget.supplierId}', {
      'otherContacts': supplierDetails['otherContacts'],
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('saved successfully!')));
  }

  Future<void> removeExtraContact(String contactId) async {
    setState(() {
      supplierDetails['otherContacts'].removeWhere(
        (contact) => contact['_id'] == contactId,
      );
    });

    await apiService.patch('supplier/${widget.supplierId}', {
      'otherContacts': supplierDetails['otherContacts'],
    });
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('saved successfully!')));
  }

  void updateSuppliersList() {
    showModalBottomSheet(
      context: context,
      builder: (addContext) {
        return AddSupplierContact(
          currentList: supplierDetails['otherContacts'] ?? [],
          onUpdated: (newList) {
            setState(() {
              supplierDetails['otherContacts'] = newList;
            });
          },
          supplierId: supplierId,
        );
      },
    );
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

  Future<void> getCashFlow() async {
    var cashFlow = await apiService.get(
      'cashflow?filter={"paymentFor": "$supplierId"}&startDate=$startDate&endDate=$endDate',
    );
    setState(() {
      cashflow = cashFlow.data['transactions'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          capitalizeFirstLetter('${supplierDetails['name']}'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: smallScreen
            ? [
                IconButton.filledTonal(
                  onPressed: () {},
                  tooltip: 'Edit',
                  icon: Icon(Icons.edit_outlined, size: 12),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  tooltip: 'Deactivate',
                  icon: Icon(Icons.remove_circle_outline, size: 12),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_forever_outlined, size: 12),
                ),
              ]
            : [
                ElevatedButton.icon(
                  onPressed: () {},
                  label: Text('Edit'),
                  icon: Icon(Icons.edit_outlined),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: Text('Deactivate'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: Text('Delete'),
                  icon: Icon(Icons.delete_forever_outlined),
                ),

                Row(children: []),
              ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Text('Supplier Summary')),
                Tab(icon: Text('Order History')),
                Tab(icon: Text('Payment History')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  supplierSummary(smallScreen),
                  OrderHistory(supplier: supplierId),
                  CustomDataTable(
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Date/Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Money In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Money out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Balance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    data: cashflow,
                    cellBuilder: (flow) => [
                      DataCell(
                        Text(
                          formatBackendTime(flow['createdAt']),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      DataCell(
                        Text(
                          flow['type'] == 'in'
                              ? flow['amount'].toString().formatToFinancial(
                                  isMoneySymbol: true,
                                )
                              : '-',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      DataCell(
                        Text(
                          flow['type'] == 'out'
                              ? flow['amount'].toString().formatToFinancial(
                                  isMoneySymbol: true,
                                )
                              : '-',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      DataCell(
                        Text(flow['title'], style: TextStyle(fontSize: 10)),
                      ),
                      DataCell(
                        Text(
                          flow['balanceAfter'].toString().formatToFinancial(
                            isMoneySymbol: true,
                          ),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // AppBar
        ), // Scaffold
      ), //
    );
  }

  SingleChildScrollView supplierSummary(bool smallScreen) {
    return SingleChildScrollView(
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
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: smallScreen ? 10 : 14,
                                ),
                              ),
                              smallScreen
                                  ? IconButton.filledTonal(
                                      onPressed: () {
                                        updateSuppliersList();
                                      },
                                      icon: Icon(Icons.add, size: 12),
                                      tooltip: 'Add New Contact',
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                        updateSuppliersList();
                                      },
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
                          columns: [
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Email',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Phone',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Role',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Delete',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          data: supplierDetails['otherContacts'] ?? [],
                          cellBuilder: (supplier) => [
                            DataCell(
                              Text(
                                capitalizeFirstLetter(supplier['name']),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                supplier['email'],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                supplier['phone_number'].toString(),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                supplier['role'].toString(),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),

                            DataCell(
                              IconButton(
                                onPressed: () {
                                  removeExtraContact(supplier['_id']);
                                },
                                icon: Icon(Icons.delete_outline, size: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (!smallScreen)
                  Expanded(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Associated Products',
                                  style: TextStyle(
                                    fontSize: smallScreen ? 10 : 14,
                                  ),
                                ),
                                smallScreen
                                    ? IconButton.filledTonal(
                                        onPressed: () {},
                                        icon: Icon(Icons.add, size: 12),
                                        tooltip: 'Add New Product',
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () {},
                                        label: Text(
                                          'Add New Product',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        icon: Icon(Icons.add),
                                      ),
                              ],
                            ),
                          ),
                          CustomDataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Current Stock',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Price',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  'Remove',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            data: supplierDetails['otherContacts'] ?? [],
                            cellBuilder: (supplier) => [
                              DataCell(
                                Text(
                                  capitalizeFirstLetter(supplier['name']),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  supplier['email'],
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),

                              DataCell(
                                Text(
                                  supplier['role'].toString(),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),

                              DataCell(
                                IconButton(
                                  onPressed: () {
                                    removeExtraContact(supplier['_id']);
                                  },
                                  icon: Icon(Icons.delete_outline, size: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (smallScreen)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Associated Products',
                            style: TextStyle(fontSize: smallScreen ? 10 : 14),
                          ),
                          smallScreen
                              ? IconButton.filledTonal(
                                  onPressed: () {
                                    updateSuppliersList();
                                  },
                                  icon: Icon(Icons.add, size: 12),
                                  tooltip: 'Add New Product',
                                )
                              : ElevatedButton.icon(
                                  onPressed: () {
                                    updateSuppliersList();
                                  },
                                  label: Text(
                                    'Add New Product',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  icon: Icon(Icons.add),
                                ),
                        ],
                      ),
                    ),
                    CustomDataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Phone',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Role',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      data: supplierDetails['otherContacts'] ?? [],
                      cellBuilder: (supplier) => [
                        DataCell(
                          Text(
                            capitalizeFirstLetter(supplier['name']),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        DataCell(
                          Text(
                            supplier['email'],
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        DataCell(
                          Text(
                            supplier['phone_number'].toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        DataCell(
                          Text(
                            supplier['role'].toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),

                        DataCell(
                          IconButton(
                            onPressed: () {
                              removeExtraContact(supplier['_id']);
                            },
                            icon: Icon(Icons.delete_outline, size: 10),
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
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          width: smallScreen ? 100 : 200,
                          child: Text(
                            'Product Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: smallScreen ? 100 : 200,
                          child: Text(
                            'Total Amount',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: smallScreen ? 100 : 200,
                          child: Text(
                            'Total Paid',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: smallScreen ? 100 : 200,
                          child: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: smallScreen ? 100 : 200,
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
                            supplier['totalPaid'].toString().formatToFinancial(
                              isMoneySymbol: true,
                            ),
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
    );
  }
}
