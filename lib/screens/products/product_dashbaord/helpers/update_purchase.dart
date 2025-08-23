import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../../service/api.service.dart';
import '../../../../service/toast.service.dart';

class UpdatePurchase extends StatefulWidget {
  final Map purchaseInfo;
  const UpdatePurchase({super.key, required this.purchaseInfo});

  @override
  UpdatePurchaseState createState() => UpdatePurchaseState();
}

class UpdatePurchaseState extends State<UpdatePurchase> {
  final ApiService apiService = ApiService();
  late Map purchaseInfo;
  late bool isDelivered = false;

  Future updatePurchase(String statusValue) async {
    final navigator = Navigator.of(context);
    try {
      showToast('loading', ToastificationType.info);
      var updatedPruchase = await apiService.patch(
        'purchases/update/${purchaseInfo['_id']}',
        {'status': statusValue},
      );
      showToast('Updated', ToastificationType.success);

      setState(() {
        updatedPruchase.data['status'] == 'Delivered' ? true : false;
      });
      navigator.pop();
    } catch (e) {
      showToast('Error', ToastificationType.error, description: e.toString());
    }
  }

  @override
  void initState() {
    purchaseInfo = widget.purchaseInfo;
    isDelivered = purchaseInfo['status'] == 'Delivered' ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Delivered'),
          Switch(
            value: isDelivered,
            onChanged: (bool value) {
              updatePurchase(value ? 'Delivered' : 'Not Delivered');
            },
          ),
        ],
      ),
    );
  }
}
