import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../components/finance_card.dart';

@RoutePage()
class DepartmentDashboard extends StatefulWidget {
  const DepartmentDashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DepartmentDashboard> {
  @override
  Widget build(BuildContext context) {
    final isBigScreen = MediaQuery.of(context).size.width > 1200;
    return SingleChildScrollView(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 400, maxHeight: 900),
            child: GridView.count(
              physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
              primary: true,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              crossAxisCount: isBigScreen ? 3 : 2,
              childAspectRatio: 3,
              children: [
                FinanceCard(
                  fontSize: isBigScreen ? 10 : 5,
                  isFinancial: false,
                  amount: 58,
                  title: 'Total Stock Count',
                  icon: Icon(Icons.money),
                ),
                FinanceCard(
                  fontSize: isBigScreen ? 10 : 5,
                  isFinancial: true,
                  amount: 500970,
                  title: 'Total Stock Value',
                  icon: Icon(Icons.money),
                ),
                FinanceCard(
                  fontSize: isBigScreen ? 10 : 5,
                  isFinancial: true,
                  amount: 500970,
                  title: 'Total Stock Value',
                  icon: Icon(Icons.money),
                ),

                FinanceCard(
                  fontSize: isBigScreen ? 10 : 5,
                  isFinancial: true,
                  amount: 500970,
                  title: 'Total Stock Value',
                  icon: Icon(Icons.money),
                ),

                FinanceCard(
                  fontSize: isBigScreen ? 10 : 5,
                  isFinancial: true,
                  amount: 500970,
                  title: 'Total Stock Value',
                  icon: Icon(Icons.money),
                ),

                FinanceCard(
                  fontSize: isBigScreen ? 10 : 5,
                  isFinancial: true,
                  amount: 500970,
                  title: 'Total Stock Value',
                  icon: Icon(Icons.money),
                ),
              ],
            ),
          ),

          SizedBox(width: 10),
        ],
      ),
    );
  }
}
