// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i25;
import 'package:averra_suite/components/error.dart' as _i10;
import 'package:averra_suite/screens/admin/dashbaord.dart' as _i2;
import 'package:averra_suite/screens/admin/navigation.dart' as _i3;
import 'package:averra_suite/screens/banks/index.dart' as _i4;
import 'package:averra_suite/screens/charges/index.dart' as _i6;
import 'package:averra_suite/screens/customers/dashbaord/index.dart' as _i8;
import 'package:averra_suite/screens/customers/index.dart' as _i9;
import 'package:averra_suite/screens/expenses/index.dart' as _i12;
import 'package:averra_suite/screens/invoice/add_invoice.dart' as _i1;
import 'package:averra_suite/screens/invoice/view_invoices.dart' as _i24;
import 'package:averra_suite/screens/locations/index.dart' as _i14;
import 'package:averra_suite/screens/login/login.dart' as _i15;
import 'package:averra_suite/screens/makesale/checkout.dart' as _i7;
import 'package:averra_suite/screens/makesale/index.dart' as _i16;
import 'package:averra_suite/screens/products/category/index.dart' as _i5;
import 'package:averra_suite/screens/products/index.dart' as _i19;
import 'package:averra_suite/screens/products/product_dashbaord/product_dashboard.dart'
    as _i18;
import 'package:averra_suite/screens/reports/expence_reports/index.dart'
    as _i11;
import 'package:averra_suite/screens/reports/income_reports/index.dart' as _i13;
import 'package:averra_suite/screens/reports/payment_reports/index.dart'
    as _i17;
import 'package:averra_suite/screens/store/dashboard.dart' as _i20;
import 'package:averra_suite/screens/store/navigation.dart' as _i21;
import 'package:averra_suite/screens/supplier/index.dart' as _i22;
import 'package:averra_suite/screens/users/index.dart' as _i23;
import 'package:collection/collection.dart' as _i27;
import 'package:flutter/material.dart' as _i26;

/// generated route for
/// [_i1.AddInvoice]
class AddInvoice extends _i25.PageRouteInfo<void> {
  const AddInvoice({List<_i25.PageRouteInfo>? children})
    : super(AddInvoice.name, initialChildren: children);

  static const String name = 'AddInvoice';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddInvoice();
    },
  );
}

/// generated route for
/// [_i2.AdminDashbaord]
class AdminDashbaord extends _i25.PageRouteInfo<void> {
  const AdminDashbaord({List<_i25.PageRouteInfo>? children})
    : super(AdminDashbaord.name, initialChildren: children);

  static const String name = 'AdminDashbaord';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminDashbaord();
    },
  );
}

/// generated route for
/// [_i3.AdminNavigation]
class AdminNavigation extends _i25.PageRouteInfo<void> {
  const AdminNavigation({List<_i25.PageRouteInfo>? children})
    : super(AdminNavigation.name, initialChildren: children);

  static const String name = 'AdminNavigation';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdminNavigation();
    },
  );
}

/// generated route for
/// [_i4.BankScreen]
class BankRoute extends _i25.PageRouteInfo<void> {
  const BankRoute({List<_i25.PageRouteInfo>? children})
    : super(BankRoute.name, initialChildren: children);

  static const String name = 'BankRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i4.BankScreen();
    },
  );
}

/// generated route for
/// [_i5.CategoryScreen]
class CategoryRoute extends _i25.PageRouteInfo<void> {
  const CategoryRoute({List<_i25.PageRouteInfo>? children})
    : super(CategoryRoute.name, initialChildren: children);

  static const String name = 'CategoryRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i5.CategoryScreen();
    },
  );
}

/// generated route for
/// [_i6.ChargesScreen]
class ChargesRoute extends _i25.PageRouteInfo<void> {
  const ChargesRoute({List<_i25.PageRouteInfo>? children})
    : super(ChargesRoute.name, initialChildren: children);

  static const String name = 'ChargesRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i6.ChargesScreen();
    },
  );
}

/// generated route for
/// [_i7.CheckoutScreen]
class CheckoutRoute extends _i25.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i26.Key? key,
    required double total,
    required List<dynamic> cart,
    required Function handleComplete,
    Map<dynamic, dynamic>? selectedBank,
    Map<dynamic, dynamic>? selectedUser,
    num? discount,
    String? invoiceId,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         CheckoutRoute.name,
         args: CheckoutRouteArgs(
           key: key,
           total: total,
           cart: cart,
           handleComplete: handleComplete,
           selectedBank: selectedBank,
           selectedUser: selectedUser,
           discount: discount,
           invoiceId: invoiceId,
         ),
         initialChildren: children,
       );

  static const String name = 'CheckoutRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckoutRouteArgs>();
      return _i7.CheckoutScreen(
        key: args.key,
        total: args.total,
        cart: args.cart,
        handleComplete: args.handleComplete,
        selectedBank: args.selectedBank,
        selectedUser: args.selectedUser,
        discount: args.discount,
        invoiceId: args.invoiceId,
      );
    },
  );
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.total,
    required this.cart,
    required this.handleComplete,
    this.selectedBank,
    this.selectedUser,
    this.discount,
    this.invoiceId,
  });

  final _i26.Key? key;

  final double total;

  final List<dynamic> cart;

  final Function handleComplete;

  final Map<dynamic, dynamic>? selectedBank;

  final Map<dynamic, dynamic>? selectedUser;

  final num? discount;

  final String? invoiceId;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, total: $total, cart: $cart, handleComplete: $handleComplete, selectedBank: $selectedBank, selectedUser: $selectedUser, discount: $discount, invoiceId: $invoiceId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckoutRouteArgs) return false;
    return key == other.key &&
        total == other.total &&
        const _i27.ListEquality().equals(cart, other.cart) &&
        handleComplete == other.handleComplete &&
        const _i27.MapEquality().equals(selectedBank, other.selectedBank) &&
        const _i27.MapEquality().equals(selectedUser, other.selectedUser) &&
        discount == other.discount &&
        invoiceId == other.invoiceId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      total.hashCode ^
      const _i27.ListEquality().hash(cart) ^
      handleComplete.hashCode ^
      const _i27.MapEquality().hash(selectedBank) ^
      const _i27.MapEquality().hash(selectedUser) ^
      discount.hashCode ^
      invoiceId.hashCode;
}

/// generated route for
/// [_i8.CustomerDetails]
class CustomerDetails extends _i25.PageRouteInfo<CustomerDetailsArgs> {
  CustomerDetails({
    _i26.Key? key,
    required Map<dynamic, dynamic> customer,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         CustomerDetails.name,
         args: CustomerDetailsArgs(key: key, customer: customer),
         initialChildren: children,
       );

  static const String name = 'CustomerDetails';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDetailsArgs>();
      return _i8.CustomerDetails(key: args.key, customer: args.customer);
    },
  );
}

class CustomerDetailsArgs {
  const CustomerDetailsArgs({this.key, required this.customer});

  final _i26.Key? key;

  final Map<dynamic, dynamic> customer;

  @override
  String toString() {
    return 'CustomerDetailsArgs{key: $key, customer: $customer}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerDetailsArgs) return false;
    return key == other.key &&
        const _i27.MapEquality().equals(customer, other.customer);
  }

  @override
  int get hashCode => key.hashCode ^ const _i27.MapEquality().hash(customer);
}

/// generated route for
/// [_i9.CustomerScreen]
class CustomerRoute extends _i25.PageRouteInfo<void> {
  const CustomerRoute({List<_i25.PageRouteInfo>? children})
    : super(CustomerRoute.name, initialChildren: children);

  static const String name = 'CustomerRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i9.CustomerScreen();
    },
  );
}

/// generated route for
/// [_i10.ErrorPage]
class ErrorRoute extends _i25.PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute({
    _i26.Key? key,
    _i26.VoidCallback? onRetry,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ErrorRoute.name,
         args: ErrorRouteArgs(key: key, onRetry: onRetry),
         initialChildren: children,
       );

  static const String name = 'ErrorRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ErrorRouteArgs>(
        orElse: () => const ErrorRouteArgs(),
      );
      return _i10.ErrorPage(key: args.key, onRetry: args.onRetry);
    },
  );
}

class ErrorRouteArgs {
  const ErrorRouteArgs({this.key, this.onRetry});

  final _i26.Key? key;

  final _i26.VoidCallback? onRetry;

  @override
  String toString() {
    return 'ErrorRouteArgs{key: $key, onRetry: $onRetry}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ErrorRouteArgs) return false;
    return key == other.key && onRetry == other.onRetry;
  }

  @override
  int get hashCode => key.hashCode ^ onRetry.hashCode;
}

/// generated route for
/// [_i11.ExpencesReportScreen]
class ExpencesReportRoute extends _i25.PageRouteInfo<void> {
  const ExpencesReportRoute({List<_i25.PageRouteInfo>? children})
    : super(ExpencesReportRoute.name, initialChildren: children);

  static const String name = 'ExpencesReportRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i11.ExpencesReportScreen();
    },
  );
}

/// generated route for
/// [_i12.Expenses]
class Expenses extends _i25.PageRouteInfo<void> {
  const Expenses({List<_i25.PageRouteInfo>? children})
    : super(Expenses.name, initialChildren: children);

  static const String name = 'Expenses';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i12.Expenses();
    },
  );
}

/// generated route for
/// [_i13.IncomeReportsScreen]
class IncomeReportsRoute extends _i25.PageRouteInfo<void> {
  const IncomeReportsRoute({List<_i25.PageRouteInfo>? children})
    : super(IncomeReportsRoute.name, initialChildren: children);

  static const String name = 'IncomeReportsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i13.IncomeReportsScreen();
    },
  );
}

/// generated route for
/// [_i14.LocationIndex]
class LocationIndex extends _i25.PageRouteInfo<void> {
  const LocationIndex({List<_i25.PageRouteInfo>? children})
    : super(LocationIndex.name, initialChildren: children);

  static const String name = 'LocationIndex';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i14.LocationIndex();
    },
  );
}

/// generated route for
/// [_i15.LoginScreen]
class LoginRoute extends _i25.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i26.Key? key,
    dynamic Function()? onResult,
    bool? isGod,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i15.LoginScreen(
        key: args.key,
        onResult: args.onResult,
        isGod: args.isGod,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult, this.isGod});

  final _i26.Key? key;

  final dynamic Function()? onResult;

  final bool? isGod;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onResult: $onResult, isGod: $isGod}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && isGod == other.isGod;
  }

  @override
  int get hashCode => key.hashCode ^ isGod.hashCode;
}

/// generated route for
/// [_i16.MakeSaleScreen]
class MakeSaleRoute extends _i25.PageRouteInfo<MakeSaleRouteArgs> {
  MakeSaleRoute({
    _i26.Key? key,
    dynamic Function()? onResult,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         MakeSaleRoute.name,
         args: MakeSaleRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'MakeSaleRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MakeSaleRouteArgs>(
        orElse: () => const MakeSaleRouteArgs(),
      );
      return _i16.MakeSaleScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class MakeSaleRouteArgs {
  const MakeSaleRouteArgs({this.key, this.onResult});

  final _i26.Key? key;

  final dynamic Function()? onResult;

  @override
  String toString() {
    return 'MakeSaleRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MakeSaleRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i17.PaymentReportsScreen]
class PaymentReportsRoute extends _i25.PageRouteInfo<void> {
  const PaymentReportsRoute({List<_i25.PageRouteInfo>? children})
    : super(PaymentReportsRoute.name, initialChildren: children);

  static const String name = 'PaymentReportsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i17.PaymentReportsScreen();
    },
  );
}

/// generated route for
/// [_i18.ProductDashboard]
class ProductDashboard extends _i25.PageRouteInfo<ProductDashboardArgs> {
  ProductDashboard({
    _i26.Key? key,
    String? productId,
    String? productName,
    required String type,
    required String? cartonAmount,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ProductDashboard.name,
         args: ProductDashboardArgs(
           key: key,
           productId: productId,
           productName: productName,
           type: type,
           cartonAmount: cartonAmount,
         ),
         initialChildren: children,
       );

  static const String name = 'ProductDashboard';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductDashboardArgs>();
      return _i18.ProductDashboard(
        key: args.key,
        productId: args.productId,
        productName: args.productName,
        type: args.type,
        cartonAmount: args.cartonAmount,
      );
    },
  );
}

class ProductDashboardArgs {
  const ProductDashboardArgs({
    this.key,
    this.productId,
    this.productName,
    required this.type,
    required this.cartonAmount,
  });

  final _i26.Key? key;

  final String? productId;

  final String? productName;

  final String type;

  final String? cartonAmount;

  @override
  String toString() {
    return 'ProductDashboardArgs{key: $key, productId: $productId, productName: $productName, type: $type, cartonAmount: $cartonAmount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductDashboardArgs) return false;
    return key == other.key &&
        productId == other.productId &&
        productName == other.productName &&
        type == other.type &&
        cartonAmount == other.cartonAmount;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      type.hashCode ^
      cartonAmount.hashCode;
}

/// generated route for
/// [_i19.ProductsScreen]
class ProductsRoute extends _i25.PageRouteInfo<void> {
  const ProductsRoute({List<_i25.PageRouteInfo>? children})
    : super(ProductsRoute.name, initialChildren: children);

  static const String name = 'ProductsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i19.ProductsScreen();
    },
  );
}

/// generated route for
/// [_i20.StoreDashboard]
class StoreDashboard extends _i25.PageRouteInfo<void> {
  const StoreDashboard({List<_i25.PageRouteInfo>? children})
    : super(StoreDashboard.name, initialChildren: children);

  static const String name = 'StoreDashboard';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i20.StoreDashboard();
    },
  );
}

/// generated route for
/// [_i21.StoreNavigation]
class StoreNavigation extends _i25.PageRouteInfo<void> {
  const StoreNavigation({List<_i25.PageRouteInfo>? children})
    : super(StoreNavigation.name, initialChildren: children);

  static const String name = 'StoreNavigation';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i21.StoreNavigation();
    },
  );
}

/// generated route for
/// [_i22.SupplierScreen]
class SupplierRoute extends _i25.PageRouteInfo<void> {
  const SupplierRoute({List<_i25.PageRouteInfo>? children})
    : super(SupplierRoute.name, initialChildren: children);

  static const String name = 'SupplierRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i22.SupplierScreen();
    },
  );
}

/// generated route for
/// [_i23.UserManagementScreen]
class UserManagementRoute extends _i25.PageRouteInfo<UserManagementRouteArgs> {
  UserManagementRoute({
    _i26.Key? key,
    bool? isGod,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         UserManagementRoute.name,
         args: UserManagementRouteArgs(key: key, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'UserManagementRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserManagementRouteArgs>(
        orElse: () => const UserManagementRouteArgs(),
      );
      return _i23.UserManagementScreen(key: args.key, isGod: args.isGod);
    },
  );
}

class UserManagementRouteArgs {
  const UserManagementRouteArgs({this.key, this.isGod});

  final _i26.Key? key;

  final bool? isGod;

  @override
  String toString() {
    return 'UserManagementRouteArgs{key: $key, isGod: $isGod}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserManagementRouteArgs) return false;
    return key == other.key && isGod == other.isGod;
  }

  @override
  int get hashCode => key.hashCode ^ isGod.hashCode;
}

/// generated route for
/// [_i24.ViewInvoices]
class ViewInvoices extends _i25.PageRouteInfo<ViewInvoicesArgs> {
  ViewInvoices({
    _i26.Key? key,
    String? invoiceId,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ViewInvoices.name,
         args: ViewInvoicesArgs(key: key, invoiceId: invoiceId),
         initialChildren: children,
       );

  static const String name = 'ViewInvoices';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewInvoicesArgs>(
        orElse: () => const ViewInvoicesArgs(),
      );
      return _i24.ViewInvoices(key: args.key, invoiceId: args.invoiceId);
    },
  );
}

class ViewInvoicesArgs {
  const ViewInvoicesArgs({this.key, this.invoiceId});

  final _i26.Key? key;

  final String? invoiceId;

  @override
  String toString() {
    return 'ViewInvoicesArgs{key: $key, invoiceId: $invoiceId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ViewInvoicesArgs) return false;
    return key == other.key && invoiceId == other.invoiceId;
  }

  @override
  int get hashCode => key.hashCode ^ invoiceId.hashCode;
}
