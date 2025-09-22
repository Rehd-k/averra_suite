import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DashbaordManagerScreen extends StatefulWidget {
  const DashbaordManagerScreen({super.key});

  @override
  DashbaordManagerState createState() => DashbaordManagerState();
}

class DashbaordManagerState extends State<DashbaordManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Manager Dashbaord'));
  }
}
