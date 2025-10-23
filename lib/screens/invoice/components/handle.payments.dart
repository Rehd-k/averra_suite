import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

import '../../../app_router.gr.dart';

class HandlePayments extends StatefulWidget {
  final double total;
  final List cart;
  final Function handleComplete;
  final Map? selectedBank;
  final Map? selectedUser;
  final num discount;
  final String invoiceId;
  const HandlePayments({
    super.key,
    required this.cart,
    required this.total,
    required this.discount,
    required this.handleComplete,
    required this.invoiceId,
    required this.selectedBank,
    required this.selectedUser,
  });

  @override
  HandlePaymentsState createState() => HandlePaymentsState();
}

class HandlePaymentsState extends State<HandlePayments> {
  double discountPerOne = 0;
  num percentage = 0;
  num totalToPay = 0;
  num indiDiscount = 0;

  @override
  void initState() {
    getDiscountedValue();

    widget.cart.removeWhere(
      (item) => (item['quantity'] - item['quantity_paid']) < 1,
    );
    super.initState();
  }

  void getTotalToPay() {
    num sum = 0;
    num indiDiscounts = 0;
    for (var item in widget.cart) {
      num payment = item['payment'] ?? 0;
      num price = item['price'] ?? 0;
      num discountedPrice = price - (price * percentage);
      item['tempTotal'] = price * payment;
      sum += payment * discountedPrice;

      indiDiscounts += item['indiDiscount'] ?? 0;
    }
    totalToPay = sum;
    indiDiscount = indiDiscounts;
  }

  void getDiscountedValue() {
    if (widget.discount != 0) {
      num? part = widget.discount;
      num? whole = widget.total;
      percentage = (part / whole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Unit Price')),
                DataColumn(
                  label: Text(
                    percentage == 0
                        ? 'Discount'
                        : 'Discount (${percentage * 100}%)',
                  ),
                ),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Payment')),
                DataColumn(label: Text('Amount To Pay')),
              ],
              rows: widget.cart.asMap().entries.map((entry) {
                int index = entry.key;
                Map item = entry.value;

                TextEditingController paymentController = TextEditingController(
                  text: item['payment']?.toString() ?? '',
                );
                num itemPricePercentage = item['price'] * percentage;

                num priceAfterPercentageRemoved =
                    item['price'] - itemPricePercentage;

                num discountedTotal =
                    item['total'] - (item['total'] * percentage);

                num unpaidQunaity = item['quantity'] - item['quantity_paid'];

                // Remove item from cart if unpaidQunaity is 0 or less

                num amountToPay = item['payment'] == null
                    ? 0
                    : item['payment'] * priceAfterPercentageRemoved;

                return DataRow(
                  cells: [
                    DataCell(Text(item['title'].toString())),
                    DataCell(
                      Text(unpaidQunaity.toString().formatToFinancial()),
                    ),
                    DataCell(
                      Text(
                        item['price']?.toString().formatToFinancial(
                              isMoneySymbol: true,
                            ) ??
                            '',
                      ),
                    ),
                    DataCell(
                      Text(
                        itemPricePercentage.toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        (discountedTotal).toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: paymentController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            // Optionally add input formatters for numbers only
                          ],
                          onChanged: (val) {
                            double? entered = double.tryParse(val);
                            double maxAmount = unpaidQunaity.toDouble();

                            if (entered != null && entered > maxAmount) {
                              paymentController.text = maxAmount.toString();
                              paymentController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: paymentController.text.length,
                                    ),
                                  );
                              entered = maxAmount;
                            }
                            setState(() {
                              widget.cart[index]['payment'] = entered ?? 0.0;
                              widget.cart[index]['indiDiscount'] =
                                  itemPricePercentage * entered!;
                              getTotalToPay();
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        (item['payment'] == null ? 0 : amountToPay)
                            .toString()
                            .formatToFinancial(isMoneySymbol: true),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: totalToPay > 0 ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () {
                  // Update all the quantity in widget.cart with the payment value
                  List itemsToRemove = [];
                  for (var item in widget.cart) {
                    if (item['payment'] != null) {
                      item['quantity'] = item['payment'] ?? 0;
                      item['total'] = item['tempTotal'];
                    } else {
                      itemsToRemove.add(item);
                    }
                  }
                  for (var item in itemsToRemove) {
                    widget.cart.remove(item);
                  }

                  totalToPay > 0
                      ? context.router.push(
                          CheckoutRoute(
                            total: (totalToPay + indiDiscount).toDouble(),
                            cart: widget.cart,
                            selectedBank: widget.selectedBank,
                            selectedUser: widget.selectedUser,
                            discount: indiDiscount,
                            invoiceId: widget.invoiceId,
                            handleComplete: widget.handleComplete,
                          ),
                        )
                      : null;
                },
                child: Text(
                  widget.total > 0 ? 'Pay $totalToPay' : 'Invalid Amount',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
