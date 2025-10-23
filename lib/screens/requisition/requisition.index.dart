import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/components/emptylist.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../components/filter.pill.dart';
import '../../service/api.service.dart';
import '../../service/date_range_helper.dart';
import '../../service/toast.service.dart';
import '../../service/token.service.dart';
import 'components/requisition.cards.dart';

@RoutePage()
class RequisitionIndex extends StatefulWidget {
  const RequisitionIndex({super.key});

  @override
  RequisitionIndexState createState() => RequisitionIndexState();
}

class RequisitionIndexState extends State<RequisitionIndex> {
  ApiService apiService = ApiService();
  JwtService jwtService = JwtService();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final JsonEncoder jsonEncoder = JsonEncoder();

  late dynamic reqisitions = [];
  bool isApproved = false;

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
        reqisitions = [];
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
        reqisitions = [];
      });
    }
    getRequisitions();
  }

  Future<void> getRequisitions() async {
    var sorting = jsonEncoder.convert({"createdAt": 'asc'});
    var result = await apiService.get(
      'reqisition?filter={"approved" : $isApproved}&skip=${reqisitions.length}&limit=${40}&sort=$sorting&startDate=$startDate&endDate=$endDate&selectedDateField=createdAt',
    );
    setState(() {
      reqisitions = result.data;
    });
  }

  void handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
      reqisitions = [];
    });
    getRequisitions();
  }

  Future<void> approve(String id, value) async {
    showToast('loading...', ToastificationType.info);
    await apiService.patch('reqisition/$id', value);
    showToast('Done', ToastificationType.success);
  }

  Future<void> handleFilter(value) async {
    if (value != null) {
      setState(() {
        isApproved = value == 'UnFilled' ? false : true;
        reqisitions = [];
      });
    }
    getRequisitions();
  }

  Future<void> unapprove(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }
    showToast('loading...', ToastificationType.info);
    await apiService.delete('reqisition/$id');
    setState(() {
      reqisitions = [];
    });
    showToast('Done', ToastificationType.success);
    getRequisitions();
  }

  @override
  void initState() {
    getRequisitions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: DateRangeHolder(
          fromDate: startDate,
          toDate: endDate,
          handleRangeChange: handleRangeChange,
          handleDateReset: handleDateReset,
        ),

        actions: [
          FiltersDropdown(
            selected: 'Filled',
            menuList: [
              {'title': 'Filled'},
              {'title': 'UnFilled'},
            ],
            doSelect: handleFilter,
            pillIcon: Icons.approval_rounded,
          ),
        ],
      ),
      body: reqisitions.isEmpty
          ? EmptyComponent(
              icon: Icons.list_alt,
              message: 'No Requsition At This Time',
              reload: getRequisitions,
              subMessage: 'Come back later',
            )
          : ApprovalCards(
              data: reqisitions,
              update: approve,
              delete: unapprove,
            ),
    );
  }
}
