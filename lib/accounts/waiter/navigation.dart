import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
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

  // Map bottom navigation bar indices to routes
  final List<PageRouteInfo> _routes = [
    MakeSaleRoute(),
    CustomerRoute(),
    IncomeReportsRoute(),
  ];
  @override
  Widget build(BuildContext context) {
    // LayoutBuilder is often a better choice for responsive UI that depends
    // on the available space for a specific widget.

    return Scaffold(
      // Only show the AppBar and the hamburger menu icon on smaller screens
      appBar: (Platform.isAndroid || Platform.isIOS)
          ? AppBar(
              title: const Text("Admin Panel", style: TextStyle(fontSize: 10)),

              actions: [
                CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.person_outlined),
                    onPressed: () async {
                      JwtService jwtService = JwtService();
                      ApiService apiService = ApiService();
                      await apiService.get(
                        'notification/test/${jwtService.decodedToken?['sub']}/this_title/testingnotification',
                      );
                    },
                  ),
                ),
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
            setState(() {
              _selectedIndex = index;
            });
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
