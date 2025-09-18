import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/financial_string_formart.dart';
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
    link: SuperviorNavigationRoute(children: [DashbaordSuperviorRoute()]),
  ),

  MenuItem(
    icon: Icons.local_shipping_outlined,
    title: 'Suppliers',
    link: SuperviorNavigationRoute(children: [SupplierRoute()]),
  ),
  MenuItem(
    icon: Icons.perm_identity_outlined,
    title: 'Customers',
    link: SuperviorNavigationRoute(children: [CustomerRoute()]),
  ),
  MenuItem(
    icon: Icons.data_array_outlined,
    title: 'Sells Report',
    link: SuperviorNavigationRoute(children: [IncomeReportsRoute()]),
  ),
  MenuItem(
    title: 'Expenses',
    icon: Icons.pending_actions,
    link: Expenses(),
    children: [
      MenuItem(
        icon: Icons.dashboard_customize_outlined,
        title: 'Dashbaord',
        link: SuperviorNavigationRoute(children: [ExpensesDashbaord()]),
      ),
      MenuItem(
        icon: Icons.add,
        title: 'Add New',
        link: SuperviorNavigationRoute(children: [AddExpenseRoute()]),
      ),
      MenuItem(
        icon: Icons.category_outlined,
        title: 'Categories',
        link: SuperviorNavigationRoute(children: [CategoriesRoute()]),
      ),
      MenuItem(
        icon: Icons.dashboard_customize_outlined,
        title: 'View Expenses',
        link: SuperviorNavigationRoute(children: [ViewExpenses()]),
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
        link: SuperviorNavigationRoute(children: [ProductsRoute()]),
      ),
      MenuItem(
        icon: Icons.raw_off_outlined,
        title: 'Raw Material',
        link: SuperviorNavigationRoute(children: [RawMaterialIndex()]),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Category',
        link: SuperviorNavigationRoute(children: [CategoryRoute()]),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Serving Size',
        link: SuperviorNavigationRoute(children: [IndexServingsizeRoute()]),
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
        link: SuperviorNavigationRoute(children: [CreateRequisition()]),
      ),
      MenuItem(
        icon: Icons.settings,
        title: 'Show Requisition',
        link: SuperviorNavigationRoute(children: [RequisitionIndex()]),
      ),
      MenuItem(
        title: 'Pending Requisition',
        icon: Icons.pending_actions,
        link: SuperviorNavigationRoute(children: [PendingRequisition()]),
      ),
    ],
  ),
];

@RoutePage()
class SuperviorNavigationScreen extends StatelessWidget {
  const SuperviorNavigationScreen({super.key});

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
                  actions: const [ThemeSwitchButton()],
                ),
          // Use a Drawer for smaller screens
          drawer: isLargeScreen ? null : const Drawer(child: MenuList()),
          body: Row(
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
