import 'package:flutter/material.dart';
import '../../helpers/financial_string_formart.dart';

Column buildProductInput(
  productController,
  onchange,
  fetchProducts,
  selectProduct,
) {
  return Column(
    children: [
      TextFormField(
        controller: productController,
        decoration: InputDecoration(
          labelText: 'Product',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          onchange();
        },
      ),
      if (productController.text.isNotEmpty)
        FutureBuilder<List<Map>>(
          future: fetchProducts(productController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('No suggestions'),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.map((suggestion) {
                  print(suggestion);
                  dynamic servingQuantity;
                  if (suggestion['servingQuantity'] == 0 ||
                      suggestion['servingQuantity'] == null) {
                    servingQuantity = 1;
                  } else {
                    servingQuantity = suggestion['servingQuantity'];
                  }

                  return ListTile(
                    title: Text(
                      capitalizeFirstLetter(suggestion['title']),
                      style: TextStyle(fontSize: 10),
                    ),
                    subtitle: Row(
                      children: [
                        suggestion['type'] != 'unit'
                            ? Text(
                                '${(suggestion['quantity'] ~/ servingQuantity).toString().formatToFinancial(isMoneySymbol: false)} ${capitalizeFirstLetter(suggestion['type'])}s',
                                style: TextStyle(fontSize: 10),
                              )
                            : SizedBox(),
                        suggestion['type'] != 'unit'
                            ? SizedBox(width: 10)
                            : SizedBox(),
                        suggestion['type'] != 'unit'
                            ? Text(
                                '${(suggestion['quantity'] % suggestion['servingQuantity']).toString().formatToFinancial(isMoneySymbol: false)} Units',
                                style: TextStyle(fontSize: 10),
                              )
                            : Text(
                                '${suggestion['quantity'].toString().formatToFinancial(isMoneySymbol: false)} Units',
                                style: TextStyle(fontSize: 10),
                              ),
                      ],
                    ),
                    trailing: Text(
                      suggestion['sellUnits']
                          ? suggestion['price'].toString().formatToFinancial(
                              isMoneySymbol: true,
                            )
                          : suggestion['servingPrice']
                                .toString()
                                .formatToFinancial(isMoneySymbol: true),
                    ),
                    onTap: () {
                      if (suggestion['sellUnits']) {
                        suggestion['remaining'] = suggestion['quantity'];
                      } else {
                        suggestion['remaining'] =
                            (suggestion['quantity'] ~/
                            suggestion['servingQuantity']);
                        suggestion['price'] = suggestion['servingPrice'];
                      }

                      selectProduct(suggestion);
                    },
                  );
                }).toList(),
              );
            }
          },
        ),
    ],
  );
}
