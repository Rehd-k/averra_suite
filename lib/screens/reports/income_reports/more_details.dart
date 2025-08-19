import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../components/tables/gen_big_table/big_table_source.dart';
import '../../../../helpers/financial_string_formart.dart';

import 'make_return.dart';

class ShowDetails extends StatelessWidget {
  const ShowDetails({
    super.key,
    required this.dataList,
    required this.handleUpdate,
    required this.updatePageInfo,
    required this.handleShowDetails,
    required this.doRePrint,
  });

  final TableDataModel dataList;
  final Function handleUpdate;
  final Function updatePageInfo;
  final Function handleShowDetails;
  final Function doRePrint;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      dataList['products'],
    );

    List<Map<String, dynamic>> returns = List<Map<String, dynamic>>.from(
      dataList['returns'],
    );

    num totalSum = dataList['totalAmount'];
    num totalReturn = returns.fold(0, (sum, item) => sum + item['total']);
    num totalPaid = totalSum - dataList['discount'];
    num discount = dataList['discount'];
    num profit = dataList['profit'];
    num width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;

    return Container(
      height: isBigScreen ? 600 : 900,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          isBigScreen
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        handleShowDetails(dataList, isBigScreen);
                      },
                      icon: Icon(
                        Icons.close_fullscreen_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(180),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          Expanded(
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: SingleChildScrollView(
                child: table(context, data, [
                  {
                    'name': 'Title',
                    'size': ColumnSize.S,
                    'field': 'title',
                    'type': 'string',
                  },
                  {
                    'name': 'Quantity',
                    'size': ColumnSize.S,
                    'field': 'quantity',
                    'type': 'number',
                  },
                  {
                    'name': 'Price',
                    'size': ColumnSize.S,
                    'field': 'price',
                    'type': 'money',
                  },
                  {
                    'name': 'Total',
                    'size': ColumnSize.S,
                    'field': 'total',
                    'type': 'money',
                  },
                ]),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            height: 200,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  height: 20,
                  child: Center(
                    child: Text(
                      'Returns',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 170,
                  child: SingleChildScrollView(
                    child: table(context, returns, [
                      {
                        'name': 'Title',
                        'size': ColumnSize.S,
                        'field': 'title',
                        'type': 'string',
                      },
                      {
                        'name': 'Quantity',
                        'size': ColumnSize.S,
                        'field': 'quantity',
                        'type': 'number',
                      },
                      {
                        'name': 'Price',
                        'size': ColumnSize.S,
                        'field': 'price',
                        'type': 'money',
                      },
                      {
                        'name': 'Total',
                        'size': ColumnSize.S,
                        'field': 'total',
                        'type': 'money',
                      },
                      {
                        'name': 'Date',
                        'size': ColumnSize.S,
                        'field': 'returnedAt',
                        'type': 'date',
                      },
                      {
                        'name': 'Handler',
                        'size': ColumnSize.S,
                        'field': 'handler',
                        'type': 'string',
                      },
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            height: isBigScreen ? 95 : 400,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: isBigScreen
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: showDetails(
                          totalSum,
                          totalPaid,
                          profit,
                          discount,
                          totalReturn,
                        ),
                      ),
                      Expanded(flex: 1, child: handleButtons(context, data)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: showDetails(
                          totalSum,
                          totalPaid,
                          profit,
                          discount,
                          totalReturn,
                        ),
                      ),
                      Expanded(flex: 1, child: handleButtons(context, data)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Padding handleButtons(BuildContext context, List<Map<String, dynamic>> data) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MakeReturn(
                        updatePageInfo: updatePageInfo,
                        sales: data,
                        id: dataList['_id'],
                        transactionId: dataList['transactionId'],
                      ),
                    ),
                  );
                },
                child: Text('Return'),
              ),
              SizedBox(width: 7),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MakeReturn(
                        updatePageInfo: updatePageInfo,
                        sales: data,
                        id: dataList['_id'],
                        transactionId: dataList['transactionId'],
                      ),
                    ),
                  );
                },
                child: Text('Refund'),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(dataList['createdAt']),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    handleUpdate({'transactionDate': picked.toString()});
                  }
                },
                child: Text('Back\nDate'),
              ),
              ElevatedButton(
                onPressed: () async {
                  doRePrint(dataList);
                },
                child: Text('Reprint\nReceipt'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column showDetails(
    num totalSum,
    num totalPaid,
    num profit,
    num discount,
    num totalReturn,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Sale:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              totalSum.toString().formatToFinancial(isMoneySymbol: true),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Paid:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              totalPaid.toString().formatToFinancial(isMoneySymbol: true),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profit:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              profit.toString().formatToFinancial(isMoneySymbol: true),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Discount:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              discount.toString().formatToFinancial(isMoneySymbol: true),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Returns:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              totalReturn.toString().formatToFinancial(isMoneySymbol: true),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  DataTable table(
    BuildContext context,
    List<Map<String, dynamic>> data,
    List<Map<String, dynamic>> columns,
  ) {
    String formatDate(String isoDate) {
      final DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    }

    return DataTable(
      dataRowMinHeight: 35,
      columns: [
        ...columns.map((column) {
          return DataColumn2(label: Text(column['name']), size: column['size']);
        }),
      ],
      rows: data.map<DataRow>((item) {
        return DataRow(
          color: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (data.indexOf(item) % 2 == 1) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.surfaceBright;
              }
              if (data.indexOf(item) % 2 == 1) {
                return Theme.of(context).colorScheme.surfaceDim;
              } else {
                return Theme.of(context).colorScheme.surface;
              }
            } else {
              return Theme.of(context).colorScheme.surfaceBright;
            }
          }),
          cells: [
            ...columns.map(
              (columnDef) => DataCell(
                Text(
                  columnDef['type'] == 'money'
                      ? item[columnDef['field']].toString().formatToFinancial(
                          isMoneySymbol: true,
                        )
                      : columnDef['type'] == 'number'
                      ? item[columnDef['field']].toString().formatToFinancial()
                      : columnDef['type'] == 'date'
                      ? formatDate(item[columnDef['field']].toString())
                      : item[columnDef['field']].toString(),
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
