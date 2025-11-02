// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i68;
import 'package:averra_suite/accounts/accounting/accounting.dashboard.dart'
    as _i1;
import 'package:averra_suite/accounts/accounting/navigation.dart' as _i2;
import 'package:averra_suite/accounts/bar/navigation.dart' as _i11;
import 'package:averra_suite/accounts/kitchen/navigation.dart' as _i35;
import 'package:averra_suite/accounts/manager/dashboard/dashboard.dart' as _i21;
import 'package:averra_suite/accounts/manager/navigation.dart' as _i39;
import 'package:averra_suite/accounts/store/store.navigation.dart' as _i54;
import 'package:averra_suite/accounts/supervior/dashbaord.supervior.dart'
    as _i22;
import 'package:averra_suite/accounts/supervior/navigation.dart' as _i55;
import 'package:averra_suite/accounts/waiter/navigation.dart' as _i66;
import 'package:averra_suite/components/error.dart' as _i29;
import 'package:averra_suite/screens/admin/dashbaord.dart' as _i8;
import 'package:averra_suite/screens/admin/navigation.dart' as _i9;
import 'package:averra_suite/screens/admin/settings.dart' as _i52;
import 'package:averra_suite/screens/banks/index.dart' as _i10;
import 'package:averra_suite/screens/cart/index.dart' as _i12;
import 'package:averra_suite/screens/charges/index.dart' as _i16;
import 'package:averra_suite/screens/customers/dashbaord/index.dart' as _i19;
import 'package:averra_suite/screens/customers/index.dart' as _i20;
import 'package:averra_suite/screens/department/dashboard.dart' as _i23;
import 'package:averra_suite/screens/department/department.history.dart'
    as _i24;
import 'package:averra_suite/screens/department/department.request.dart'
    as _i27;
import 'package:averra_suite/screens/department/department/index.dart' as _i25;
import 'package:averra_suite/screens/department/navigation.dart' as _i26;
import 'package:averra_suite/screens/department/send.products.dart' as _i50;
import 'package:averra_suite/screens/expenses/add_expneses.dart' as _i3;
import 'package:averra_suite/screens/expenses/categories.dart' as _i14;
import 'package:averra_suite/screens/expenses/expenses.dashbaord.dart' as _i31;
import 'package:averra_suite/screens/expenses/view_expenses.dart' as _i60;
import 'package:averra_suite/screens/invoice/add_invoice.dart' as _i4;
import 'package:averra_suite/screens/invoice/view_invoices.dart' as _i61;
import 'package:averra_suite/screens/locations/index.dart' as _i36;
import 'package:averra_suite/screens/login/login.dart' as _i37;
import 'package:averra_suite/screens/makesale/checkout.dart' as _i17;
import 'package:averra_suite/screens/makesale/index.dart' as _i38;
import 'package:averra_suite/screens/otherincome/addotherincome.dart' as _i5;
import 'package:averra_suite/screens/otherincome/categories.dart' as _i40;
import 'package:averra_suite/screens/otherincome/otherIncomr.dashbaord.dart'
    as _i41;
import 'package:averra_suite/screens/otherincome/viewotherincomes.dart' as _i62;
import 'package:averra_suite/screens/products/category/index.dart' as _i15;
import 'package:averra_suite/screens/products/index.dart' as _i45;
import 'package:averra_suite/screens/products/product_dashbaord/product_dashboard.dart'
    as _i44;
import 'package:averra_suite/screens/rawmaterial/rawmaterial.index.dart'
    as _i48;
import 'package:averra_suite/screens/rawmaterial/rawmaterial_dashbaord/rawmaterial_dashboard.dart'
    as _i47;
import 'package:averra_suite/screens/reports/expence_reports/index.dart'
    as _i30;
import 'package:averra_suite/screens/reports/income_reports/index.dart' as _i33;
import 'package:averra_suite/screens/reports/payment_reports/index.dart'
    as _i42;
import 'package:averra_suite/screens/requisition/create.requisition.dart'
    as _i18;
import 'package:averra_suite/screens/requisition/pending.requisition.dart'
    as _i43;
import 'package:averra_suite/screens/requisition/requisition.index.dart'
    as _i49;
import 'package:averra_suite/screens/requisition/send.to.branch.dart' as _i51;
import 'package:averra_suite/screens/searving/index.servingsize.dart' as _i34;
import 'package:averra_suite/screens/statements/cash.statement.dart' as _i13;
import 'package:averra_suite/screens/statements/profit.loss.statement.dart'
    as _i46;
import 'package:averra_suite/screens/stock/display.stock.dart' as _i28;
import 'package:averra_suite/screens/supplier/add_supplier.dart' as _i6;
import 'package:averra_suite/screens/supplier/index.dart' as _i57;
import 'package:averra_suite/screens/supplier/supplier.details.dart' as _i56;
import 'package:averra_suite/screens/supplier/suppliers.dashbaord.dart' as _i58;
import 'package:averra_suite/screens/supplier/view_suppliers.dart' as _i63;
import 'package:averra_suite/screens/users/add_user.dart' as _i7;
import 'package:averra_suite/screens/users/index.dart' as _i59;
import 'package:averra_suite/screens/users/staffdetails/staff.dashboard.dart'
    as _i53;
import 'package:averra_suite/screens/users/view.user.dart' as _i64;
import 'package:averra_suite/screens/users/view_users.dart' as _i65;
import 'package:averra_suite/screens/worInProgress/finished_goods.dart' as _i32;
import 'package:averra_suite/screens/worInProgress/wip.dart' as _i67;
import 'package:collection/collection.dart' as _i70;
import 'package:flutter/material.dart' as _i69;

/// generated route for
/// [_i1.AccountingDashboardScreen]
class AccountingDashboardRoute extends _i68.PageRouteInfo<void> {
  const AccountingDashboardRoute({List<_i68.PageRouteInfo>? children})
    : super(AccountingDashboardRoute.name, initialChildren: children);

  static const String name = 'AccountingDashboardRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountingDashboardScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountingNavigationScreen]
class AccountingNavigationRoute extends _i68.PageRouteInfo<void> {
  const AccountingNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(AccountingNavigationRoute.name, initialChildren: children);

  static const String name = 'AccountingNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountingNavigationScreen();
    },
  );
}

/// generated route for
/// [_i3.AddExpenseScreen]
class AddExpenseRoute extends _i68.PageRouteInfo<AddExpenseRouteArgs> {
  AddExpenseRoute({
    _i69.Key? key,
    Map<dynamic, dynamic>? updateInfo,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AddExpenseRoute.name,
         args: AddExpenseRouteArgs(key: key, updateInfo: updateInfo),
         initialChildren: children,
       );

  static const String name = 'AddExpenseRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddExpenseRouteArgs>(
        orElse: () => const AddExpenseRouteArgs(),
      );
      return _i3.AddExpenseScreen(key: args.key, updateInfo: args.updateInfo);
    },
  );
}

class AddExpenseRouteArgs {
  const AddExpenseRouteArgs({this.key, this.updateInfo});

  final _i69.Key? key;

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
        const _i70.MapEquality<dynamic, dynamic>().equals(
          updateInfo,
          other.updateInfo,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i70.MapEquality<dynamic, dynamic>().hash(updateInfo);
}

/// generated route for
/// [_i4.AddInvoice]
class AddInvoice extends _i68.PageRouteInfo<void> {
  const AddInvoice({List<_i68.PageRouteInfo>? children})
    : super(AddInvoice.name, initialChildren: children);

  static const String name = 'AddInvoice';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i4.AddInvoice();
    },
  );
}

/// generated route for
/// [_i5.AddOtherIncomeScreen]
class AddOtherIncomeRoute extends _i68.PageRouteInfo<AddOtherIncomeRouteArgs> {
  AddOtherIncomeRoute({
    _i69.Key? key,
    Map<dynamic, dynamic>? updateInfo,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AddOtherIncomeRoute.name,
         args: AddOtherIncomeRouteArgs(key: key, updateInfo: updateInfo),
         initialChildren: children,
       );

  static const String name = 'AddOtherIncomeRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddOtherIncomeRouteArgs>(
        orElse: () => const AddOtherIncomeRouteArgs(),
      );
      return _i5.AddOtherIncomeScreen(
        key: args.key,
        updateInfo: args.updateInfo,
      );
    },
  );
}

class AddOtherIncomeRouteArgs {
  const AddOtherIncomeRouteArgs({this.key, this.updateInfo});

  final _i69.Key? key;

  final Map<dynamic, dynamic>? updateInfo;

  @override
  String toString() {
    return 'AddOtherIncomeRouteArgs{key: $key, updateInfo: $updateInfo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddOtherIncomeRouteArgs) return false;
    return key == other.key &&
        const _i70.MapEquality<dynamic, dynamic>().equals(
          updateInfo,
          other.updateInfo,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i70.MapEquality<dynamic, dynamic>().hash(updateInfo);
}

/// generated route for
/// [_i6.AddSupplier]
class AddSupplier extends _i68.PageRouteInfo<void> {
  const AddSupplier({List<_i68.PageRouteInfo>? children})
    : super(AddSupplier.name, initialChildren: children);

  static const String name = 'AddSupplier';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i6.AddSupplier();
    },
  );
}

/// generated route for
/// [_i7.AddUser]
class AddUser extends _i68.PageRouteInfo<AddUserArgs> {
  AddUser({
    _i69.Key? key,
    dynamic Function()? updateUserList,
    bool? isGod,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AddUser.name,
         args: AddUserArgs(
           key: key,
           updateUserList: updateUserList,
           isGod: isGod,
         ),
         initialChildren: children,
       );

  static const String name = 'AddUser';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddUserArgs>(orElse: () => const AddUserArgs());
      return _i7.AddUser(
        key: args.key,
        updateUserList: args.updateUserList,
        isGod: args.isGod,
      );
    },
  );
}

class AddUserArgs {
  const AddUserArgs({this.key, this.updateUserList, this.isGod});

  final _i69.Key? key;

  final dynamic Function()? updateUserList;

  final bool? isGod;

  @override
  String toString() {
    return 'AddUserArgs{key: $key, updateUserList: $updateUserList, isGod: $isGod}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddUserArgs) return false;
    return key == other.key && isGod == other.isGod;
  }

  @override
  int get hashCode => key.hashCode ^ isGod.hashCode;
}

/// generated route for
/// [_i8.AdminDashbaord]
class AdminDashbaord extends _i68.PageRouteInfo<void> {
  const AdminDashbaord({List<_i68.PageRouteInfo>? children})
    : super(AdminDashbaord.name, initialChildren: children);

  static const String name = 'AdminDashbaord';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i8.AdminDashbaord();
    },
  );
}

/// generated route for
/// [_i9.AdminNavigation]
class AdminNavigation extends _i68.PageRouteInfo<void> {
  const AdminNavigation({List<_i68.PageRouteInfo>? children})
    : super(AdminNavigation.name, initialChildren: children);

  static const String name = 'AdminNavigation';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i9.AdminNavigation();
    },
  );
}

/// generated route for
/// [_i10.BankScreen]
class BankRoute extends _i68.PageRouteInfo<void> {
  const BankRoute({List<_i68.PageRouteInfo>? children})
    : super(BankRoute.name, initialChildren: children);

  static const String name = 'BankRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i10.BankScreen();
    },
  );
}

/// generated route for
/// [_i11.BarNavigationScreen]
class BarNavigationRoute extends _i68.PageRouteInfo<void> {
  const BarNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(BarNavigationRoute.name, initialChildren: children);

  static const String name = 'BarNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i11.BarNavigationScreen();
    },
  );
}

/// generated route for
/// [_i12.CartScreen]
class CartRoute extends _i68.PageRouteInfo<void> {
  const CartRoute({List<_i68.PageRouteInfo>? children})
    : super(CartRoute.name, initialChildren: children);

  static const String name = 'CartRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i12.CartScreen();
    },
  );
}

/// generated route for
/// [_i13.CashStatementScreen]
class CashStatementRoute extends _i68.PageRouteInfo<void> {
  const CashStatementRoute({List<_i68.PageRouteInfo>? children})
    : super(CashStatementRoute.name, initialChildren: children);

  static const String name = 'CashStatementRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i13.CashStatementScreen();
    },
  );
}

/// generated route for
/// [_i14.CategoriesScreen]
class CategoriesRoute extends _i68.PageRouteInfo<void> {
  const CategoriesRoute({List<_i68.PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i14.CategoriesScreen();
    },
  );
}

/// generated route for
/// [_i15.CategoryScreen]
class CategoryRoute extends _i68.PageRouteInfo<void> {
  const CategoryRoute({List<_i68.PageRouteInfo>? children})
    : super(CategoryRoute.name, initialChildren: children);

  static const String name = 'CategoryRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i15.CategoryScreen();
    },
  );
}

/// generated route for
/// [_i16.ChargesScreen]
class ChargesRoute extends _i68.PageRouteInfo<void> {
  const ChargesRoute({List<_i68.PageRouteInfo>? children})
    : super(ChargesRoute.name, initialChildren: children);

  static const String name = 'ChargesRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i16.ChargesScreen();
    },
  );
}

/// generated route for
/// [_i17.CheckoutScreen]
class CheckoutRoute extends _i68.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i69.Key? key,
    required double total,
    required List<dynamic> cart,
    required Function handleComplete,
    Map<dynamic, dynamic>? selectedBank,
    Map<dynamic, dynamic>? selectedUser,
    num? discount,
    String? invoiceId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckoutRouteArgs>();
      return _i17.CheckoutScreen(
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

  final _i69.Key? key;

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
        const _i70.ListEquality<dynamic>().equals(cart, other.cart) &&
        handleComplete == other.handleComplete &&
        const _i70.MapEquality<dynamic, dynamic>().equals(
          selectedBank,
          other.selectedBank,
        ) &&
        const _i70.MapEquality<dynamic, dynamic>().equals(
          selectedUser,
          other.selectedUser,
        ) &&
        discount == other.discount &&
        invoiceId == other.invoiceId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      total.hashCode ^
      const _i70.ListEquality<dynamic>().hash(cart) ^
      handleComplete.hashCode ^
      const _i70.MapEquality<dynamic, dynamic>().hash(selectedBank) ^
      const _i70.MapEquality<dynamic, dynamic>().hash(selectedUser) ^
      discount.hashCode ^
      invoiceId.hashCode;
}

/// generated route for
/// [_i18.CreateRequisition]
class CreateRequisition extends _i68.PageRouteInfo<void> {
  const CreateRequisition({List<_i68.PageRouteInfo>? children})
    : super(CreateRequisition.name, initialChildren: children);

  static const String name = 'CreateRequisition';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i18.CreateRequisition();
    },
  );
}

/// generated route for
/// [_i19.CustomerDetails]
class CustomerDetails extends _i68.PageRouteInfo<CustomerDetailsArgs> {
  CustomerDetails({
    _i69.Key? key,
    required Map<dynamic, dynamic> customer,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CustomerDetails.name,
         args: CustomerDetailsArgs(key: key, customer: customer),
         initialChildren: children,
       );

  static const String name = 'CustomerDetails';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDetailsArgs>();
      return _i19.CustomerDetails(key: args.key, customer: args.customer);
    },
  );
}

class CustomerDetailsArgs {
  const CustomerDetailsArgs({this.key, required this.customer});

  final _i69.Key? key;

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
        const _i70.MapEquality<dynamic, dynamic>().equals(
          customer,
          other.customer,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^ const _i70.MapEquality<dynamic, dynamic>().hash(customer);
}

/// generated route for
/// [_i20.CustomerScreen]
class CustomerRoute extends _i68.PageRouteInfo<void> {
  const CustomerRoute({List<_i68.PageRouteInfo>? children})
    : super(CustomerRoute.name, initialChildren: children);

  static const String name = 'CustomerRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i20.CustomerScreen();
    },
  );
}

/// generated route for
/// [_i21.DashbaordManagerScreen]
class DashbaordManagerRoute
    extends _i68.PageRouteInfo<DashbaordManagerRouteArgs> {
  DashbaordManagerRoute({
    _i69.Key? key,
    dynamic Function()? onResult,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         DashbaordManagerRoute.name,
         args: DashbaordManagerRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'DashbaordManagerRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DashbaordManagerRouteArgs>(
        orElse: () => const DashbaordManagerRouteArgs(),
      );
      return _i21.DashbaordManagerScreen(
        key: args.key,
        onResult: args.onResult,
      );
    },
  );
}

class DashbaordManagerRouteArgs {
  const DashbaordManagerRouteArgs({this.key, this.onResult});

  final _i69.Key? key;

  final dynamic Function()? onResult;

  @override
  String toString() {
    return 'DashbaordManagerRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DashbaordManagerRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i22.DashbaordSuperviorScreen]
class DashbaordSuperviorRoute extends _i68.PageRouteInfo<void> {
  const DashbaordSuperviorRoute({List<_i68.PageRouteInfo>? children})
    : super(DashbaordSuperviorRoute.name, initialChildren: children);

  static const String name = 'DashbaordSuperviorRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i22.DashbaordSuperviorScreen();
    },
  );
}

/// generated route for
/// [_i23.DepartmentDashboard]
class DepartmentDashboard extends _i68.PageRouteInfo<void> {
  const DepartmentDashboard({List<_i68.PageRouteInfo>? children})
    : super(DepartmentDashboard.name, initialChildren: children);

  static const String name = 'DepartmentDashboard';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i23.DepartmentDashboard();
    },
  );
}

/// generated route for
/// [_i24.DepartmentHistory]
class DepartmentHistory extends _i68.PageRouteInfo<void> {
  const DepartmentHistory({List<_i68.PageRouteInfo>? children})
    : super(DepartmentHistory.name, initialChildren: children);

  static const String name = 'DepartmentHistory';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i24.DepartmentHistory();
    },
  );
}

/// generated route for
/// [_i25.DepartmentIndex]
class DepartmentIndex extends _i68.PageRouteInfo<void> {
  const DepartmentIndex({List<_i68.PageRouteInfo>? children})
    : super(DepartmentIndex.name, initialChildren: children);

  static const String name = 'DepartmentIndex';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i25.DepartmentIndex();
    },
  );
}

/// generated route for
/// [_i26.DepartmentNavigation]
class DepartmentNavigation extends _i68.PageRouteInfo<void> {
  const DepartmentNavigation({List<_i68.PageRouteInfo>? children})
    : super(DepartmentNavigation.name, initialChildren: children);

  static const String name = 'DepartmentNavigation';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i26.DepartmentNavigation();
    },
  );
}

/// generated route for
/// [_i27.DepartmentRequest]
class DepartmentRequest extends _i68.PageRouteInfo<void> {
  const DepartmentRequest({List<_i68.PageRouteInfo>? children})
    : super(DepartmentRequest.name, initialChildren: children);

  static const String name = 'DepartmentRequest';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i27.DepartmentRequest();
    },
  );
}

/// generated route for
/// [_i28.DisplayStockScreen]
class DisplayStockRoute extends _i68.PageRouteInfo<void> {
  const DisplayStockRoute({List<_i68.PageRouteInfo>? children})
    : super(DisplayStockRoute.name, initialChildren: children);

  static const String name = 'DisplayStockRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i28.DisplayStockScreen();
    },
  );
}

/// generated route for
/// [_i29.ErrorPage]
class ErrorRoute extends _i68.PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute({
    _i69.Key? key,
    _i69.VoidCallback? onRetry,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ErrorRoute.name,
         args: ErrorRouteArgs(key: key, onRetry: onRetry),
         initialChildren: children,
       );

  static const String name = 'ErrorRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ErrorRouteArgs>(
        orElse: () => const ErrorRouteArgs(),
      );
      return _i29.ErrorPage(key: args.key, onRetry: args.onRetry);
    },
  );
}

class ErrorRouteArgs {
  const ErrorRouteArgs({this.key, this.onRetry});

  final _i69.Key? key;

  final _i69.VoidCallback? onRetry;

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
/// [_i30.ExpencesReportScreen]
class ExpencesReportRoute extends _i68.PageRouteInfo<void> {
  const ExpencesReportRoute({List<_i68.PageRouteInfo>? children})
    : super(ExpencesReportRoute.name, initialChildren: children);

  static const String name = 'ExpencesReportRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i30.ExpencesReportScreen();
    },
  );
}

/// generated route for
/// [_i31.ExpensesDashbaord]
class ExpensesDashbaord extends _i68.PageRouteInfo<void> {
  const ExpensesDashbaord({List<_i68.PageRouteInfo>? children})
    : super(ExpensesDashbaord.name, initialChildren: children);

  static const String name = 'ExpensesDashbaord';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i31.ExpensesDashbaord();
    },
  );
}

/// generated route for
/// [_i32.FinishedGoods]
class FinishedGoods extends _i68.PageRouteInfo<void> {
  const FinishedGoods({List<_i68.PageRouteInfo>? children})
    : super(FinishedGoods.name, initialChildren: children);

  static const String name = 'FinishedGoods';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i32.FinishedGoods();
    },
  );
}

/// generated route for
/// [_i33.IncomeReportsScreen]
class IncomeReportsRoute extends _i68.PageRouteInfo<void> {
  const IncomeReportsRoute({List<_i68.PageRouteInfo>? children})
    : super(IncomeReportsRoute.name, initialChildren: children);

  static const String name = 'IncomeReportsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i33.IncomeReportsScreen();
    },
  );
}

/// generated route for
/// [_i34.IndexServingsizeScreen]
class IndexServingsizeRoute extends _i68.PageRouteInfo<void> {
  const IndexServingsizeRoute({List<_i68.PageRouteInfo>? children})
    : super(IndexServingsizeRoute.name, initialChildren: children);

  static const String name = 'IndexServingsizeRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i34.IndexServingsizeScreen();
    },
  );
}

/// generated route for
/// [_i35.KitchenNavigationScreen]
class KitchenNavigationRoute extends _i68.PageRouteInfo<void> {
  const KitchenNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(KitchenNavigationRoute.name, initialChildren: children);

  static const String name = 'KitchenNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i35.KitchenNavigationScreen();
    },
  );
}

/// generated route for
/// [_i36.LocationIndex]
class LocationIndex extends _i68.PageRouteInfo<void> {
  const LocationIndex({List<_i68.PageRouteInfo>? children})
    : super(LocationIndex.name, initialChildren: children);

  static const String name = 'LocationIndex';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i36.LocationIndex();
    },
  );
}

/// generated route for
/// [_i37.LoginScreen]
class LoginRoute extends _i68.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i69.Key? key,
    dynamic Function()? onResult,
    bool? isGod,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i37.LoginScreen(
        key: args.key,
        onResult: args.onResult,
        isGod: args.isGod,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult, this.isGod});

  final _i69.Key? key;

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
/// [_i38.MakeSaleScreen]
class MakeSaleRoute extends _i68.PageRouteInfo<MakeSaleRouteArgs> {
  MakeSaleRoute({
    _i69.Key? key,
    dynamic Function()? onResult,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         MakeSaleRoute.name,
         args: MakeSaleRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'MakeSaleRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MakeSaleRouteArgs>(
        orElse: () => const MakeSaleRouteArgs(),
      );
      return _i38.MakeSaleScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class MakeSaleRouteArgs {
  const MakeSaleRouteArgs({this.key, this.onResult});

  final _i69.Key? key;

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
/// [_i39.ManagerNavigationScreen]
class ManagerNavigationRoute extends _i68.PageRouteInfo<void> {
  const ManagerNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(ManagerNavigationRoute.name, initialChildren: children);

  static const String name = 'ManagerNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i39.ManagerNavigationScreen();
    },
  );
}

/// generated route for
/// [_i40.OtherIncomeCategoriesScreen]
class OtherIncomeCategoriesRoute extends _i68.PageRouteInfo<void> {
  const OtherIncomeCategoriesRoute({List<_i68.PageRouteInfo>? children})
    : super(OtherIncomeCategoriesRoute.name, initialChildren: children);

  static const String name = 'OtherIncomeCategoriesRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i40.OtherIncomeCategoriesScreen();
    },
  );
}

/// generated route for
/// [_i41.OtherIncomesDashbaord]
class OtherIncomesDashbaord extends _i68.PageRouteInfo<void> {
  const OtherIncomesDashbaord({List<_i68.PageRouteInfo>? children})
    : super(OtherIncomesDashbaord.name, initialChildren: children);

  static const String name = 'OtherIncomesDashbaord';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i41.OtherIncomesDashbaord();
    },
  );
}

/// generated route for
/// [_i42.PaymentReportsScreen]
class PaymentReportsRoute extends _i68.PageRouteInfo<void> {
  const PaymentReportsRoute({List<_i68.PageRouteInfo>? children})
    : super(PaymentReportsRoute.name, initialChildren: children);

  static const String name = 'PaymentReportsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i42.PaymentReportsScreen();
    },
  );
}

/// generated route for
/// [_i43.PendingRequisition]
class PendingRequisition extends _i68.PageRouteInfo<void> {
  const PendingRequisition({List<_i68.PageRouteInfo>? children})
    : super(PendingRequisition.name, initialChildren: children);

  static const String name = 'PendingRequisition';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i43.PendingRequisition();
    },
  );
}

/// generated route for
/// [_i44.ProductDashboard]
class ProductDashboard extends _i68.PageRouteInfo<ProductDashboardArgs> {
  ProductDashboard({
    _i69.Key? key,
    String? productId,
    String? productName,
    required String type,
    required String? servingQuantity,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductDashboardArgs>();
      return _i44.ProductDashboard(
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

  final _i69.Key? key;

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
/// [_i45.ProductsScreen]
class ProductsRoute extends _i68.PageRouteInfo<void> {
  const ProductsRoute({List<_i68.PageRouteInfo>? children})
    : super(ProductsRoute.name, initialChildren: children);

  static const String name = 'ProductsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i45.ProductsScreen();
    },
  );
}

/// generated route for
/// [_i46.ProfitLossStatementScreen]
class ProfitLossStatementRoute extends _i68.PageRouteInfo<void> {
  const ProfitLossStatementRoute({List<_i68.PageRouteInfo>? children})
    : super(ProfitLossStatementRoute.name, initialChildren: children);

  static const String name = 'ProfitLossStatementRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i46.ProfitLossStatementScreen();
    },
  );
}

/// generated route for
/// [_i47.RawMaterialDashboard]
class RawMaterialDashboard
    extends _i68.PageRouteInfo<RawMaterialDashboardArgs> {
  RawMaterialDashboard({
    _i69.Key? key,
    required String rawmaterialId,
    required String rawmaterialName,
    required num servingSize,
    required String unit,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RawMaterialDashboardArgs>();
      return _i47.RawMaterialDashboard(
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

  final _i69.Key? key;

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
/// [_i48.RawMaterialIndex]
class RawMaterialIndex extends _i68.PageRouteInfo<void> {
  const RawMaterialIndex({List<_i68.PageRouteInfo>? children})
    : super(RawMaterialIndex.name, initialChildren: children);

  static const String name = 'RawMaterialIndex';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i48.RawMaterialIndex();
    },
  );
}

/// generated route for
/// [_i49.RequisitionIndex]
class RequisitionIndex extends _i68.PageRouteInfo<void> {
  const RequisitionIndex({List<_i68.PageRouteInfo>? children})
    : super(RequisitionIndex.name, initialChildren: children);

  static const String name = 'RequisitionIndex';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i49.RequisitionIndex();
    },
  );
}

/// generated route for
/// [_i50.SendProducts]
class SendProducts extends _i68.PageRouteInfo<void> {
  const SendProducts({List<_i68.PageRouteInfo>? children})
    : super(SendProducts.name, initialChildren: children);

  static const String name = 'SendProducts';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i50.SendProducts();
    },
  );
}

/// generated route for
/// [_i51.SendToBranchScreen]
class SendToBranchRoute extends _i68.PageRouteInfo<void> {
  const SendToBranchRoute({List<_i68.PageRouteInfo>? children})
    : super(SendToBranchRoute.name, initialChildren: children);

  static const String name = 'SendToBranchRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i51.SendToBranchScreen();
    },
  );
}

/// generated route for
/// [_i52.Settings]
class Settings extends _i68.PageRouteInfo<void> {
  const Settings({List<_i68.PageRouteInfo>? children})
    : super(Settings.name, initialChildren: children);

  static const String name = 'Settings';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i52.Settings();
    },
  );
}

/// generated route for
/// [_i53.StaffDashboard]
class StaffDashboard extends _i68.PageRouteInfo<void> {
  const StaffDashboard({List<_i68.PageRouteInfo>? children})
    : super(StaffDashboard.name, initialChildren: children);

  static const String name = 'StaffDashboard';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i53.StaffDashboard();
    },
  );
}

/// generated route for
/// [_i54.StoreNavigationScreen]
class StoreNavigationRoute extends _i68.PageRouteInfo<void> {
  const StoreNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(StoreNavigationRoute.name, initialChildren: children);

  static const String name = 'StoreNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i54.StoreNavigationScreen();
    },
  );
}

/// generated route for
/// [_i55.SuperviorNavigationScreen]
class SuperviorNavigationRoute extends _i68.PageRouteInfo<void> {
  const SuperviorNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(SuperviorNavigationRoute.name, initialChildren: children);

  static const String name = 'SuperviorNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i55.SuperviorNavigationScreen();
    },
  );
}

/// generated route for
/// [_i56.SupplierDetailsScreen]
class SupplierDetailsRoute
    extends _i68.PageRouteInfo<SupplierDetailsRouteArgs> {
  SupplierDetailsRoute({
    _i69.Key? key,
    required String supplierId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         SupplierDetailsRoute.name,
         args: SupplierDetailsRouteArgs(key: key, supplierId: supplierId),
         initialChildren: children,
       );

  static const String name = 'SupplierDetailsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupplierDetailsRouteArgs>();
      return _i56.SupplierDetailsScreen(
        key: args.key,
        supplierId: args.supplierId,
      );
    },
  );
}

class SupplierDetailsRouteArgs {
  const SupplierDetailsRouteArgs({this.key, required this.supplierId});

  final _i69.Key? key;

  final String supplierId;

  @override
  String toString() {
    return 'SupplierDetailsRouteArgs{key: $key, supplierId: $supplierId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SupplierDetailsRouteArgs) return false;
    return key == other.key && supplierId == other.supplierId;
  }

  @override
  int get hashCode => key.hashCode ^ supplierId.hashCode;
}

/// generated route for
/// [_i57.SupplierScreen]
class SupplierRoute extends _i68.PageRouteInfo<void> {
  const SupplierRoute({List<_i68.PageRouteInfo>? children})
    : super(SupplierRoute.name, initialChildren: children);

  static const String name = 'SupplierRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i57.SupplierScreen();
    },
  );
}

/// generated route for
/// [_i58.SuppliersDashbaordScreen]
class SuppliersDashbaordRoute extends _i68.PageRouteInfo<void> {
  const SuppliersDashbaordRoute({List<_i68.PageRouteInfo>? children})
    : super(SuppliersDashbaordRoute.name, initialChildren: children);

  static const String name = 'SuppliersDashbaordRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i58.SuppliersDashbaordScreen();
    },
  );
}

/// generated route for
/// [_i59.UserManagementScreen]
class UserManagementRoute extends _i68.PageRouteInfo<UserManagementRouteArgs> {
  UserManagementRoute({
    _i69.Key? key,
    bool? isGod,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         UserManagementRoute.name,
         args: UserManagementRouteArgs(key: key, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'UserManagementRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserManagementRouteArgs>(
        orElse: () => const UserManagementRouteArgs(),
      );
      return _i59.UserManagementScreen(key: args.key, isGod: args.isGod);
    },
  );
}

class UserManagementRouteArgs {
  const UserManagementRouteArgs({this.key, this.isGod});

  final _i69.Key? key;

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
/// [_i60.ViewExpenses]
class ViewExpenses extends _i68.PageRouteInfo<ViewExpensesArgs> {
  ViewExpenses({
    _i69.Key? key,
    dynamic Function()? updateExpense,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ViewExpenses.name,
         args: ViewExpensesArgs(key: key, updateExpense: updateExpense),
         initialChildren: children,
       );

  static const String name = 'ViewExpenses';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewExpensesArgs>(
        orElse: () => const ViewExpensesArgs(),
      );
      return _i60.ViewExpenses(
        key: args.key,
        updateExpense: args.updateExpense,
      );
    },
  );
}

class ViewExpensesArgs {
  const ViewExpensesArgs({this.key, this.updateExpense});

  final _i69.Key? key;

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
/// [_i61.ViewInvoices]
class ViewInvoices extends _i68.PageRouteInfo<ViewInvoicesArgs> {
  ViewInvoices({
    _i69.Key? key,
    String? invoiceId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ViewInvoices.name,
         args: ViewInvoicesArgs(key: key, invoiceId: invoiceId),
         initialChildren: children,
       );

  static const String name = 'ViewInvoices';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewInvoicesArgs>(
        orElse: () => const ViewInvoicesArgs(),
      );
      return _i61.ViewInvoices(key: args.key, invoiceId: args.invoiceId);
    },
  );
}

class ViewInvoicesArgs {
  const ViewInvoicesArgs({this.key, this.invoiceId});

  final _i69.Key? key;

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
/// [_i62.ViewOtherIncomes]
class ViewOtherIncomes extends _i68.PageRouteInfo<ViewOtherIncomesArgs> {
  ViewOtherIncomes({
    _i69.Key? key,
    dynamic Function()? updateOtherIncome,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ViewOtherIncomes.name,
         args: ViewOtherIncomesArgs(
           key: key,
           updateOtherIncome: updateOtherIncome,
         ),
         initialChildren: children,
       );

  static const String name = 'ViewOtherIncomes';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewOtherIncomesArgs>(
        orElse: () => const ViewOtherIncomesArgs(),
      );
      return _i62.ViewOtherIncomes(
        key: args.key,
        updateOtherIncome: args.updateOtherIncome,
      );
    },
  );
}

class ViewOtherIncomesArgs {
  const ViewOtherIncomesArgs({this.key, this.updateOtherIncome});

  final _i69.Key? key;

  final dynamic Function()? updateOtherIncome;

  @override
  String toString() {
    return 'ViewOtherIncomesArgs{key: $key, updateOtherIncome: $updateOtherIncome}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ViewOtherIncomesArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i63.ViewSuppliersScreen]
class ViewSuppliersRoute extends _i68.PageRouteInfo<void> {
  const ViewSuppliersRoute({List<_i68.PageRouteInfo>? children})
    : super(ViewSuppliersRoute.name, initialChildren: children);

  static const String name = 'ViewSuppliersRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i63.ViewSuppliersScreen();
    },
  );
}

/// generated route for
/// [_i64.ViewUser]
class ViewUser extends _i68.PageRouteInfo<ViewUserArgs> {
  ViewUser({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ViewUser.name,
         args: ViewUserArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ViewUser';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewUserArgs>();
      return _i64.ViewUser(key: args.key, id: args.id);
    },
  );
}

class ViewUserArgs {
  const ViewUserArgs({this.key, required this.id});

  final _i69.Key? key;

  final String id;

  @override
  String toString() {
    return 'ViewUserArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ViewUserArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i65.ViewUsers]
class ViewUsers extends _i68.PageRouteInfo<void> {
  const ViewUsers({List<_i68.PageRouteInfo>? children})
    : super(ViewUsers.name, initialChildren: children);

  static const String name = 'ViewUsers';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i65.ViewUsers();
    },
  );
}

/// generated route for
/// [_i66.WaiterNavigationScreen]
class WaiterNavigationRoute extends _i68.PageRouteInfo<void> {
  const WaiterNavigationRoute({List<_i68.PageRouteInfo>? children})
    : super(WaiterNavigationRoute.name, initialChildren: children);

  static const String name = 'WaiterNavigationRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i66.WaiterNavigationScreen();
    },
  );
}

/// generated route for
/// [_i67.Wip]
class Wip extends _i68.PageRouteInfo<void> {
  const Wip({List<_i68.PageRouteInfo>? children})
    : super(Wip.name, initialChildren: children);

  static const String name = 'Wip';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i67.Wip();
    },
  );
}
