import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  StaffDashboardState createState() => StaffDashboardState();
}

class StaffDashboardState extends State<StaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Container());
  }
}
