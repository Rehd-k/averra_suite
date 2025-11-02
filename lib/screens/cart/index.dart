import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';

import '../../components/emptylist.dart';
import '../../components/filter.pill.dart';
import '../../service/date_range_helper.dart';
import '../../service/token.service.dart';
import 'orderitem.dart';

@RoutePage()
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartState();
}

class _CartState extends State<CartScreen> {
  ApiService apiService = ApiService();
  JwtService jwtService = JwtService();
  late List orders = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String settled = 'pending';
  List statuses = [
    {'title': 'pending'},
    {'title': 'settled'},
  ];

  Future<void> sendNotification(
    String recipient,
    String message,
    String title,
  ) async {
    await apiService.post('notifications/recipient', {
      "message": message,
      "recipient": recipient,
      "title": title,
    });
  }

  Future<void> getOrders() async {
    var res = await apiService.get(
      'cart?filter={"department" : "${jwtService.decodedToken?['department']}", "status" : "$settled"}&startDate=$startDate&endDate=$endDate',
    );
    setState(() {
      orders = res.data;
    });
  }

  void handleSelectOrders(String value) {
    setState(() {
      settled = value;
    });
    getOrders();
  }

  Future<void> handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
      });
    }
    getOrders();
  }

  Future<void> resetRange() async {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
    });
    getOrders();
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DateRangeHolder(
                  fromDate: startDate,
                  toDate: endDate,
                  handleRangeChange: (String handle, DateTime picked) {
                    handleRangeChange(handle, picked);
                  },
                  handleDateReset: () {},
                ),
              ),

              SizedBox(width: 10),
              FiltersDropdown(
                pillIcon: Icons.pending_actions,
                selected: settled,
                menuList: statuses,
                doSelect: handleSelectOrders,
              ),
            ],
          ),
        ),

        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: EmptyComponent(
                    icon: Icons.remove_shopping_cart_outlined,
                    message: "No Orders Yet",
                    subMessage: "No Waiting Order Today",
                    reload: getOrders,
                  ),
                )
              : SingleChildScrollView(
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
                          (maxWidth - (spacing * (cardsPerRow - 1))) /
                          cardsPerRow;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          ...orders.map(
                            (order) => SizedBox(
                              width: cardWidth,
                              child: OrderItem(
                                orderItem: order,
                                sendNotification: sendNotification,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
