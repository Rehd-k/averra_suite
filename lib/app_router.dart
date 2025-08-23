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
        AutoRoute(page: AdminDashbaord.page),
        AutoRoute(page: UserManagementRoute.page),
        AutoRoute(page: LocationIndex.page),
        AutoRoute(page: ProductsRoute.page),
        AutoRoute(page: ProductDashboard.page),
        AutoRoute(page: CategoryRoute.page),
        AutoRoute(page: SupplierRoute.page),
        AutoRoute(page: BankRoute.page),
        AutoRoute(page: ErrorRoute.page),

        AutoRoute(page: CustomerDetails.page),
        AutoRoute(page: MakeSaleRoute.page),
        AutoRoute(page: CheckoutRoute.page),
        AutoRoute(page: PaymentReportsRoute.page),
        AutoRoute(page: IncomeReportsRoute.page),
        AutoRoute(page: Expenses.page),
        AutoRoute(page: AddInvoice.page),
        AutoRoute(page: ViewInvoices.page),
        AutoRoute(page: ChargesRoute.page),
        AutoRoute(page: StoreDashboard.page),
        AutoRoute(page: StoreIndex.page),
        AutoRoute(page: SendProducts.page),
        AutoRoute(page: StoreHistory.page),
        AutoRoute(page: Settings.page),
      ],
    ),
    AutoRoute(
      page: StoreNavigation.page,
      children: [
        AutoRoute(page: StoreDashboard.page),
        AutoRoute(page: StoreIndex.page),
      ],
    ),
  ];
}
