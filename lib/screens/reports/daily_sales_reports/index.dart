import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/dailysalesreport.dart';
import '../../../service/api.service.dart';

@RoutePage()
class DailySaleIndexScreen extends StatefulWidget {
  const DailySaleIndexScreen({super.key});

  @override
  DailySaleIndexState createState() => DailySaleIndexState();
}

class DailySaleIndexState extends State<DailySaleIndexScreen> {
  final apiService = ApiService();
  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
  final pdfReportService = PdfReportService();
  dynamic reportData;

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        _fromDate = picked;
      });
    } else if (select == 'to') {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Future<void> handleGetReport() async {
    var res = await apiService.get(
      'analytics/get-stock-sales-report?startDate=$_fromDate&endDate=$_toDate',
    );
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(res.data);
    final ByteData bytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = bytes.buffer.asUint8List();

    // 3. Execute
    await PdfReportService().saveAndShareFile(data, logoBytes);
  }

  void showReportBottomSheet(bool isBigScreen) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              dateRangeHolder(context, !isBigScreen),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.barcode_reader),
                      label: Text("Print"),
                      onPressed: () async {
                        await handleGetReport();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.share),
            label: Text("Download & Share Report"),
            onPressed: () async {
              showReportBottomSheet(!smallScreen);
              // 1. Load Logo
            },
          ),
        ],
      ),
      body: Center(child: Text('data')),
    );
  }

  Container dateRangeHolder(BuildContext context, isBigScreen) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: isBigScreen
          ? Row(
              children: [
                Row(
                  children: [
                    isBigScreen ? Text('From :') : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      tooltip: 'From date',
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: _toDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          handleRangeChange('from', picked);
                        }
                      },
                    ),
                    Text(
                      _fromDate != null
                          ? "${_fromDate!.toLocal()}".split(' ')[0]
                          : "From",
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    isBigScreen ? Text('To :') : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      tooltip: 'To date',
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _toDate ?? DateTime.now(),
                          firstDate: _fromDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          handleRangeChange('to', picked);
                        }
                      },
                    ),
                    Text(
                      _toDate != null
                          ? "${_toDate!.toLocal()}".split(' ')[0]
                          : "To",
                    ),
                  ],
                ),
                Spacer(),
                isBigScreen
                    ? OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _fromDate = DateTime.now();
                            _toDate = DateTime.now();
                          });
                        },
                        child: Text('Reset'),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _fromDate = DateTime.now();
                            _toDate = DateTime.now();
                          });
                        },
                        icon: Icon(Icons.cancel_outlined),
                      ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            tooltip: 'From date',
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: _toDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                handleRangeChange('from', picked);
                              }
                            },
                          ),
                          Text(
                            _fromDate != null
                                ? "${_fromDate!.toLocal()}".split(' ')[0]
                                : "From",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isBigScreen) Text('To :'),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            tooltip: 'To date',
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _toDate ?? DateTime.now(),
                                firstDate: _fromDate ?? DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                handleRangeChange('to', picked);
                              }
                            },
                          ),
                          Text(
                            _toDate != null
                                ? "${_toDate!.toLocal()}".split(' ')[0]
                                : "To",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = DateTime.now();
                      _toDate = DateTime.now();
                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
              ],
            ),
    );
  }
}
