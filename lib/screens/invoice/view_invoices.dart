import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../service/api.service.dart';
import 'components/filters.dart';
import 'components/infinite_table.dart';

@RoutePage()
class ViewInvoices extends StatefulWidget {
  final String? invoiceId;
  const ViewInvoices({super.key, this.invoiceId});

  @override
  ViewInvoicesState createState() => ViewInvoicesState();
}

class ViewInvoicesState extends State<ViewInvoices> {
  ApiService apiService = ApiService();
  final JsonEncoder jsonEncoder = JsonEncoder();
  String selectedDateField = 'createdAt';
  String selectedForSearch = 'invoiceNumber';
  String searchParams = '';
  String selectedStatus = '';
  List suggestions = [];
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  static const _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  String currentFrameId = 'invoicePDF';
  List<Invoice> _invoices = [];
  int _currentOffset = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  void onFieldChange(value) {
    setState(() {
      selectedDateField = value;
    });
  }

  onInputChange(value) {
    setState(() {
      selectedForSearch = value;
    });
  }

  onSelectStatus(value) {
    setState(() {
      selectedStatus = value;
    });
    _invoices = [];
    _fetchInvoices();
  }

  handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        _fromDate = picked;
      });
    } else if (select == 'to') {
      setState(() {
        _toDate = picked;
      });
    }
    _invoices = [];
    _fetchInvoices();
  }

  handleRangeChanged(String rangeLabel) {
    setState(() {
      selectedDateField = rangeLabel;
    });
  }

  onSearchParamsChange(value) async {
    await Future.delayed(const Duration(seconds: 1));
    _invoices = [];
    setState(() {
      searchParams = value;
    });

    _fetchInvoices();
  }

  handleDateReset() {
    setState(() {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      // getSales();
    });
  }

  checkIfInvoiceIdAndGetIno() {
    if (widget.invoiceId != null) {
      searchParams = widget.invoiceId!;
      _fromDate = DateTime(2000);
      _toDate = DateTime.now();
      _fetchInvoices();
    } else {
      _fetchInvoices();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
            !_isLoading &&
            _hasMore) {
          _fetchInvoices();
        }
      });
    }
  }

  Future<void> deleteInvoice(String id) async {
    toastification.show(
      title: Text('Loading'),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
    );
    await apiService.delete('invoice?filter={"_id": "$id"}');
    setState(() {
      _invoices.removeWhere((invoice) => invoice.id == id);
    });
    toastification.show(
      title: Text('Done - Invoice deleted'),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  void initState() {
    super.initState();
    checkIfInvoiceIdAndGetIno();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    final newItems = await fetchInvoices(_currentOffset, _pageSize);
    setState(() {
      _invoices.addAll(newItems);
      _currentOffset += newItems.length;
      _hasMore = newItems.length == _pageSize;
      _isLoading = false;
    });
  }

  Future<Iterable<Invoice>> fetchInvoices(int offset, int limit) async {
    final response = await apiService.get(
      'invoice?filter={"$selectedForSearch":{"\$regex" : "${searchParams.toLowerCase()}"}, "status" : {"\$regex" : "${selectedStatus.toLowerCase()}"}}&sort={"$selectedDateField":-1}&startDate=$_fromDate&endDate=$_toDate&selectedDateField=$selectedDateField&limit=$_pageSize',
    );

    if (offset >= 60) return [];

    var data = response.data as List;

    return data.map<Invoice>((item) {
      return Invoice(
        id: item['_id'],
        invoiceNumber: item['invoiceNumber'],
        customer: item['customer'],
        issueDate: item['issuedDate'],
        dueDate: item['dueDate'],
        recurringCycle: item['from'],
        total: item['totalAmount'],
        amountPaid: (item['transactionId'] as List<dynamic>?)?.join(', ') ?? '',
        status: item['status'],
        items: item['items'],
        discount: item['discount'],
        tax: item['tax'],
        bank: item['bank'],
        note: item['note'].isEmpty
            ? 'Thank\'s For Doing Business With Us'
            : item['note'],
      );
    });
  }

  Container dateRangeHolder(BuildContext context, isBigScreen) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Row(
            children: [
              isBigScreen ? Text('From :') : SizedBox.shrink(),
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withAlpha(180),
                ),
                tooltip: 'From date',
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fromDate,
                    firstDate: DateTime(2000),
                    lastDate: _toDate,
                  );
                  if (picked != null) {
                    handleRangeChange('from', picked);
                  }
                },
              ),
              Text("${_fromDate.toLocal()}".split(' ')[0]),
            ],
          ),
          SizedBox(width: 16),
          Row(
            children: [
              isBigScreen ? Text('To :') : SizedBox.shrink(),
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withAlpha(180),
                ),
                tooltip: 'To date',
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _toDate,
                    firstDate: _fromDate,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    handleRangeChange('to', picked);
                  }
                },
              ),
              Text("${_toDate.toLocal()}".split(' ')[0]),
            ],
          ),
          Spacer(),
          isBigScreen
              ? OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = DateTime.now();
                      _toDate = DateTime.now();
                      // getSales();
                    });
                  },
                  child: Text('Reset'),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = DateTime.now();
                      _toDate = DateTime.now();
                      // getSales();
                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage(String id) async {
    await apiService.get('invoice/send-whatsapp/$id');
  }

  Future<void> _updateInvoice(String id, transaction) async {
    try {
      final response = await apiService.put(
        'invoice/update/${jsonEncoder.convert({'_id': id})}',
        transaction,
      );

      if (response.statusCode == 200) {
        setState(() {
          _invoices = _invoices.map((invoice) {
            if (invoice.id == id) {
              return invoice.copyWith(
                status: 'paid',
                transactionId: transaction['transactionId'],
              );
            }
            return invoice;
          }).toList();
        });
        debugPrint('Invoice updated successfully.');
      } else {
        debugPrint('Failed to update invoice: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error updating invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 2 : 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice list',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 30 : 54,
                    fontWeight: FontWeight.w100,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.router.push(AddInvoice());
                  },
                  label: const Text('Add Invoice'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 5),
            FilterHeader(
              selectedDateField: selectedDateField,
              selectedForSearch: selectedForSearch,
              selectedStatus: selectedStatus,
              onFieldChange: onFieldChange,
              onInputChange: onInputChange,
              onSelectStatus: onSelectStatus,
              suggestions: suggestions,
              onSearchParamsChange: onSearchParamsChange,
              handleRangeChange: handleRangeChange,
              handleDateReset: handleDateReset,
              fromDate: _fromDate,
              toDate: _toDate,
            ),
            const SizedBox(height: 20),
            Container(
              constraints: BoxConstraints(minHeight: 200),
              child: InvoiceTablePage(
                deleteInvoice: deleteInvoice,
                invoices: _invoices,
                scrollController: _scrollController,
                isLoading: _isLoading,
                hasMore: _hasMore,
                handleSendMessage: _handleSendMessage,
                updateInvoice: _updateInvoice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
