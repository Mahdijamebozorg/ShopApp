import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'package:shop_app/View/Theme/theme.dart';
import 'package:shop_app/Constants/urls.dart';
import 'package:shop_app/Controller/bindings.dart';
import 'package:shop_app/Controller/auth.dart';
import 'package:shop_app/View/Screens/splash_screen.dart';
import 'package:shop_app/View/Screens/authentication_screen.dart';
import 'package:shop_app/View/Screens/products_overview_screen.dart';

void main() async {
  //force portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  // initialize bindings to take thme to parse initializer
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
      providers: Bindings.providers,
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
      home: Consumer<User>(
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
      routes: Bindings.routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
            builder: (ctx) => const ProductsOverviewScreen());
      },
    );
  }
}
