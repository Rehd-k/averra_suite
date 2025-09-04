import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';

class ShowProducts extends StatelessWidget {
  final List products;
  final ScrollController scrollController;
  final List otherCosts;
  final Function handleAddCost;
  final String id;
  const ShowProducts({
    super.key,
    required this.products,
    required this.scrollController,
    required this.otherCosts,
    required this.handleAddCost,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    num productCost = products.fold(
      0,
      (sum, item) => sum + (item['cost'] as num),
    );
    num otherCost = otherCosts.fold(
      0,
      (sum, item) => sum + (item['cost'] as num),
    );
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Products List",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        productCost.toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: products.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        style: TextStyle(fontSize: 10),
                        products[index]['title'],
                      ),
                      subtitle: Text(
                        style: TextStyle(fontSize: 10),
                        products[index]['quantity']
                            .toString()
                            .formatToFinancial(isMoneySymbol: false),
                      ),
                      trailing: Text(
                        style: TextStyle(fontSize: 10),
                        products[index]['cost'].toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Other Cost",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        otherCost.toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: otherCosts.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        style: TextStyle(fontSize: 10),
                        otherCosts[index]['title'],
                      ),
                      subtitle: Text(
                        style: TextStyle(fontSize: 10),
                        otherCosts[index]['quantity']
                            .toString()
                            .formatToFinancial(isMoneySymbol: false),
                      ),
                      trailing: Text(
                        style: TextStyle(fontSize: 10),
                        otherCosts[index]['cost'].toString().formatToFinancial(
                          isMoneySymbol: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
