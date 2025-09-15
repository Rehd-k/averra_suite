import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

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
  late dynamic reqisitions = [];
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
        isApproved = value;
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
        actions: [
          Flexible(
            flex: 3,
            child: DateRangeHolder(
              fromDate: startDate,
              toDate: endDate,
              handleRangeChange: handleRangeChange,
              handleDateReset: handleDateReset,
            ),
          ),
          Expanded(
            flex: 1,
            child: DropdownButton<bool>(
              value: isApproved,
              items: const [
                DropdownMenuItem(value: true, child: Text('Filled')),
                DropdownMenuItem(value: false, child: Text('UnFilled')),
              ],
              onChanged: (bool? value) {
                if (value != null) {
                  handleFilter(value); // your callback
                }
              },
              borderRadius: BorderRadius.circular(12),
              underline: const SizedBox(), // removes default underline
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            ),
          ),
        ],
      ),
      body: ApprovalCards(
        data: reqisitions,
        update: approve,
        delete: unapprove,
      ),
    );
  }
}
