import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../helpers/financial_string_formart.dart';
import '../service/api.service.dart';

// Assuming Request and Product classes are defined elsewhere with the necessary properties.
// Also assuming the formatToFinancial extension is defined.

class RequestCard extends StatefulWidget {
  final dynamic request; // Replace 'dynamic' with your actual Request type

  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _isExpanded = false;
  double? _productsHeight;
  final GlobalKey _productsKey = GlobalKey();
  final ApiService apiService = ApiService();

  Future<void> handleApprove(String id, String section) async {
    showToast('loading...', ToastificationType.info);
    await apiService.get('department-history/approve/$id/$section');
    setState(() {});
    showToast('Done', ToastificationType.success);
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final productsTiles = request.products
        .map<Widget>(
          (product) => ListTile(
            title: Text(product.title, style: TextStyle(fontSize: 10)),

            trailing: Text(
              'Quantity: ${product.quantity}',
              style: TextStyle(fontSize: 10),
            ),
          ),
        )
        .toList();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Date: ${formatBackendTime(request.date.toString())}',
                  style: TextStyle(fontSize: 10),
                ),
                if (request.completer.isNotEmpty)
                  Text(
                    'Approved Date: ${formatBackendTime(request.approvedDate.toString())}',
                    style: TextStyle(fontSize: 10),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'From: ${request.from}',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text('To: ${request.to}', style: TextStyle(fontSize: 10)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Initiator: ${request.initiator}',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      'Completer: ${request.completer}',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('Products', style: TextStyle(fontSize: 10)),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isExpanded = expanded;
                    });
                    if (expanded && _productsHeight == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_productsKey.currentContext != null) {
                          final height =
                              _productsKey.currentContext!.size!.height;
                          setState(() {
                            _productsHeight = height;
                          });
                        }
                      });
                    }
                  },
                  children: _buildProductsSection(productsTiles),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () {}, child: const Text('Delete')),
                if (request.completer.isEmpty)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      handleApprove(request.id, request.section);
                    },
                    label: Text("Approve"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductsSection(List<Widget> productsTiles) {
    const maxHeight = 300.0;

    if (!_isExpanded) {
      return [];
    }

    if (_productsHeight == null) {
      // Initially render the full column to measure its height. If very tall, it will temporarily expand the card,
      // but will immediately rebuild to the constrained version after measurement.
      return [Column(key: _productsKey, children: productsTiles)];
    } else if (_productsHeight! <= maxHeight) {
      // If content fits within max, render without scroll
      return [Column(children: productsTiles)];
    } else {
      // If content exceeds max, render with scroll and fixed height
      return [
        SizedBox(
          height: maxHeight,
          child: SingleChildScrollView(child: Column(children: productsTiles)),
        ),
      ];
    }
  }
}
