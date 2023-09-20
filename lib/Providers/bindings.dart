import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Providers/auth.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Providers/orders.dart';
import 'package:shop_app/Providers/products.dart';
import 'package:shop_app/screens/authentication_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

class Bindings {
  Bindings.of(this.ctx);
  final BuildContext ctx;

  final routes = {
    AuthenticationScreen.routeName: (ctx) => const AuthenticationScreen(),
    ProductsOverviewScreen.routeName: (ctx) => const ProductsOverviewScreen(),
    ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
    CartScreen.routeName: (ctx) => const CartScreen(),
    OrdersScreen.routeName: (ctx) => const OrdersScreen(),
    UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
    EditProductScreen.routeName: (ctx) => const EditProductScreen(),
  };

  final providers = [
    // auth
    ChangeNotifierProvider(
      create: (ctx) => Auth(),
    ),
    // products
    ChangeNotifierProxyProvider<Auth, Products>(
      create: (ctx) => Products([], "", ""),
      update: (ctx, auth, previewsProducts) => Products(
          previewsProducts == null ? [] : previewsProducts.items,
          auth.userId!,
          auth.userDataId!),
    ),
    // cart
    ChangeNotifierProvider(
      create: (ctx) => Cart(),
    ),
    // orders
    ChangeNotifierProxyProvider<Auth, Orders>(
      create: (ctx) => Orders("", []),
      update: (ctx, auth, presviews) =>
          Orders(auth.userDataId!, presviews == null ? [] : presviews.orders),
    ),
  ];
}
