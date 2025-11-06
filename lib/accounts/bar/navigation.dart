import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/financial_string_formart.dart';
import '../../helpers/notificationbar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (Platform.isAndroid || Platform.isIOS)
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                capitalizeFirstLetter(JwtService().decodedToken?['username']),
                style: const TextStyle(fontSize: 12),
              ),
              actions: [
                SlidingNotificationDropdown(),
                const ThemeSwitchButton(),
                IconButton(
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
          if (Platform.isWindows)
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                      child: Row(
                        children: [
                          SizedBox(width: 20),
                          SvgPicture.asset(
                            height: 40,
                            width: 40,
                            'assets/vectors/logo.svg',
                          ),
                          SizedBox(width: 10),
                          Text('Averra Suite'),
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
