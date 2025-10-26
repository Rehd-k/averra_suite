import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/financial_string_formart.dart';
import '../../helpers/title_bar.dart';
import '../../service/token.service.dart';

/// A type-safe data model for our navigation items.
/// Using a class is better than a Map for readability and error prevention.
class MenuItem {
  final String title;
  final IconData icon;
  final PageRouteInfo link;
  final List<MenuItem>? children;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.link,
    this.children,
  });
}

final List<MenuItem> menuData = [
  MenuItem(
    icon: Icons.local_shipping_outlined,
    title: 'Dashboard',
    link: ManagerNavigationRoute(children: [DashbaordManagerRoute()]),
  ),
  MenuItem(
    icon: Icons.supervised_user_circle_outlined,
    title: 'Team',
    link: UserManagementRoute(),
    children: [
      MenuItem(
        icon: Icons.settings,
        title: 'Dashbaord',
        link: ManagerNavigationRoute(children: [StaffDashboard()]),
      ),
      MenuItem(
        icon: Icons.settings,
        title: 'Add New',
        link: ManagerNavigationRoute(children: [AddUser()]),
      ),
      MenuItem(
        icon: Icons.settings,
        title: 'View Staff',
        link: ManagerNavigationRoute(children: [ViewUsers()]),
      ),
    ],
  ),

  MenuItem(
    icon: Icons.local_shipping_outlined,
    title: 'Suppliers',
    link: SupplierRoute(),
    children: [
      MenuItem(
        icon: Icons.local_shipping_outlined,
        title: 'Dashboards',
        link: ManagerNavigationRoute(children: [SuppliersDashbaordRoute()]),
      ),
      MenuItem(
        icon: Icons.local_shipping_outlined,
        title: 'Add New',
        link: ManagerNavigationRoute(children: [AddSupplier()]),
      ),
      MenuItem(
        icon: Icons.local_shipping_outlined,
        title: 'View Suppliers',
        link: ManagerNavigationRoute(children: [ViewSuppliersRoute()]),
      ),
    ],
  ),
  MenuItem(
    icon: Icons.perm_identity_outlined,
    title: 'Customers',
    link: ManagerNavigationRoute(children: [CustomerRoute()]),
  ),
  MenuItem(
    icon: Icons.data_array_outlined,
    title: 'Sells Report',
    link: ManagerNavigationRoute(children: [IncomeReportsRoute()]),
  ),
  MenuItem(
    title: 'Expenses',
    icon: Icons.pending_actions,
    link: ManagerNavigationRoute(),
    children: [
      MenuItem(
        icon: Icons.dashboard_customize_outlined,
        title: 'Dashbaord',
        link: ManagerNavigationRoute(children: [ExpensesDashbaord()]),
      ),
      MenuItem(
        icon: Icons.add,
        title: 'Add New',
        link: ManagerNavigationRoute(children: [AddExpenseRoute()]),
      ),
      MenuItem(
        icon: Icons.category_outlined,
        title: 'Categories',
        link: ManagerNavigationRoute(children: [CategoriesRoute()]),
      ),
      MenuItem(
        icon: Icons.dashboard_customize_outlined,
        title: 'View Expenses',
        link: ManagerNavigationRoute(children: [ViewExpenses()]),
      ),
    ],
  ),
  MenuItem(
    icon: Icons.point_of_sale_outlined,
    title: 'Goods',
    link: ProductsRoute(),
    children: [
      MenuItem(
        icon: Icons.point_of_sale_outlined,
        title: 'Products',
        link: ManagerNavigationRoute(children: [ProductsRoute()]),
      ),
      MenuItem(
        icon: Icons.raw_off_outlined,
        title: 'Raw Material',
        link: ManagerNavigationRoute(children: [RawMaterialIndex()]),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Category',
        link: ManagerNavigationRoute(children: [CategoryRoute()]),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Serving Size',
        link: ManagerNavigationRoute(children: [IndexServingsizeRoute()]),
      ),
    ],
  ),
  MenuItem(
    icon: Icons.settings,
    title: 'Requisition',
    link: Settings(),
    children: [
      MenuItem(
        icon: Icons.settings,
        title: 'Create',
        link: ManagerNavigationRoute(children: [CreateRequisition()]),
      ),
      MenuItem(
        icon: Icons.settings,
        title: 'Show Requisition',
        link: ManagerNavigationRoute(children: [RequisitionIndex()]),
      ),
      MenuItem(
        title: 'Pending Requisition',
        icon: Icons.pending_actions,
        link: ManagerNavigationRoute(children: [PendingRequisition()]),
      ),
    ],
  ),
];

@RoutePage()
class ManagerNavigationScreen extends StatelessWidget {
  const ManagerNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder is often a better choice for responsive UI that depends
    // on the available space for a specific widget.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 1200;

        return Scaffold(
          // Only show the AppBar and the hamburger menu icon on smaller screens
          appBar: isLargeScreen
              ? null
              : AppBar(
                  title: const Text(
                    "Admin Panel",
                    style: TextStyle(fontSize: 10),
                  ),
                  actions: [
                    const ThemeSwitchButton(),
                    IconButton(
                      icon: const Icon(Icons.logout_outlined, size: 10),
                      onPressed: () {
                        JwtService().logout();
                        context.router.replaceAll([LoginRoute()]);
                      },
                    ),
                  ],
                ),
          // Use a Drawer for smaller screens
          drawer: isLargeScreen ? null : const Drawer(child: MenuList()),
          body: Column(
            children: [
              if (Platform.isWindows)
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
                child: Row(
                  children: [
                    // Show the permanent side menu on large screens
                    if (isLargeScreen)
                      const SizedBox(
                        width: 190, // A common width for side navigation
                        child: MenuList(),
                      ),
                    // This is the main content area that will be displayed
                    Expanded(child: const SafeArea(child: AutoRouter())),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A private helper widget that builds the menu list.
/// This is stateful to manage the accordion (ExpansionTile) state.
class MenuList extends StatefulWidget {
  const MenuList({super.key});

  @override
  MenuListState createState() => MenuListState();
}

class MenuListState extends State<MenuList> {
  JwtService jwtService = JwtService();
  // This will store the title of the currently expanded menu item
  String? _expandedItemTitle;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: const CircleAvatar(
                      child: Icon(Icons.person_outlined),
                    ),
                  ),
                  // On large screens, the ThemeSwitchButton is here because there's no AppBar.
                  if (isLargeScreen)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ThemeSwitchButton(),
                        IconButton(
                          icon: const Icon(Icons.logout_outlined, size: 10),
                          onPressed: () {
                            jwtService.logout();
                            context.router.replaceAll([LoginRoute()]);
                          },
                        ),
                      ],
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    capitalizeFirstLetter(jwtService.decodedToken?['username']),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Generate the list of menu items dynamically
        ...menuData.map((item) => _buildMenuItem(item)),
      ],
    );
  }

  /// Builds a single menu item.
  /// It returns an ExpansionTile for items with children, or a ListTile otherwise.
  Widget _buildMenuItem(MenuItem item) {
    // Check if the current item has children
    final bool hasChildren = item.children != null && item.children!.isNotEmpty;

    if (hasChildren) {
      final bool isExpanded = _expandedItemTitle == item.title;
      return ExpansionTile(
        key: PageStorageKey(item.title), // Helps preserve scroll state
        leading: Icon(item.icon, size: 8),
        title: Text(item.title, style: TextStyle(fontSize: 10)),
        initiallyExpanded: isExpanded,
        // This callback handles the accordion logic
        // ...existing code...
        onExpansionChanged: (bool expanded) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _expandedItemTitle = expanded ? item.title : null;
              });
            }
          });
        },
        // ...existing code...
        children: item.children!
            .map(
              (child) => ListTile(
                contentPadding: const EdgeInsets.only(
                  left: 48.0,
                ), // Indent sub-items
                leading: Icon(child.icon, size: 10),
                title: Text(child.title, style: TextStyle(fontSize: 10)),
                onTap: () => _handleNavigation(context, child.link),
              ),
            )
            .toList(),
      );
    } else {
      // Build a simple ListTile for items without children
      return ListTile(
        leading: Icon(item.icon, size: 10),
        title: Text(item.title, style: TextStyle(fontSize: 10)),
        onTap: () => _handleNavigation(context, item.link),
      );
    }
  }

  /// Centralized navigation logic.
  void _handleNavigation(BuildContext context, PageRouteInfo route) {
    context.router.push(route);
    // If the menu is inside a drawer, close it after tapping an item.
    if (Scaffold.of(context).hasDrawer) {
      Navigator.of(context).pop();
    }
  }
}
