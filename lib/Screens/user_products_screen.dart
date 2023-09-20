import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Providers/products.dart';
import 'package:shop_app/Screens/edit_product_screen.dart';
import 'package:shop_app/Widgets/app_drawer.dart';
import 'package:shop_app/Widgets/user_product_item.dart';



class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = context.watch<Products>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(Navigator.of(context).pushReplacementNamed),
      body: productsData.userItems.isEmpty
          ? const Center(
              child: Text("You have no product yet!"),
            )
          : RefreshIndicator(
              onRefresh: () => context.read<Products>().getProductsFromServer(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: productsData.userItems.length,
                  itemBuilder: (_, i) => Column(
                    children: [
                      UserProductItem(
                        productsData.userItems[i].id,
                        productsData.userItems[i].title,
                        productsData.userItems[i].imageUrl,
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
