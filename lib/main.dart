import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:shop_app/Theme/theme.dart';

import 'package:shop_app/Constants/urls.dart';
import 'package:shop_app/Providers/bindings.dart';
import 'package:shop_app/Providers/Auth.dart';
import 'package:shop_app/screens/splash-screen.dart';
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
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // using provider
    return MultiProvider(
      providers: Bindings.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyShop',
        theme: AppTheme.theme,

        // using auth to show main screen
        home: Consumer<Auth>(
          builder: (context, auth, _) => auth.isAuth
              ?  ProductsOverviewScreen()
              : FutureBuilder(
                  // auto login
                  future: auth.tryAutoLogin(),
                  builder: (ctx, data) =>
                      data.connectionState == ConnectionState.waiting
                          ?  SplashScreen()
                          :  AuthenticationScreen(),
                ),
        ),
        routes: Bindings.routes,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (ctx) =>  ProductsOverviewScreen());
        },
      ),
    );
  }
}
