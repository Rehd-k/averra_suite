import 'package:flutter/material.dart';
import '../../helpers/financial_string_formart.dart';

Column buildProductInput(
    productController, onchange, fetchProducts, selectProduct) {
  return Column(
    children: [
      TextFormField(
        controller: productController,
        decoration: InputDecoration(
          labelText: 'Product',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                  child: Text('Error: ${snapshot.error}'));
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
                  if (suggestion['cartonAmount'] == 0 ||
                      suggestion['cartonAmount'] == null) {
                    cartonAmout = 1;
                  } else {
                    cartonAmout = suggestion['cartonAmount'];
                  }

                  return ListTile(
                    title: Text(suggestion['title']),
                    subtitle: Row(children: [
                      suggestion['type'] == 'carton'
                          ? Text(
                              '${(suggestion['quantity'] ~/ cartonAmout).toString().formatToFinancial(isMoneySymbol: false)} Cartons',
                            )
                          : SizedBox(),
                      suggestion['type'] == 'carton'
                          ? SizedBox(width: 10)
                          : SizedBox(),
                      suggestion['type'] == 'carton'
                          ? Text(
                              '${(suggestion['quantity'] % suggestion['cartonAmount']).toString().formatToFinancial(isMoneySymbol: false)} Units')
                          : Text(
                              '${suggestion['quantity'].toString().formatToFinancial(isMoneySymbol: false)} Units'),
                    ]),
                    trailing: Text(suggestion['price']
                        .toString()
                        .formatToFinancial(isMoneySymbol: true)),
                    onTap: () {
                      suggestion['remaining'] = suggestion['quantity'];

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
