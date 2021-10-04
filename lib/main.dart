import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_complete_guide/providers/Auth.dart';
import 'package:flutter_complete_guide/screens/Authentication_screen.dart';
import 'package:flutter_complete_guide/screens/splash-screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';

void main() async {
  //force portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  const String parseServerUrl = "https://parseapi.back4app.com";
  const String applicationId = "5BtCJeNbypmMYuboAQtGR1yF1s5ZSynUmoltMq5M";
  const String clientKey = "d3uN0RKn1Ndjz8qRlzk9UcsIobXSCMzuDWO5PS8X";
  await new Parse().initialize(
    applicationId,
    parseServerUrl,
    clientKey: clientKey,
    autoSendSessionId: true,
    debug: true,
  );
  return runApp(MyApp(parseServerUrl, applicationId, clientKey));
}

class MyApp extends StatelessWidget {
  final String parseServerUrl;
  final String applicationId;
  final String clientKey;
  MyApp(this.parseServerUrl, this.applicationId, this.clientKey);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(parseServerUrl, applicationId, clientKey),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products([], "", ""),
          update: (ctx, auth, previewsProducts) => Products(
              previewsProducts == null ? [] : previewsProducts.items,
              auth.userId,
              auth.userDataId),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders("", []),
          update: (ctx, auth, presviews) => Orders(
              auth.userDataId, presviews == null ? [] : presviews.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          // home: auth.isAuth ? ProductsOverviewScreen() : AuthenticationScreen(),
          // initialRoute: "/",
          routes: {
            "/": (ctx) {
              return auth.isAuth
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, data) =>
                          data.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthenticationScreen(),
                    );
            },
            AuthenticationScreen.routeName: (ctx) => AuthenticationScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
                builder: (ctx) => ProductsOverviewScreen());
          },
        ),
      ),
    );
  }
}
