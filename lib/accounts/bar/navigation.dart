import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/financial_string_formart.dart';
import '../../service/token.service.dart';

// import '../../app_router.gr.dart';

/// A type-safe data model for our navigation items.
/// Using a class is better than a Map for readability and error prevention.

@RoutePage()
class BarNavigationScreen extends StatelessWidget {
  const BarNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder is often a better choice for responsive UI that depends
    // on the available space for a specific widget.
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          capitalizeFirstLetter(JwtService().decodedToken?['username']),
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          CircleAvatar(child: Icon(Icons.person_outlined)),
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
      body: AutoRouter(),
    );
  }
}
