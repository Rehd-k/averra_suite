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
                  dynamic cartonAmout;
                  if (suggestion['servingSize'] == 0 ||
                      suggestion['servingSize'] == null) {
                    cartonAmout = 1;
                  } else {
                    cartonAmout = suggestion['servingSize'];
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
                                '${(suggestion['quantity'] ~/ cartonAmout).toString().formatToFinancial(isMoneySymbol: false)} ${capitalizeFirstLetter(suggestion['type'])}s',
                                style: TextStyle(fontSize: 10),
                              )
                            : SizedBox(),
                        suggestion['type'] != 'unit'
                            ? SizedBox(width: 10)
                            : SizedBox(),
                        suggestion['type'] != 'unit'
                            ? Text(
                                '${(suggestion['quantity'] % suggestion['servingSize']).toString().formatToFinancial(isMoneySymbol: false)} Units',
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
                            suggestion['servingSize']);
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
