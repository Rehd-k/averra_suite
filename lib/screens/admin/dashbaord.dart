import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../components/cards_layout.dart';

@RoutePage()
class AdminDashbaord extends StatefulWidget {
  const AdminDashbaord({super.key});

  @override
  DashbaordState createState() => DashbaordState();
}

class DashbaordState extends State<AdminDashbaord> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [ResponsiveCardGrid()],
      ),
    );
  }
}
