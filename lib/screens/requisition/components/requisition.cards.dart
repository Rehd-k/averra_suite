import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/token.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApprovalCards extends StatelessWidget {
  final dynamic data;
  final Function update;
  final Function delete;

  const ApprovalCards({
    super.key,
    required this.data,
    required this.update,
    required this.delete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 1; // 3 on big, 1 on small

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 3,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final bool approved = item['approved'] ?? false;
        final createdAt = DateTime.tryParse(item['createdAt'] ?? '');
        final formattedDate = createdAt != null
            ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
            : 'Unknown date';

        return GestureDetector(
          onTap: () => _showProducts(context, item['products'] ?? []),
          child: Card(
            elevation: 8,
            shadowColor: approved
                ? Colors.greenAccent.withValues(alpha: 0.5)
                : Colors.redAccent.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date: $formattedDate",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth > 600 ? 14 : 10,
                        ),
                      ),
                      if (item['initiator'] ==
                              JwtService().decodedToken?['username'] ||
                          [
                            'god',
                            'admin',
                          ].contains(JwtService().decodedToken?['role']))
                        IconButton(
                          onPressed: () {
                            delete(item['_id']);
                          },
                          icon: Icon(Icons.delete, size: 10),
                          tooltip: 'Delete',
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    "Initiator: ${capitalizeFirstLetter(item['initiator'])}",
                  ),
                  item['from'] == null
                      ? Text("To: ${capitalizeFirstLetter(item['to'])}")
                      : Text("From: ${capitalizeFirstLetter(item['from'])}"),
                  item['from'] == null
                      ? Text("From: ${capitalizeFirstLetter(item['location'])}")
                      : Text(
                          "Location: ${capitalizeFirstLetter(item['location'])}",
                        ),
                  Text("Products : ${item['products'].length}"),
                  Text(
                    "Total Cost : ${item['totalCost'].toString().formatToFinancial(isMoneySymbol: false)}",
                  ),

                  const Spacer(),

                  // Buttons only if not approved
                  if (!approved &&
                      [
                        'god',
                        'admin',
                      ].contains(JwtService().decodedToken?['role']))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            delete(item['_id']);
                          },
                          child: const Text("Decline"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            update(item['_id'], {"approved": true});
                          },
                          child: const Text("Fill"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProducts(BuildContext context, List<dynamic> products) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final product = products[index];
            return ListTile(
              title: Text(product['product_title'] ?? 'Unknown'),
              subtitle: Text(
                "Qty: ${product['quantity']}   Cost: ${product['cost']}",
              ),
            );
          },
        ),
      ),
    );
  }
}
