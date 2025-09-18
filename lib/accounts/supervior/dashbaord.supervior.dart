import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DashbaordSuperviorScreen extends StatefulWidget {
  const DashbaordSuperviorScreen({super.key});

  @override
  DashbaordSuperviorState createState() => DashbaordSuperviorState();
}

class DashbaordSuperviorState extends State<DashbaordSuperviorScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Supervisor Dashbaord'));
  }
}
