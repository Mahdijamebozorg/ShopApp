import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Controller/product_controller.dart';
import 'package:shop_app/View/Widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool onlyFavs;
  const ProductsGrid({required this.onlyFavs, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (_, productsData, ch) {
        final products = productsData.getProduct(onlyFav: onlyFavs);
        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: products.length,
          itemBuilder: (ctx, i) => ProductItem(product: products[i]),
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
}
