import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, keepHistory: false, initial: true),
    AutoRoute(
      path: '/',
      page: AdminNavigation.page,
      children: [
        AutoRoute(
          path: 'dashboard',
          page: AdminDashbaord.page,
          // guards: [LogedinGuard()],
        ),
        AutoRoute(path: 'users', page: UserManagementRoute.page),
        AutoRoute(path: 'location', page: LocationIndex.page),
        AutoRoute(path: 'products', page: ProductsRoute.page),
        AutoRoute(page: ProductDashboard.page, path: 'product-dashboard'),
        AutoRoute(path: 'categories', page: CategoryRoute.page),
        AutoRoute(path: 'suppliers', page: SupplierRoute.page),
      ],
    ),
    // guards: [LoginGaurd()]),
  ];
}
