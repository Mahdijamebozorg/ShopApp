import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Providers/orders.dart';
import 'package:shop_app/Providers/products.dart';

import 'package:shop_app/Theme/theme.dart';

import 'package:shop_app/Constants/urls.dart';
import 'package:shop_app/Providers/bindings.dart';
import 'package:shop_app/Providers/auth.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/authentication_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

void main() async {
  //force portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Parse().initialize(
    Urls.applicationId,
    Urls.parseServerUrl,
    clientKey: Urls.clientKey,
    autoSendSessionId: true,
    debug: true,
  );
  return runApp(const ProviderBinding());
}

class ProviderBinding extends StatelessWidget {
  const ProviderBinding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // using provider
    return MultiProvider(
      providers: [
        // auth
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        // products
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products([], "", ""),
          update: (_, auth, previewsProducts) => Products(
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
          create: (_) => Orders("", []),
          update: (_, auth, presviews) => Orders(
              auth.userDataId!, presviews == null ? [] : presviews.orders),
        ),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyShop',
      theme: AppTheme.theme,

      // using auth to show main screen
      home: Consumer<Auth>(
        builder: (context, auth, _) => auth.isAuth
            ? const ProductsOverviewScreen()
            : FutureBuilder(
                // auto login
                future: auth.tryAutoLogin(),
                builder: (ctx, data) =>
                    data.connectionState == ConnectionState.waiting
                        ? const SplashScreen()
                        : const AuthenticationScreen(),
              ),
      ),
      routes: Bindings.of(context).routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
            builder: (ctx) => const ProductsOverviewScreen());
      },
    );
  }
}
