import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/notificationbar.dart';
import '../../helpers/title_bar.dart';
import '../../helpers/webSocket.connect.dart';
import '../../service/token.service.dart';

@RoutePage()
class KitchenNavigationScreen extends StatefulWidget {
  const KitchenNavigationScreen({super.key});

  @override
  State<KitchenNavigationScreen> createState() =>
      _KitchenNavigationScreenState();
}

class _KitchenNavigationScreenState extends State<KitchenNavigationScreen> {
  int _selectedIndex = 0;
  final ws = WebSocketService();

  // Map bottom navigation bar indices to routes
  final List<PageRouteInfo> _routes = [
    CartRoute(),
    DepartmentRequest(),
    Wip(),
    FinishedGoods(),
  ];

  // Capitalize first letter of username
  String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

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
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined),
            activeIcon: Icon(Icons.request_page),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_and_archive_outlined),
            activeIcon: Icon(Icons.send_and_archive),
            label: 'W.I.P',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_outlined),
            activeIcon: Icon(Icons.shopping_cart_checkout),
            label: 'Finished Goods',
          ),
        ],
      ),
      body: Column(
        children: [
          if (Platform.isWindows)
            WindowTitleBarBox(
              child: Container(
                color: Theme.of(context).cardColor,
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
