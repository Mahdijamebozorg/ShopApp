import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Screens/orders_screen.dart';
import 'package:shop_app/Screens/user_products_screen.dart';
import 'package:shop_app/providers/Auth.dart';


class AppDrawer extends StatelessWidget {
  final Function _logOut;
  const AppDrawer(this._logOut, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              await context.read<Auth>().logOut();
              _logOut("/");
            },
          ),
        ],
      ),
    );
  }
}
