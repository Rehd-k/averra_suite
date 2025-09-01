import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../app_router.gr.dart';
import '../../components/theme_switch_button.dart';

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

/// The menu data now uses the MenuItem model.
/// I've also corrected the typo in 'Dashboard'.
final List<MenuItem> menuData = [
  MenuItem(
    icon: Icons.inventory_2_outlined,
    title: 'Dashboard',
    link: AdminDashbaord(),
  ),
  MenuItem(
    icon: Icons.supervised_user_circle_outlined,
    title: 'Team',
    link: UserManagementRoute(),
    children: [
      MenuItem(
        icon: Icons.settings,
        title: 'Dashbaord',
        link: StaffDashboard(),
      ),
      MenuItem(
        icon: Icons.settings,
        title: 'Add New',
        link: UserManagementRoute(),
      ),
    ],
  ),
  MenuItem(
    icon: Icons.perm_identity_outlined,
    title: 'Customers',
    link: CustomerRoute(),
  ),
  MenuItem(
    icon: Icons.point_of_sale_outlined,
    title: 'Goods',
    link: ProductsRoute(),
    children: [
      MenuItem(
        icon: Icons.point_of_sale_outlined,
        title: 'Products',
        link: ProductsRoute(),
      ),
      MenuItem(
        icon: Icons.raw_off_outlined,
        title: 'Raw Material',
        link: RawMaterialIndex(),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Category',
        link: CategoryRoute(),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Serving Size',
        link: IndexServingsizeRoute(),
      ),
    ],
  ),

  MenuItem(
    icon: Icons.local_shipping_outlined,
    title: 'Suppliers',
    link: SupplierRoute(),
  ),
  MenuItem(
    icon: Icons.sell_outlined,
    title: 'Make Sell',
    link: MakeSaleRoute(),
  ),
  MenuItem(
    icon: Icons.data_array_outlined,
    title: 'Sells Report',
    link: IncomeReportsRoute(),
  ),
  MenuItem(
    icon:
        Icons.account_balance_wallet_outlined, // Changed to a more fitting icon
    title: 'Banks',
    link: BankRoute(),
  ),
  MenuItem(
    icon: Icons.store_mall_directory_outlined, // Changed to a more fitting icon
    title: 'Department',
    link: DepartmentNavigation(), // This route might be a parent/wrapper
    children: [
      MenuItem(
        icon: Icons.point_of_sale_outlined,
        title: 'Dashboard',
        link: DepartmentDashboard(),
      ),
      MenuItem(
        icon: Icons.perm_identity_outlined,
        title: 'Details',
        link: DepartmentIndex(),
      ),
      MenuItem(
        icon: Icons.local_shipping_outlined,
        title: 'Move Products',
        link: SendProducts(),
      ),
      MenuItem(icon: Icons.list_alt, title: 'Logs', link: DepartmentHistory()),
    ],
  ),
  MenuItem(
    title: 'Invoices',
    icon: Icons.inventory_2_rounded,
    children: [
      MenuItem(icon: Icons.add, title: 'Create Invoices', link: AddInvoice()),
      MenuItem(
        icon: Icons.list_alt,
        title: 'Handle Invoices',
        link: ViewInvoices(),
      ),
    ],
    link: AddInvoice(),
  ),
  MenuItem(icon: Icons.settings, title: 'Settings', link: Settings()),
];

@RoutePage()
class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key});

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
          drawer: isLargeScreen ? null : const Drawer(child: _AdminMenuList()),
          body: Row(
            children: [
              // Show the permanent side menu on large screens
              if (isLargeScreen)
                const SizedBox(
                  width: 190, // A common width for side navigation
                  child: _AdminMenuList(),
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
class _AdminMenuList extends StatefulWidget {
  const _AdminMenuList();

  @override
  __AdminMenuListState createState() => __AdminMenuListState();
}

class __AdminMenuListState extends State<_AdminMenuList> {
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
                  const Text(
                    'Admin Navigation',
                    style: TextStyle(fontSize: 10),
                  ),
                  // On large screens, the ThemeSwitchButton is here because there's no AppBar.
                  if (isLargeScreen) const ThemeSwitchButton(),
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
