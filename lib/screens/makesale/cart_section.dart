import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../helpers/financial_string_formart.dart';

import '../../app_router.gr.dart';

class CartSection extends StatelessWidget {
  final Function saveCart;
  final Function emptyCart;
  final List<Map<String, dynamic>> cart;
  final double cartTotal;
  final Function(String) decrementCartQuantity;
  final Function(String) incrementCartQuantity;
  final Function(String) removeFromCart;
  final Function() handleComplete;
  final bool isSmallScreen;

  const CartSection({
    super.key,
    required this.cart,
    required this.cartTotal,
    required this.decrementCartQuantity,
    required this.incrementCartQuantity,
    required this.removeFromCart,
    required this.saveCart,
    required this.emptyCart,
    required this.handleComplete,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmallScreen) {
      return mainCart(context);
    } else {
      return Expanded(flex: 2, child: mainCart(context));
    }
  }

  doShowToast(String toastMessage, ToastificationType type) {
    toastification.show(
      title: Text(toastMessage),
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  Column mainCart(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                cartTotal < 1
                    ? null
                    : context.router.push(
                        CheckoutRoute(
                          total: cartTotal,
                          cart: cart,
                          handleComplete: handleComplete,
                        ),
                      );
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cartTotal.toString().formatToFinancial(
                        isMoneySymbol: true,
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      'Checkout ${cart.isEmpty ? '' : '(${cart.length})'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (cart.isEmpty) {
                      doShowToast('Nothing To Save', ToastificationType.info);
                    } else {
                      doShowToast('Done', ToastificationType.info);
                      saveCart();
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Save',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        Icon(Icons.save_alt_outlined, size: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Material(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (cart.isNotEmpty) {
                      doShowToast('Done', ToastificationType.success);
                      emptyCart();
                    } else {
                      doShowToast(
                        'No Items In Cart To Clean',
                        ToastificationType.info,
                      );
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Clean Up',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        Icon(
                          Icons.delete_outline_outlined,
                          size: 15,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: Column(
            children: [
              // Header row in a Table
              Table(
                columnWidths: {
                  0: FlexColumnWidth(1), // Name column wider
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Scrollable data rows
              Expanded(
                child: cart.isEmpty
                    ? Center(child: Text('No Selected Products'))
                    : SingleChildScrollView(
                        child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(1), // Name column wider
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: cart
                              .map(
                                (res) => TableRow(
                                  decoration: cart.indexOf(res) % 2 == 1
                                      ? BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceDim,
                                        )
                                      : null,
                                  children: [
                                    // '_id': product['_id'],
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Tooltip(
                                          message: res['title'].toString(),
                                          child: Text(
                                            res['title'].toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          res['price']
                                              .toString()
                                              .formatToFinancial(
                                                isMoneySymbol: true,
                                              ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                size: 16,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 20,
                                              ),
                                              onPressed: () {
                                                decrementCartQuantity(
                                                  res['productId'],
                                                );
                                              },
                                            ),
                                            Text(
                                              res['quantity']
                                                  .toString()
                                                  .formatToFinancial(),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                size: 16,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 20,
                                              ),
                                              onPressed: () {
                                                incrementCartQuantity(
                                                  res['productId'],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              res['total']
                                                  .toString()
                                                  .formatToFinancial(
                                                    isMoneySymbol: true,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close, size: 16),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 20,
                                              ),
                                              onPressed: () {
                                                removeFromCart(
                                                  res['productId'],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
