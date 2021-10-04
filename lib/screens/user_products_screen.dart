import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
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
      body: productsData.userItems.length == 0
          ? Center(
              child: Text("You have no product yet!"),
            )
          : RefreshIndicator(
              onRefresh: () => Provider.of<Products>(context, listen: false)
                  .getProductsFromServer(),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: productsData.userItems.length,
                  itemBuilder: (_, i) => Column(
                    children: [
                      UserProductItem(
                        productsData.userItems[i].id,
                        productsData.userItems[i].title,
                        productsData.userItems[i].imageUrl,
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
