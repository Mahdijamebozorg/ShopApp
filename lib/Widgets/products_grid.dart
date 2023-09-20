import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/products.dart';
import 'package:shop_app/Widgets/product_item.dart';


class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  const ProductsGrid(this.showFavs, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          context.read<Products>().getProductsFromServer(),
      builder: (context, data) {
        if (data.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (data.error != null) {
          return const Center(
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
                  child: const ProductItem(),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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