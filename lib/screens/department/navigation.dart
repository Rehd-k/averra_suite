import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';

@RoutePage()
class DepartmentNavigation extends StatelessWidget {
  const DepartmentNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 1200;
    final isLargeScreen = screenWidth > 1200;
    return Scaffold(
      appBar: AppBar(actions: [ThemeSwitchButton()]),
      drawer: isSmallScreen || isMediumScreen
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                    ),
                    child: Text('Department Navigation'),
                  ),
                  ListTile(
                    title: Text('Dashboard'),
                    onTap: () {
                      context.router.push(DepartmentDashboard());
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          isLargeScreen
              ? Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                        ),
                        child: Text('Admin Navigation'),
                      ),
                      ListTile(
                        title: Text('Dashboard'),
                        onTap: () {
                          context.router.push(DepartmentDashboard());
                        },
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          Expanded(flex: 5, child: SafeArea(child: AutoRouter())),
        ],
      ),
    );
  }
}
