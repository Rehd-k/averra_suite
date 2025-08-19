import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'add_expneses.dart';
import 'view_expenses.dart';

@RoutePage()
class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  ExpensesState createState() => ExpensesState();
}

class ExpensesState extends State<Expenses> {
  final GlobalKey<ViewExpensesState> viewExpenseKey =
      GlobalKey<ViewExpensesState>();

  void updateExpenses() {
    viewExpenseKey.currentState?.updateExpenseList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          smallScreen
              ? SizedBox.shrink()
              : Expanded(
                  flex: 1,
                  child: AddExpenses(updateExpenses: updateExpenses),
                ),
          SizedBox(width: smallScreen ? 0 : 20),
          Expanded(
            flex: 2,
            child: ViewExpenses(
              key: viewExpenseKey,
              updateExpense: updateExpenses,
            ),
          ),
        ],
      ),
    );
  }
}
