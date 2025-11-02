import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import '../../service/toast.service.dart';

class DisplayStockTable extends StatefulWidget {
  final String department;
  const DisplayStockTable({super.key, required this.department});

  @override
  DisplayStockState createState() => DisplayStockState();
}

class DisplayStockState extends State<DisplayStockTable> {
  ApiService apiService = ApiService();
  dynamic snapShots = [];
  DateTime selectedDate = DateTime.now();

  bool isLoading = true;
  String department = '';

  Future<void> handleGetSnapShots() async {
    try {
      var res = await apiService.get(
        'stock-snapshot?department=$department&date=${selectedDate.toString()}',
      );

      List mergedList = [
        ...res.data[0]['finishedGoods'],
        ...res.data[0]['RawGoods'],
      ];
      setState(() {
        isLoading = false;
        snapShots = mergedList;
      });
    } catch (e) {
      showToast(e.toString(), ToastificationType.error);
    }
  }

  Future<void> selectDate(DateTime picked) async {
    selectedDate = picked;
    handleGetSnapShots();
  }

  @override
  void initState() {
    department = widget.department;
    handleGetSnapShots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(capitalizeFirstLetter(department)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, size: 10),
            tooltip: 'Select Date',
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                selectDate(picked);
              }
            },
          ),

          Text("${selectedDate.toLocal()}".split(' ')[0]),
          SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? SizedBox()
          : snapShots.isEmpty
          ? Center(child: Text('No Closing Stock Recorded At This Date'))
          : Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Clossing Stock')),
                    DataColumn(label: Text('Unit Cost')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: [
                    ...snapShots.map(
                      (e) => DataRow(
                        cells: [
                          DataCell(Text(e['title'] ?? 'Product Name')),
                          DataCell(Text(department)),
                          DataCell(
                            Text(
                              e['quantity'].toString().formatToFinancial(
                                isMoneySymbol: false,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              e['unitCost'].toString().formatToFinancial(
                                isMoneySymbol: false,
                              ),
                            ),
                          ),

                          DataCell(
                            Text(
                              e['cost'].toString().formatToFinancial(
                                isMoneySymbol: true,
                              ),
                            ),
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
