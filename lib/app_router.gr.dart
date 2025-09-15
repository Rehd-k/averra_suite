// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i43;
import 'package:averra_suite/components/error.dart' as _i18;
import 'package:averra_suite/screens/admin/dashbaord.dart' as _i3;
import 'package:averra_suite/screens/admin/navigation.dart' as _i4;
import 'package:averra_suite/screens/admin/settings.dart' as _i36;
import 'package:averra_suite/screens/banks/index.dart' as _i5;
import 'package:averra_suite/screens/charges/index.dart' as _i8;
import 'package:averra_suite/screens/customers/dashbaord/index.dart' as _i11;
import 'package:averra_suite/screens/customers/index.dart' as _i12;
import 'package:averra_suite/screens/department/dashboard.dart' as _i13;
import 'package:averra_suite/screens/department/department.history.dart'
    as _i14;
import 'package:averra_suite/screens/department/department.request.dart'
    as _i17;
import 'package:averra_suite/screens/department/department/index.dart' as _i15;
import 'package:averra_suite/screens/department/navigation.dart' as _i16;
import 'package:averra_suite/screens/department/send.products.dart' as _i35;
import 'package:averra_suite/screens/expenses/add_expneses.dart' as _i1;
import 'package:averra_suite/screens/expenses/categories.dart' as _i6;
import 'package:averra_suite/screens/expenses/expenses.dashbaord.dart' as _i21;
import 'package:averra_suite/screens/expenses/index.dart' as _i20;
import 'package:averra_suite/screens/expenses/view_expenses.dart' as _i40;
import 'package:averra_suite/screens/invoice/add_invoice.dart' as _i2;
import 'package:averra_suite/screens/invoice/view_invoices.dart' as _i41;
import 'package:averra_suite/screens/locations/index.dart' as _i25;
import 'package:averra_suite/screens/login/login.dart' as _i26;
import 'package:averra_suite/screens/makesale/checkout.dart' as _i9;
import 'package:averra_suite/screens/makesale/index.dart' as _i27;
import 'package:averra_suite/screens/products/category/index.dart' as _i7;
import 'package:averra_suite/screens/products/index.dart' as _i31;
import 'package:averra_suite/screens/products/product_dashbaord/product_dashboard.dart'
    as _i30;
import 'package:averra_suite/screens/rawmaterial/rawmaterial.index.dart'
    as _i33;
import 'package:averra_suite/screens/rawmaterial/rawmaterial_dashbaord/rawmaterial_dashboard.dart'
    as _i32;
import 'package:averra_suite/screens/reports/expence_reports/index.dart'
    as _i19;
import 'package:averra_suite/screens/reports/income_reports/index.dart' as _i23;
import 'package:averra_suite/screens/reports/payment_reports/index.dart'
    as _i28;
import 'package:averra_suite/screens/requisition/create.requisition.dart'
    as _i10;
import 'package:averra_suite/screens/requisition/pending.requisition.dart'
    as _i29;
import 'package:averra_suite/screens/requisition/requisition.index.dart'
    as _i34;
import 'package:averra_suite/screens/searving/index.servingsize.dart' as _i24;
import 'package:averra_suite/screens/supplier/index.dart' as _i38;
import 'package:averra_suite/screens/users/index.dart' as _i39;
import 'package:averra_suite/screens/users/staffdetails/staff.dashboard.dart'
    as _i37;
import 'package:averra_suite/screens/worInProgress/finished_goods.dart' as _i22;
import 'package:averra_suite/screens/worInProgress/wip.dart' as _i42;
import 'package:collection/collection.dart' as _i45;
import 'package:flutter/material.dart' as _i44;

/// generated route for
/// [_i1.AddExpenseScreen]
class AddExpenseRoute extends _i43.PageRouteInfo<AddExpenseRouteArgs> {
  AddExpenseRoute({
    _i44.Key? key,
    Map<dynamic, dynamic>? updateInfo,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         AddExpenseRoute.name,
         args: AddExpenseRouteArgs(key: key, updateInfo: updateInfo),
         initialChildren: children,
       );

  static const String name = 'AddExpenseRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddExpenseRouteArgs>(
        orElse: () => const AddExpenseRouteArgs(),
      );
      return _i1.AddExpenseScreen(key: args.key, updateInfo: args.updateInfo);
    },
  );
}

class AddExpenseRouteArgs {
  const AddExpenseRouteArgs({this.key, this.updateInfo});

  final _i44.Key? key;

  final Map<dynamic, dynamic>? updateInfo;

  @override
  String toString() {
    return 'AddExpenseRouteArgs{key: $key, updateInfo: $updateInfo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddExpenseRouteArgs) return false;
    return key == other.key &&
        const _i45.MapEquality().equals(updateInfo, other.updateInfo);
  }

  @override
  int get hashCode => key.hashCode ^ const _i45.MapEquality().hash(updateInfo);
}

/// generated route for
/// [_i2.AddInvoice]
class AddInvoice extends _i43.PageRouteInfo<void> {
  const AddInvoice({List<_i43.PageRouteInfo>? children})
    : super(AddInvoice.name, initialChildren: children);

  static const String name = 'AddInvoice';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i2.AddInvoice();
    },
  );
}

/// generated route for
/// [_i3.AdminDashbaord]
class AdminDashbaord extends _i43.PageRouteInfo<void> {
  const AdminDashbaord({List<_i43.PageRouteInfo>? children})
    : super(AdminDashbaord.name, initialChildren: children);

  static const String name = 'AdminDashbaord';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdminDashbaord();
    },
  );
}

/// generated route for
/// [_i4.AdminNavigation]
class AdminNavigation extends _i43.PageRouteInfo<void> {
  const AdminNavigation({List<_i43.PageRouteInfo>? children})
    : super(AdminNavigation.name, initialChildren: children);

  static const String name = 'AdminNavigation';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i4.AdminNavigation();
    },
  );
}

/// generated route for
/// [_i5.BankScreen]
class BankRoute extends _i43.PageRouteInfo<void> {
  const BankRoute({List<_i43.PageRouteInfo>? children})
    : super(BankRoute.name, initialChildren: children);

  static const String name = 'BankRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i5.BankScreen();
    },
  );
}

/// generated route for
/// [_i6.CategoriesScreen]
class CategoriesRoute extends _i43.PageRouteInfo<void> {
  const CategoriesRoute({List<_i43.PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i6.CategoriesScreen();
    },
  );
}

/// generated route for
/// [_i7.CategoryScreen]
class CategoryRoute extends _i43.PageRouteInfo<void> {
  const CategoryRoute({List<_i43.PageRouteInfo>? children})
    : super(CategoryRoute.name, initialChildren: children);

  static const String name = 'CategoryRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i7.CategoryScreen();
    },
  );
}

/// generated route for
/// [_i8.ChargesScreen]
class ChargesRoute extends _i43.PageRouteInfo<void> {
  const ChargesRoute({List<_i43.PageRouteInfo>? children})
    : super(ChargesRoute.name, initialChildren: children);

  static const String name = 'ChargesRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i8.ChargesScreen();
    },
  );
}

/// generated route for
/// [_i9.CheckoutScreen]
class CheckoutRoute extends _i43.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i44.Key? key,
    required double total,
    required List<dynamic> cart,
    required Function handleComplete,
    Map<dynamic, dynamic>? selectedBank,
    Map<dynamic, dynamic>? selectedUser,
    num? discount,
    String? invoiceId,
    List<_i43.PageRouteInfo>? children,
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

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckoutRouteArgs>();
      return _i9.CheckoutScreen(
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

  final _i44.Key? key;

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
        const _i45.ListEquality().equals(cart, other.cart) &&
        handleComplete == other.handleComplete &&
        const _i45.MapEquality().equals(selectedBank, other.selectedBank) &&
        const _i45.MapEquality().equals(selectedUser, other.selectedUser) &&
        discount == other.discount &&
        invoiceId == other.invoiceId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      total.hashCode ^
      const _i45.ListEquality().hash(cart) ^
      handleComplete.hashCode ^
      const _i45.MapEquality().hash(selectedBank) ^
      const _i45.MapEquality().hash(selectedUser) ^
      discount.hashCode ^
      invoiceId.hashCode;
}

/// generated route for
/// [_i10.CreateRequisition]
class CreateRequisition extends _i43.PageRouteInfo<void> {
  const CreateRequisition({List<_i43.PageRouteInfo>? children})
    : super(CreateRequisition.name, initialChildren: children);

  static const String name = 'CreateRequisition';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i10.CreateRequisition();
    },
  );
}

/// generated route for
/// [_i11.CustomerDetails]
class CustomerDetails extends _i43.PageRouteInfo<CustomerDetailsArgs> {
  CustomerDetails({
    _i44.Key? key,
    required Map<dynamic, dynamic> customer,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         CustomerDetails.name,
         args: CustomerDetailsArgs(key: key, customer: customer),
         initialChildren: children,
       );

  static const String name = 'CustomerDetails';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDetailsArgs>();
      return _i11.CustomerDetails(key: args.key, customer: args.customer);
    },
  );
}

class CustomerDetailsArgs {
  const CustomerDetailsArgs({this.key, required this.customer});

  final _i44.Key? key;

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
        const _i45.MapEquality().equals(customer, other.customer);
  }

  @override
  int get hashCode => key.hashCode ^ const _i45.MapEquality().hash(customer);
}

/// generated route for
/// [_i12.CustomerScreen]
class CustomerRoute extends _i43.PageRouteInfo<void> {
  const CustomerRoute({List<_i43.PageRouteInfo>? children})
    : super(CustomerRoute.name, initialChildren: children);

  static const String name = 'CustomerRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i12.CustomerScreen();
    },
  );
}

/// generated route for
/// [_i13.DepartmentDashboard]
class DepartmentDashboard extends _i43.PageRouteInfo<void> {
  const DepartmentDashboard({List<_i43.PageRouteInfo>? children})
    : super(DepartmentDashboard.name, initialChildren: children);

  static const String name = 'DepartmentDashboard';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i13.DepartmentDashboard();
    },
  );
}

/// generated route for
/// [_i14.DepartmentHistory]
class DepartmentHistory extends _i43.PageRouteInfo<void> {
  const DepartmentHistory({List<_i43.PageRouteInfo>? children})
    : super(DepartmentHistory.name, initialChildren: children);

  static const String name = 'DepartmentHistory';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i14.DepartmentHistory();
    },
  );
}

/// generated route for
/// [_i15.DepartmentIndex]
class DepartmentIndex extends _i43.PageRouteInfo<void> {
  const DepartmentIndex({List<_i43.PageRouteInfo>? children})
    : super(DepartmentIndex.name, initialChildren: children);

  static const String name = 'DepartmentIndex';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i15.DepartmentIndex();
    },
  );
}

/// generated route for
/// [_i16.DepartmentNavigation]
class DepartmentNavigation extends _i43.PageRouteInfo<void> {
  const DepartmentNavigation({List<_i43.PageRouteInfo>? children})
    : super(DepartmentNavigation.name, initialChildren: children);

  static const String name = 'DepartmentNavigation';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i16.DepartmentNavigation();
    },
  );
}

/// generated route for
/// [_i17.DepartmentRequest]
class DepartmentRequest extends _i43.PageRouteInfo<void> {
  const DepartmentRequest({List<_i43.PageRouteInfo>? children})
    : super(DepartmentRequest.name, initialChildren: children);

  static const String name = 'DepartmentRequest';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i17.DepartmentRequest();
    },
  );
}

/// generated route for
/// [_i18.ErrorPage]
class ErrorRoute extends _i43.PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute({
    _i44.Key? key,
    _i44.VoidCallback? onRetry,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         ErrorRoute.name,
         args: ErrorRouteArgs(key: key, onRetry: onRetry),
         initialChildren: children,
       );

  static const String name = 'ErrorRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ErrorRouteArgs>(
        orElse: () => const ErrorRouteArgs(),
      );
      return _i18.ErrorPage(key: args.key, onRetry: args.onRetry);
    },
  );
}

class ErrorRouteArgs {
  const ErrorRouteArgs({this.key, this.onRetry});

  final _i44.Key? key;

  final _i44.VoidCallback? onRetry;

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
/// [_i19.ExpencesReportScreen]
class ExpencesReportRoute extends _i43.PageRouteInfo<void> {
  const ExpencesReportRoute({List<_i43.PageRouteInfo>? children})
    : super(ExpencesReportRoute.name, initialChildren: children);

  static const String name = 'ExpencesReportRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i19.ExpencesReportScreen();
    },
  );
}

/// generated route for
/// [_i20.Expenses]
class Expenses extends _i43.PageRouteInfo<void> {
  const Expenses({List<_i43.PageRouteInfo>? children})
    : super(Expenses.name, initialChildren: children);

  static const String name = 'Expenses';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i20.Expenses();
    },
  );
}

/// generated route for
/// [_i21.ExpensesDashbaord]
class ExpensesDashbaord extends _i43.PageRouteInfo<void> {
  const ExpensesDashbaord({List<_i43.PageRouteInfo>? children})
    : super(ExpensesDashbaord.name, initialChildren: children);

  static const String name = 'ExpensesDashbaord';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i21.ExpensesDashbaord();
    },
  );
}

/// generated route for
/// [_i22.FinishedGoods]
class FinishedGoods extends _i43.PageRouteInfo<void> {
  const FinishedGoods({List<_i43.PageRouteInfo>? children})
    : super(FinishedGoods.name, initialChildren: children);

  static const String name = 'FinishedGoods';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i22.FinishedGoods();
    },
  );
}

/// generated route for
/// [_i23.IncomeReportsScreen]
class IncomeReportsRoute extends _i43.PageRouteInfo<void> {
  const IncomeReportsRoute({List<_i43.PageRouteInfo>? children})
    : super(IncomeReportsRoute.name, initialChildren: children);

  static const String name = 'IncomeReportsRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i23.IncomeReportsScreen();
    },
  );
}

/// generated route for
/// [_i24.IndexServingsizeScreen]
class IndexServingsizeRoute extends _i43.PageRouteInfo<void> {
  const IndexServingsizeRoute({List<_i43.PageRouteInfo>? children})
    : super(IndexServingsizeRoute.name, initialChildren: children);

  static const String name = 'IndexServingsizeRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i24.IndexServingsizeScreen();
    },
  );
}

/// generated route for
/// [_i25.LocationIndex]
class LocationIndex extends _i43.PageRouteInfo<void> {
  const LocationIndex({List<_i43.PageRouteInfo>? children})
    : super(LocationIndex.name, initialChildren: children);

  static const String name = 'LocationIndex';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i25.LocationIndex();
    },
  );
}

/// generated route for
/// [_i26.LoginScreen]
class LoginRoute extends _i43.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i44.Key? key,
    dynamic Function()? onResult,
    bool? isGod,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i26.LoginScreen(
        key: args.key,
        onResult: args.onResult,
        isGod: args.isGod,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult, this.isGod});

  final _i44.Key? key;

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
/// [_i27.MakeSaleScreen]
class MakeSaleRoute extends _i43.PageRouteInfo<MakeSaleRouteArgs> {
  MakeSaleRoute({
    _i44.Key? key,
    dynamic Function()? onResult,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         MakeSaleRoute.name,
         args: MakeSaleRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'MakeSaleRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MakeSaleRouteArgs>(
        orElse: () => const MakeSaleRouteArgs(),
      );
      return _i27.MakeSaleScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class MakeSaleRouteArgs {
  const MakeSaleRouteArgs({this.key, this.onResult});

  final _i44.Key? key;

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
/// [_i28.PaymentReportsScreen]
class PaymentReportsRoute extends _i43.PageRouteInfo<void> {
  const PaymentReportsRoute({List<_i43.PageRouteInfo>? children})
    : super(PaymentReportsRoute.name, initialChildren: children);

  static const String name = 'PaymentReportsRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i28.PaymentReportsScreen();
    },
  );
}

/// generated route for
/// [_i29.PendingRequisition]
class PendingRequisition extends _i43.PageRouteInfo<void> {
  const PendingRequisition({List<_i43.PageRouteInfo>? children})
    : super(PendingRequisition.name, initialChildren: children);

  static const String name = 'PendingRequisition';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i29.PendingRequisition();
    },
  );
}

/// generated route for
/// [_i30.ProductDashboard]
class ProductDashboard extends _i43.PageRouteInfo<ProductDashboardArgs> {
  ProductDashboard({
    _i44.Key? key,
    String? productId,
    String? productName,
    required String type,
    required String? servingQuantity,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         ProductDashboard.name,
         args: ProductDashboardArgs(
           key: key,
           productId: productId,
           productName: productName,
           type: type,
           servingQuantity: servingQuantity,
         ),
         initialChildren: children,
       );

  static const String name = 'ProductDashboard';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductDashboardArgs>();
      return _i30.ProductDashboard(
        key: args.key,
        productId: args.productId,
        productName: args.productName,
        type: args.type,
        servingQuantity: args.servingQuantity,
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
    required this.servingQuantity,
  });

  final _i44.Key? key;

  final String? productId;

  final String? productName;

  final String type;

  final String? servingQuantity;

  @override
  String toString() {
    return 'ProductDashboardArgs{key: $key, productId: $productId, productName: $productName, type: $type, servingQuantity: $servingQuantity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductDashboardArgs) return false;
    return key == other.key &&
        productId == other.productId &&
        productName == other.productName &&
        type == other.type &&
        servingQuantity == other.servingQuantity;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      type.hashCode ^
      servingQuantity.hashCode;
}

/// generated route for
/// [_i31.ProductsScreen]
class ProductsRoute extends _i43.PageRouteInfo<void> {
  const ProductsRoute({List<_i43.PageRouteInfo>? children})
    : super(ProductsRoute.name, initialChildren: children);

  static const String name = 'ProductsRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i31.ProductsScreen();
    },
  );
}

/// generated route for
/// [_i32.RawMaterialDashboard]
class RawMaterialDashboard
    extends _i43.PageRouteInfo<RawMaterialDashboardArgs> {
  RawMaterialDashboard({
    _i44.Key? key,
    required String rawmaterialId,
    required String rawmaterialName,
    required num servingSize,
    required String unit,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         RawMaterialDashboard.name,
         args: RawMaterialDashboardArgs(
           key: key,
           rawmaterialId: rawmaterialId,
           rawmaterialName: rawmaterialName,
           servingSize: servingSize,
           unit: unit,
         ),
         initialChildren: children,
       );

  static const String name = 'RawMaterialDashboard';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RawMaterialDashboardArgs>();
      return _i32.RawMaterialDashboard(
        key: args.key,
        rawmaterialId: args.rawmaterialId,
        rawmaterialName: args.rawmaterialName,
        servingSize: args.servingSize,
        unit: args.unit,
      );
    },
  );
}

class RawMaterialDashboardArgs {
  const RawMaterialDashboardArgs({
    this.key,
    required this.rawmaterialId,
    required this.rawmaterialName,
    required this.servingSize,
    required this.unit,
  });

  final _i44.Key? key;

  final String rawmaterialId;

  final String rawmaterialName;

  final num servingSize;

  final String unit;

  @override
  String toString() {
    return 'RawMaterialDashboardArgs{key: $key, rawmaterialId: $rawmaterialId, rawmaterialName: $rawmaterialName, servingSize: $servingSize, unit: $unit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RawMaterialDashboardArgs) return false;
    return key == other.key &&
        rawmaterialId == other.rawmaterialId &&
        rawmaterialName == other.rawmaterialName &&
        servingSize == other.servingSize &&
        unit == other.unit;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      rawmaterialId.hashCode ^
      rawmaterialName.hashCode ^
      servingSize.hashCode ^
      unit.hashCode;
}

/// generated route for
/// [_i33.RawMaterialIndex]
class RawMaterialIndex extends _i43.PageRouteInfo<void> {
  const RawMaterialIndex({List<_i43.PageRouteInfo>? children})
    : super(RawMaterialIndex.name, initialChildren: children);

  static const String name = 'RawMaterialIndex';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i33.RawMaterialIndex();
    },
  );
}

/// generated route for
/// [_i34.RequisitionIndex]
class RequisitionIndex extends _i43.PageRouteInfo<void> {
  const RequisitionIndex({List<_i43.PageRouteInfo>? children})
    : super(RequisitionIndex.name, initialChildren: children);

  static const String name = 'RequisitionIndex';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i34.RequisitionIndex();
    },
  );
}

/// generated route for
/// [_i35.SendProducts]
class SendProducts extends _i43.PageRouteInfo<void> {
  const SendProducts({List<_i43.PageRouteInfo>? children})
    : super(SendProducts.name, initialChildren: children);

  static const String name = 'SendProducts';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i35.SendProducts();
    },
  );
}

/// generated route for
/// [_i36.Settings]
class Settings extends _i43.PageRouteInfo<void> {
  const Settings({List<_i43.PageRouteInfo>? children})
    : super(Settings.name, initialChildren: children);

  static const String name = 'Settings';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i36.Settings();
    },
  );
}

/// generated route for
/// [_i37.StaffDashboard]
class StaffDashboard extends _i43.PageRouteInfo<void> {
  const StaffDashboard({List<_i43.PageRouteInfo>? children})
    : super(StaffDashboard.name, initialChildren: children);

  static const String name = 'StaffDashboard';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i37.StaffDashboard();
    },
  );
}

/// generated route for
/// [_i38.SupplierScreen]
class SupplierRoute extends _i43.PageRouteInfo<void> {
  const SupplierRoute({List<_i43.PageRouteInfo>? children})
    : super(SupplierRoute.name, initialChildren: children);

  static const String name = 'SupplierRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i38.SupplierScreen();
    },
  );
}

/// generated route for
/// [_i39.UserManagementScreen]
class UserManagementRoute extends _i43.PageRouteInfo<UserManagementRouteArgs> {
  UserManagementRoute({
    _i44.Key? key,
    bool? isGod,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         UserManagementRoute.name,
         args: UserManagementRouteArgs(key: key, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'UserManagementRoute';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserManagementRouteArgs>(
        orElse: () => const UserManagementRouteArgs(),
      );
      return _i39.UserManagementScreen(key: args.key, isGod: args.isGod);
    },
  );
}

class UserManagementRouteArgs {
  const UserManagementRouteArgs({this.key, this.isGod});

  final _i44.Key? key;

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
/// [_i40.ViewExpenses]
class ViewExpenses extends _i43.PageRouteInfo<ViewExpensesArgs> {
  ViewExpenses({
    _i44.Key? key,
    dynamic Function()? updateExpense,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         ViewExpenses.name,
         args: ViewExpensesArgs(key: key, updateExpense: updateExpense),
         initialChildren: children,
       );

  static const String name = 'ViewExpenses';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewExpensesArgs>(
        orElse: () => const ViewExpensesArgs(),
      );
      return _i40.ViewExpenses(
        key: args.key,
        updateExpense: args.updateExpense,
      );
    },
  );
}

class ViewExpensesArgs {
  const ViewExpensesArgs({this.key, this.updateExpense});

  final _i44.Key? key;

  final dynamic Function()? updateExpense;

  @override
  String toString() {
    return 'ViewExpensesArgs{key: $key, updateExpense: $updateExpense}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ViewExpensesArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i41.ViewInvoices]
class ViewInvoices extends _i43.PageRouteInfo<ViewInvoicesArgs> {
  ViewInvoices({
    _i44.Key? key,
    String? invoiceId,
    List<_i43.PageRouteInfo>? children,
  }) : super(
         ViewInvoices.name,
         args: ViewInvoicesArgs(key: key, invoiceId: invoiceId),
         initialChildren: children,
       );

  static const String name = 'ViewInvoices';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewInvoicesArgs>(
        orElse: () => const ViewInvoicesArgs(),
      );
      return _i41.ViewInvoices(key: args.key, invoiceId: args.invoiceId);
    },
  );
}

class ViewInvoicesArgs {
  const ViewInvoicesArgs({this.key, this.invoiceId});

  final _i44.Key? key;

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

/// generated route for
/// [_i42.Wip]
class Wip extends _i43.PageRouteInfo<void> {
  const Wip({List<_i43.PageRouteInfo>? children})
    : super(Wip.name, initialChildren: children);

  static const String name = 'Wip';

  static _i43.PageInfo page = _i43.PageInfo(
    name,
    builder: (data) {
      return const _i42.Wip();
    },
  );
}
