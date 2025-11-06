import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/notificationbar.dart';
import '../../helpers/title_bar.dart';
import '../../service/token.service.dart';

@RoutePage()
class WaiterNavigationScreen extends StatefulWidget {
  const WaiterNavigationScreen({super.key});

  @override
  State<WaiterNavigationScreen> createState() => _WaiterNavigationScreenState();
}

class _WaiterNavigationScreenState extends State<WaiterNavigationScreen> {
  int _selectedIndex = 0;

  final List<PageRouteInfo> _routes = [
    MakeSaleRoute(),
    CustomerRoute(),
    IncomeReportsRoute(),
  ];

  final _innerRouterKey = GlobalKey<AutoRouterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (Platform.isAndroid || Platform.isIOS)
          ? AppBar(
              title: const Text("Waiter", style: TextStyle(fontSize: 10)),
              actions: [
                SlidingNotificationDropdown(),
                const ThemeSwitchButton(),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout_outlined, size: 12),
                  onPressed: () {
                    JwtService().logout();
                    context.router.replaceAll([LoginRoute()]);
                  },
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            setState(() => _selectedIndex = index);
            _innerRouterKey.currentState!.controller!.replaceAll([
              _routes[index],
            ]);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sell_outlined),
            activeIcon: Icon(Icons.sell),
            label: 'Make Sale',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity_outlined),
            activeIcon: Icon(Icons.perm_identity),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_array_outlined),
            activeIcon: Icon(Icons.data_array),
            label: 'Sales Report',
          ),
        ],
      ),
      body: Column(
        children: [
          if (Platform.isWindows)
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          SvgPicture.asset(
                            'assets/vectors/logo.svg',
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(width: 10),
                          const Text('Averra Suite'),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      SlidingNotificationDropdown(),
                      const ThemeSwitchButton(),
                      InkWell(
                        child: const Icon(Icons.logout_outlined, size: 12),
                        onTap: () {
                          JwtService().logout();
                          context.router.replaceAll([LoginRoute()]);
                        },
                      ),
                      const WindowButtons(),
                    ],
                  ),
                ],
              ),
            ),
          // ✅ Imperative router (not declarative)
          Expanded(child: AutoRouter(key: _innerRouterKey)),
        ],
      ),
    );
  }
}
