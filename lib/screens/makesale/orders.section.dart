import 'package:averra_suite/components/emptylist.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class OrdersSection extends StatelessWidget {
  final List ordersSections;
  final Function loadCartFromStorage;
  final Function removeCartFromStorage;
  const OrdersSection({
    super.key,
    required this.ordersSections,
    required this.loadCartFromStorage,
    required this.removeCartFromStorage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 600 ? 2 : (width < 1024 ? 3 : 4);

        // If user didn't provide ordersSections, create some sample items.
        final items = ordersSections.isNotEmpty ? ordersSections : [];

        return items.isEmpty
            ? EmptyComponent(
                icon: Icons.add_shopping_cart,
                message: 'No Orders Yet',
                reload: () {},
                subMessage: 'Add Orders to see them listed here.',
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Order #${item['orderNo']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['total']}'.formatToFinancial(
                                  isMoneySymbol: true,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton.filledTonal(
                                iconSize: 10,
                                tooltip: 'Activate',
                                icon: Icon(Icons.login_outlined, size: 12),
                                onPressed: () => loadCartFromStorage(item['_id']),
                              ),

                              IconButton.filledTonal(
                                iconSize: 10,
                                tooltip: 'Delete',
                                icon: Icon(Icons.delete, size: 12),
                                onPressed: () =>
                                    removeCartFromStorage(item['_id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
