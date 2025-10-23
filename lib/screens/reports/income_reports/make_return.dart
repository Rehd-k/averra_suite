import 'package:flutter/material.dart';

import '../../../service/api.service.dart';
import '../../../service/token.service.dart';

class MakeReturn extends StatefulWidget {
  final List<Map<String, dynamic>> sales;
  final String id;
  final Function updatePageInfo;
  final String transactionId;

  const MakeReturn({
    super.key,
    required this.sales,
    required this.id,
    required this.updatePageInfo,
    required this.transactionId,
  });

  @override
  MakeReturnState createState() => MakeReturnState();
}

class MakeReturnState extends State<MakeReturn> {
  ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late int _quantity;
  late Map<String, dynamic> _selectedProduct;
  final List<Map<String, dynamic>> _updatedProducts = [];

  @override
  void initState() {
    super.initState();
    _quantity = 0;
    if (widget.sales.isNotEmpty) {
      _selectedProduct = widget.sales[0];
    }
  }

  void _updateProduct() {
    setState(() {
      final existingProduct = _updatedProducts.firstWhere(
        (product) => product['title'] == _selectedProduct['title'],
        orElse: () => {},
      );
      if (existingProduct.isNotEmpty) {
        existingProduct['quantity'] = _quantity;
      } else {
        _updatedProducts.add({
          'productId': _selectedProduct['productId'],
          'title': _selectedProduct['title'],
          'quantity': _quantity,
          'price': _selectedProduct['price'],
          'total': _selectedProduct['price'] * _quantity,
          'batches': _selectedProduct['breakdown'],
          'from': _selectedProduct['from'],
        });
      }
    });
  }

  void doReturns() async {
    final userRole = JwtService().decodedToken;
    if (userRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (userRole['role'] == 'admin' || userRole['role'] == 'god') {
      // Capture the context before the async gap
      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await apiService.put('sales/return/${widget.id}', {
        'id': widget.id,
        'returns': _updatedProducts,
      });
      widget.updatePageInfo();

      // Check if widget is still mounted before showing message
      if (!mounted) return;

      // Use captured scaffoldMessenger
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Returned Successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Use captured router
      Navigator.of(context).pop();
    } else {
      try {
        await Future.wait(
          _updatedProducts.map((product) async {
            var info = await apiService.post('todo', {
              'title': 'Do Returns',
              'description':
                  'Return "${product['quantity']}" of the ${product['title']}  product for transaction with id ${widget.transactionId}',
              'from': userRole['username'],
              'createdAt': DateTime.now().toString(),
            });
            if (info.statusCode >= 200 && info.statusCode <= 300) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Manager have been notified, Review is being made, Return will be made shorty',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              return;
            } else {
              throw Exception('Failed to create todo: $info');
            }
          }),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create todo. $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
  }

  void _deleteProduct(String productName) {
    setState(() {
      _updatedProducts.removeWhere(
        (product) => product['title'] == productName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Return Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<Map<String, dynamic>>(
              initialValue: _selectedProduct,
              items: widget.sales.map((product) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: product,
                  child: Text(product['title']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value!;
                  _quantity = 0;
                });
              },
              decoration: InputDecoration(labelText: 'Select Product'),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: _selectedProduct['quantity'].toString(),
                      suffix: Text(_selectedProduct['quantity'].toString()),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      final int? quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Please enter a valid quantity';
                      }
                      if (quantity > _selectedProduct['quantity']) {
                        return 'Quantity cannot be more than available product quantity';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _quantity = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: _selectedProduct['price'].toString(),
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _updateProduct();
                        _formKey.currentState!.reset();
                      }
                    },
                    child: Text('Submit Return'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _updatedProducts.length,
                itemBuilder: (context, index) {
                  final product = _updatedProducts[index];
                  return ListTile(
                    title: Text(product['title']),
                    subtitle: Text('Quantity: ${product['quantity']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteProduct(product['title']);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _updatedProducts.isNotEmpty
                ? ElevatedButton(
                    onPressed: () {
                      doReturns();
                    },
                    child: Text(
                      'Return Item${_updatedProducts.length < 2 ? '' : 's'}',
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
