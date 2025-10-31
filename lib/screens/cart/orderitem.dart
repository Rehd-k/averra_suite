import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../helpers/financial_string_formart.dart';

class OrderItem extends StatefulWidget {
  final Map<String, dynamic> orderItem;
  final Function sendNotification;
  const OrderItem({
    super.key,
    required this.orderItem,
    required this.sendNotification,
  });

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
                      Text(
                        formatBackendTime(orderItem['updatedAt']),
                        style: TextStyle(fontSize: 12),
                      ),
                      Text('Order #${orderItem['orderNo']}'),
                      Text(
                        'From  - ${orderItem['initiator']}',
                        style: TextStyle(fontSize: 12),
                      ),
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
                for (final fromDept in orderItem['from'])
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...((fromDept['products'] ?? []) as List).map<Widget>(
                        (product) => ListTile(
                          leading: Text('X ${product['quantity']}'),
                          title: Text(product['title']),
                          trailing: Switch(
                            value: product['settled'] ?? false,
                            onChanged: (bool newValue) {
                              product['settled'] = newValue;
                              updateSingleSettled();
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              widget.sendNotification(
                orderItem['initiator'],
                'Order ${orderItem['orderNo']} is Ready',
                'Order Ready',
              );
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
