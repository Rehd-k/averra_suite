import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/title_bar.dart';
import '../../service/token.service.dart';

@RoutePage()
class BarNavigationScreen extends StatefulWidget {
  const BarNavigationScreen({super.key});

  @override
  State<BarNavigationScreen> createState() => _BarNavigationScreenState();
}

class _BarNavigationScreenState extends State<BarNavigationScreen> {
  int _selectedIndex = 0;

  // Map bottom navigation bar indices to routes
  final List<PageRouteInfo> _routes = [CartRoute(), DepartmentRequest()];

  // Capitalize first letter of username
  String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return Scaffold(
      appBar: isBigScreen
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                capitalizeFirstLetter(JwtService().decodedToken?['username']),
                style: const TextStyle(fontSize: 12),
              ),
              actions: [
                const CircleAvatar(child: Icon(Icons.person_outlined)),
                const ThemeSwitchButton(),
                IconButton(
                  icon: const Icon(Icons.logout_outlined, size: 12),
                  onPressed: () {
                    JwtService().logout();
                    context.router.replaceAll([LoginRoute()]);
                  },
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_outlined),
            activeIcon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.shopping_cart_checkout),
            label: 'Inventory',
          ),
        ],
      ),
      body: Column(
        children: [
          if (isBigScreen && Platform.isWindows)
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow(child: Text('Logged In'))),
                  const CircleAvatar(child: Icon(Icons.person_outlined)),
                  const ThemeSwitchButton(),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, size: 12),
                    onPressed: () {
                      JwtService().logout();
                      context.router.replaceAll([LoginRoute()]);
                    },
                  ),
                  const WindowButtons(),
                ],
              ),
            ),
          Expanded(
            child: AutoRouter.declarative(
              routes: (_) => [_routes[_selectedIndex]],
            ),
          ),
        ],
      ),
    );
  }
}
