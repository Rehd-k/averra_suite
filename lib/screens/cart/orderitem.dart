import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../helpers/financial_string_formart.dart';

class OrderItem extends StatefulWidget {
  final Map<String, dynamic> orderItem;
  const OrderItem({super.key, required this.orderItem});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  ApiService apiService = ApiService();
  late Map<String, dynamic> orderItem;

  Future<void> updateSingleSettled() async {
    var res = await apiService.patch('cart/${orderItem['_id']}', orderItem);

    setState(() {
      orderItem = res.data;
    });
  }

  @override
  void initState() {
    super.initState();
    orderItem = widget.orderItem;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatBackendTime(orderItem['updatedAt'])),
                      const Text('Table 15'),
                      Text('From  - ${orderItem['initiator']}'),
                    ],
                  ),
                ),
                const Expanded(child: Center(child: Text('Pending'))),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 400,
            child: ListView(
              children: [
                ...orderItem['products']
                    .map(
                      (order) => ListTile(
                        leading: Text('X ${order['quantity']}'),
                        title: Text(order['title']),
                        trailing: Switch(
                          value: order['settled'] ?? false,
                          onChanged: (bool newValue) {
                            order['settled'] = newValue;
                            updateSingleSettled();
                          },
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              // Handle button press
            },
            child: Text(
              'Notify ${capitalizeFirstLetter(orderItem['initiator'])}',
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
