import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import 'orderitem.dart';

@RoutePage()
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartState();
}

class _CartState extends State<CartScreen> {
  ApiService apiService = ApiService();
  late List orders = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Future<void> getOrders() async {
    var res = await apiService.get(
      'cart?filter={}&startDate=$startDate&endDate=$endDate',
    );

    setState(() {
      orders.addAll(res.data);
    });
  }


  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine how many cards per row based on screen width
          double maxWidth = constraints.maxWidth;
          int cardsPerRow;

          if (maxWidth >= 900) {
            cardsPerRow = 4; // large screen
          } else if (maxWidth >= 600) {
            cardsPerRow = 3; // medium screen
          } else {
            cardsPerRow = 1; // small screen
          }

          // Card width calculation with spacing
          double spacing = 16.0;
          double cardWidth =
              (maxWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              ...orders.map(
                (order) => SizedBox(
                  width: cardWidth,
                  child: OrderItem(orderItem: order),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
