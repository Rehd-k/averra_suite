import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AccountingDashboardScreen extends StatefulWidget {
  const AccountingDashboardScreen({super.key});

  @override
  AccountingDashboardState createState() => AccountingDashboardState();
}

class AccountingDashboardState extends State<AccountingDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Accountant Dashboard'));
  }
}
