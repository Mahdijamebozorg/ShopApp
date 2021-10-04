import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<Products>(context, listen: false).getProductsFromServer(),
      builder: (context, data) {
        if (data.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        else if (data.error != null) {
          return Center(
            child: Text("an error happened"),
          );
        } else {
          return Consumer<Products>(
            builder: (_, productsData, ch) {
              final products =
                  showFavs ? productsData.favoriteItems : productsData.items;
              return GridView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: products.length,
                itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                  // builder: (c) => products[i],
                  value: products[i],
                  child: ProductItem(
                      ),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              );
            },
          );
        }
      },
    );
  }
}
