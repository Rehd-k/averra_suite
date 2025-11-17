import 'package:flutter/material.dart';

class IncomeReportsHeader extends StatelessWidget {
  final String? selectedField;
  final String? selectedAccount;
  final String? selectedPaymentMethod;
  final bool isSearchEnabled;
  final TextEditingController searchController;
  final Function(String?) onFieldChange;
  final Function(String?) onAccountChange;
  final Function(String?) onPaymentMethodChange;
  final Function(String)? onSearcfieldChange;
  final List cashiers;

  const IncomeReportsHeader({
    super.key,
    required this.selectedField,
    required this.selectedAccount,
    required this.selectedPaymentMethod,
    required this.isSearchEnabled,
    required this.searchController,
    required this.onFieldChange,
    required this.onAccountChange,
    required this.onPaymentMethodChange,
    required this.onSearcfieldChange,
    required this.cashiers,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return Padding(
      padding: EdgeInsets.all(isBigScreen ? 16.0 : 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Field',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'transactionId',
                      child: Text('Tran. Id'),
                    ),
                    DropdownMenuItem(
                      value: 'barcodeId',
                      child: Text('Please Select'),
                    ),
                    DropdownMenuItem(value: 'handler', child: Text('handler')),
                  ],
                  onChanged: onFieldChange,
                  initialValue: selectedField,
                ),

                SizedBox(height: 16.0),
                searchBox(context),
              ],
            ),
          ),
          SizedBox(width: isBigScreen ? 30 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cashier Account',
                    border: OutlineInputBorder(),
                  ),
                  items: cashiers.map<DropdownMenuItem<String>>((cashier) {
                    return DropdownMenuItem<String>(
                      value: cashier.toString(),
                      child: Text(
                        cashier.toString() == '' ? 'All' : cashier.toString(),
                      ),
                    );
                  }).toList(),
                  onChanged: onAccountChange,
                  initialValue: selectedAccount,
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Payment Methods',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfer'),
                    ),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                  ],
                  onChanged: onPaymentMethodChange,
                  initialValue: selectedPaymentMethod,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox searchBox(BuildContext context) {
    // bool smallScreen,
    return SizedBox(
      // height: 30,
      // width: smallScreen ? double.infinity : 250,
      child: TextField(
        enabled: isSearchEnabled,
        style: TextStyle(fontSize: 13),
        cursorHeight: 13,
        controller: searchController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          hintText: "Search...",
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: InkWell(
            child: Icon(Icons.search),
            onTap: () => onSearcfieldChange,
          ),
        ),
        onChanged: onSearcfieldChange,
      ),
    );
  }
}
