// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:averra_suite/screens/admin/dashbaord.dart' as _i1;
import 'package:averra_suite/screens/admin/navigation.dart' as _i2;
import 'package:averra_suite/screens/locations/index.dart' as _i4;
import 'package:averra_suite/screens/login/login.dart' as _i5;
import 'package:averra_suite/screens/products/category/index.dart' as _i3;
import 'package:averra_suite/screens/products/index.dart' as _i7;
import 'package:averra_suite/screens/products/product_dashbaord/product_dashboard.dart'
    as _i6;
import 'package:averra_suite/screens/supplier/index.dart' as _i8;
import 'package:averra_suite/screens/users/index.dart' as _i9;
import 'package:flutter/material.dart' as _i11;

/// generated route for
/// [_i1.AdminDashbaord]
class AdminDashbaord extends _i10.PageRouteInfo<void> {
  const AdminDashbaord({List<_i10.PageRouteInfo>? children})
    : super(AdminDashbaord.name, initialChildren: children);

  static const String name = 'AdminDashbaord';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdminDashbaord();
    },
  );
}

/// generated route for
/// [_i2.AdminNavigation]
class AdminNavigation extends _i10.PageRouteInfo<void> {
  const AdminNavigation({List<_i10.PageRouteInfo>? children})
    : super(AdminNavigation.name, initialChildren: children);

  static const String name = 'AdminNavigation';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminNavigation();
    },
  );
}

/// generated route for
/// [_i3.CategoryScreen]
class CategoryRoute extends _i10.PageRouteInfo<void> {
  const CategoryRoute({List<_i10.PageRouteInfo>? children})
    : super(CategoryRoute.name, initialChildren: children);

  static const String name = 'CategoryRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i3.CategoryScreen();
    },
  );
}

/// generated route for
/// [_i4.LocationIndex]
class LocationIndex extends _i10.PageRouteInfo<void> {
  const LocationIndex({List<_i10.PageRouteInfo>? children})
    : super(LocationIndex.name, initialChildren: children);

  static const String name = 'LocationIndex';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i4.LocationIndex();
    },
  );
}

/// generated route for
/// [_i5.LoginScreen]
class LoginRoute extends _i10.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i11.Key? key,
    dynamic Function()? onResult,
    bool? isGod,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i5.LoginScreen(
        key: args.key,
        onResult: args.onResult,
        isGod: args.isGod,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.onResult, this.isGod});

  final _i11.Key? key;

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
/// [_i6.ProductDashboard]
class ProductDashboard extends _i10.PageRouteInfo<ProductDashboardArgs> {
  ProductDashboard({
    _i11.Key? key,
    String? productId,
    String? productName,
    required String type,
    required String? cartonAmount,
    List<_i10.PageRouteInfo>? children,
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

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductDashboardArgs>();
      return _i6.ProductDashboard(
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

  final _i11.Key? key;

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
/// [_i7.ProductsScreen]
class ProductsRoute extends _i10.PageRouteInfo<void> {
  const ProductsRoute({List<_i10.PageRouteInfo>? children})
    : super(ProductsRoute.name, initialChildren: children);

  static const String name = 'ProductsRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i7.ProductsScreen();
    },
  );
}

/// generated route for
/// [_i8.SupplierScreen]
class SupplierRoute extends _i10.PageRouteInfo<void> {
  const SupplierRoute({List<_i10.PageRouteInfo>? children})
    : super(SupplierRoute.name, initialChildren: children);

  static const String name = 'SupplierRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i8.SupplierScreen();
    },
  );
}

/// generated route for
/// [_i9.UserManagementScreen]
class UserManagementRoute extends _i10.PageRouteInfo<UserManagementRouteArgs> {
  UserManagementRoute({
    _i11.Key? key,
    bool? isGod,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         UserManagementRoute.name,
         args: UserManagementRouteArgs(key: key, isGod: isGod),
         initialChildren: children,
       );

  static const String name = 'UserManagementRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserManagementRouteArgs>(
        orElse: () => const UserManagementRouteArgs(),
      );
      return _i9.UserManagementScreen(key: args.key, isGod: args.isGod);
    },
  );
}

class UserManagementRouteArgs {
  const UserManagementRouteArgs({this.key, this.isGod});

  final _i11.Key? key;

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
