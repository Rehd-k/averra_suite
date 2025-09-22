import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../components/emptylist.dart';
import '../../components/filter.pill.dart';
import '../../service/api.service.dart';
import '../../service/date_range_helper.dart';
import '../../service/token.service.dart';
import 'components/requisition.cards.dart';

@RoutePage()
class PendingRequisition extends StatefulWidget {
  const PendingRequisition({super.key});

  @override
  PendingRequisitionState createState() => PendingRequisitionState();
}

class PendingRequisitionState extends State<PendingRequisition> {
  ApiService apiService = ApiService();
  JwtService jwtService = JwtService();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final JsonEncoder jsonEncoder = JsonEncoder();
  late List reqisitions = [];
  bool isApproved = false;

  handleRangeChange(String select, DateTime picked) async {
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
      'reqisition?filter={"from" : {"\$regex" : "${jwtService.decodedToken?['location'].toLowerCase()}"}}&skip=${reqisitions.length}&limit=${10}&sort=$sorting&startDate=$startDate&endDate=$endDate&selectedDateField=createdAt',
    );

    setState(() {
      reqisitions = result.data;
    });
  }

  Future<void> approve(String id, value) async {
    showToast('loading...', ToastificationType.info);
    await apiService.patch('reqisition/$id', value);
    showToast('Done', ToastificationType.success);
  }

  Future<void> unapprove(String id) async {
    showToast('loading...', ToastificationType.info);
    await apiService.delete('reqisition/$id');
    showToast('Done', ToastificationType.success);
    getRequisitions();
  }

  handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
      reqisitions = [];
      // getSales();
    });
    getRequisitions();
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
              icon: Icons.list_alt_outlined,
              message: 'No Pending Reqisitions At This Time',
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
