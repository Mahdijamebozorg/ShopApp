import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Model/product.dart';

import 'package:shop_app/Controller/cart_controller.dart';
import 'package:shop_app/Controller/product_controller.dart';
import 'package:shop_app/View/Screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();
    final productCtrl = context.watch<ProductController>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          leading: IconButton(
            icon: Icon(
              productCtrl.isFav(product.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () => productCtrl.toggleFavoriteStatus(product.id),
          ),
          subtitle: Text(
            product.price.toString(),
            textAlign: TextAlign.center,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              debugPrint(product.id);
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Added item to cart!',
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          //a temp photo to have fade animation on loading image
          child: Hero(
            tag: product.id,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
