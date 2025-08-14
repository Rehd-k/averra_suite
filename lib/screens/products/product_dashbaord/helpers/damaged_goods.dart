import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<void> showDamagedGoodsForm(
    BuildContext context, handleDamagedGoods, id, num goodRemaining) async {
  DateTime selectedDate = DateTime.now();
  final quantityController = TextEditingController();
  final reasonController = TextEditingController();

  showMaterialModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Register Damaged Goods',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('(Total Remaining -  ${goodRemaining.toString()})')
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (quantityController.text.isNotEmpty) {
                final enteredQuantity = int.parse(quantityController.text);
                if (enteredQuantity > goodRemaining) {
                  quantityController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Quantity cannot exceed remaining goods ($goodRemaining)'),
                    ),
                  );
                }
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  if (quantityController.text.isNotEmpty &&
                      reasonController.text.isNotEmpty) {
                    await handleDamagedGoods({
                      "_id": id,
                      'quantity': int.parse(quantityController.text),
                      'reason': reasonController.text,
                      'date': selectedDate.toString().split(' ')[0],
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
