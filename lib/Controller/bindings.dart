import 'package:provider/provider.dart';

import 'package:shop_app/Controller/auth.dart';
import 'package:shop_app/Controller/cart_controller.dart';
import 'package:shop_app/Controller/order_controller.dart';
import 'package:shop_app/Controller/product_controller.dart';
import 'package:shop_app/View/Screens/authentication_screen.dart';
import 'package:shop_app/View/Screens/cart_screen.dart';
import 'package:shop_app/View/Screens/edit_product_screen.dart';
import 'package:shop_app/View/Screens/orders_screen.dart';
import 'package:shop_app/View/Screens/product_detail_screen.dart';
import 'package:shop_app/View/Screens/products_overview_screen.dart';
import 'package:shop_app/View/Screens/user_products_screen.dart';

class Bindings {
  static final routes = {
    AuthenticationScreen.routeName: (ctx) => const AuthenticationScreen(),
    ProductsOverviewScreen.routeName: (ctx) => const ProductsOverviewScreen(),
    ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
    CartScreen.routeName: (ctx) => const CartScreen(),
    OrdersScreen.routeName: (ctx) => const OrdersScreen(),
    UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
    EditProductScreen.routeName: (ctx) => const EditProductScreen(),
  };

  static final providers = [
    // auth
    ChangeNotifierProvider(
      create: (ctx) => User(),
    ),
    // products
    ChangeNotifierProxyProvider<User, ProductController>(
      create: (ctx) => ProductController([], [], "", ""),
      update: (ctx, auth, previewsProducts) => ProductController(
        previewsProducts == null ? [] : previewsProducts.getProduct(),
        previewsProducts == null ? [] : previewsProducts.getFavs,
        auth.userId!,
        auth.userDataId!,
      ),
    ),
    // cart
    ChangeNotifierProvider(
      create: (ctx) => CartController(),
    ),
    // orders
    ChangeNotifierProxyProvider<User, OrderController>(
      create: (ctx) => OrderController("", []),
      update: (ctx, auth, presviews) => OrderController(
          auth.userDataId!, presviews == null ? [] : presviews.orders),
    ),
  ];
}
