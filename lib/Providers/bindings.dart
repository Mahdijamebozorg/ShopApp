import 'package:shop_app/providers/Auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/authentication_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

class Bindings {
  static final routes = {
    AuthenticationScreen.routeName: (ctx) => AuthenticationScreen(),
    ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
    ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
    CartScreen.routeName: (ctx) => CartScreen(),
    OrdersScreen.routeName: (ctx) => OrdersScreen(),
    UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
    EditProductScreen.routeName: (ctx) => const EditProductScreen(),
  };

  static final providers = [
    // auth
    ChangeNotifierProvider(
      create: (_) => Auth(),
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
      create: (_) => Cart(),
    ),
    // orders
    ChangeNotifierProxyProvider<Auth, Orders>(
      create: (ctx) => Orders("", []),
      update: (ctx, auth, presviews) =>
          Orders(auth.userDataId!, presviews == null ? [] : presviews.orders),
    ),
  ];
}
