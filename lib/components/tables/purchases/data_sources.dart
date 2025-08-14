import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../helpers/financial_string_formart.dart';

class DessertDataSourceAsync extends AsyncDataTableSource {
  DessertDataSourceAsync({
    required this.data,
    required this.columnDefs,
    required this.allowMultipleSelection,
    required this.handleSelection,
    required this.context,
    required this.longPress,
    this.actions,
  });

  DessertDataSourceAsync.empty(
    this.allowMultipleSelection,
    this.handleSelection,
    this.context,
    this.longPress,
  ) {
    _empty = true;
  }

  DessertDataSourceAsync.error(
    this.allowMultipleSelection,
    this.handleSelection,
    this.context,
    this.longPress,
  ) {
    _errorCounter = 0;
  }

  late List<dynamic> data;
  late List<dynamic> columnDefs;
  bool _empty = false;
  int? _errorCounter;
  final Set<int> _selectedRows = {};
  final bool allowMultipleSelection;
  final Function handleSelection;
  final BuildContext context;
  final bool longPress;
  List? actions;

  void sort(String columnName, bool ascending) {
    refreshDatasource();
  }

  @override
  void selectAll() {
    for (var i = 0; i < data.length; i++) {
      _selectedRows.add(i);
      setRowSelection(ValueKey<int>(i), true);
    }
    handleSelection(getSelectedRows());
    notifyListeners();
  }

  @override
  void deselectAll() {
    _selectedRows.clear();
    notifyListeners();
    handleSelection(getSelectedRows());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    String formatDate(String isoDate) {
      final DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    }

    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    assert(startIndex >= 0);

    var result = data;

    if (_empty) {
      return AsyncRowsResponse(0, []);
    }

    var paginatedData = result.skip(startIndex).take(count).toList();

    Color getRowColor(Map<String, dynamic> product, int index) {
      if (product['status'] != null && product['status'] == 'Not Delivered') {
        return Colors.red.withAlpha(77);
      }
      if (product['debt'] != null && product['debt'] > 0) {
        return Colors.yellow.withAlpha(77);
      }

      if (product['status'] != null) {
        return Colors.green.withAlpha(77);
      }

      if (product['isAvailable'] != null && product['isAvailable'] != true) {
        return Colors.red.withAlpha(77);
      }

      if (product['quantity'] != null &&
          product['roq'] != null &&
          product['quantity'] <= product['roq']) {
        return Colors.yellow.withAlpha(77);
      }

      if (product['quantity'] != null && product['quantity'] < 1) {
        return Colors.red.withAlpha(77);
      } else if (product['quantity'] != null && product['quantity'] > 1) {
        return Colors.green.withAlpha(77);
      }

      return index % 2 == 0
          ? Theme.of(context).colorScheme.surfaceDim
          : Theme.of(context).colorScheme.surfaceBright;
    }

    var r = AsyncRowsResponse(
      result.length,
      paginatedData.asMap().entries.map((entry) {
        final index = entry.key + startIndex;
        final purchase = entry.value;
        return DataRow(
          color: WidgetStateProperty.resolveWith(
            (states) => getRowColor(purchase, index),
          ),
          onLongPress: () {
            // longPress
            //     ? context.router.push(ProductDashboard(
            //         productId: purchase['_id'], productName: purchase['title']))
            //     : null;
          },
          key: ValueKey<int>(index),
          selected: _selectedRows.contains(index),
          onSelectChanged: (value) {
            if (value != null) {
              if (allowMultipleSelection) {
                if (value) {
                  _selectedRows.add(index);
                  setRowSelection(ValueKey<int>(index), true);
                } else {
                  _selectedRows.remove(index);
                  setRowSelection(ValueKey<int>(index), false);
                }
              } else {
                _selectedRows.clear();
                deselectAll();
                if (value) {
                  _selectedRows.add(index);
                  setRowSelection(ValueKey<int>(index), true);
                }
              }
              handleSelection(getSelectedRows());
              notifyListeners();
            }
          },
          cells: [
            ...columnDefs.map(
              (columnDef) =>
                  DataCell(filedText(columnDef, purchase, formatDate)),
            ),
          ],
        );
      }).toList(),
    );

    return r;
  }

  num getSold(List sold) {
    return sold.fold(0, (sum, item) => sum + (item["amount"] ?? 0));
  }

  filedText(columnDef, purchase, String Function(String isoDate) formatDate) {
    switch (columnDef['type']) {
      case 'money':
        return Text(
          purchase[columnDef['field']].toString().formatToFinancial(
            isMoneySymbol: true,
          ),
        );
      case 'number':
        return Text(
          purchase[columnDef['field']].toString().formatToFinancial(),
        );
      case 'date':
        return Text(formatDate(purchase[columnDef['field']].toString()));
      case 'uppercase':
        return Text(purchase[columnDef['field']].toString().toUpperCase());
      case 'actions':
        return Row(children: [...?actions]);
      case 'sold':
        return Text(
          getSold(purchase[columnDef['field']]).toString().formatToFinancial(),
        );
      default:
        return Text(purchase[columnDef['field']].toString());
    }
  }

  List getSelectedRows() {
    return _selectedRows.map((index) => data[index]).toList();
  }
}
