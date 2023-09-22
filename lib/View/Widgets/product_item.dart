import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Model/product.dart';

import 'package:shop_app/Controller/cart_controller.dart';
import 'package:shop_app/Controller/product_controller.dart';
import 'package:shop_app/View/Screens/product_detail_screen.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

bool isWating = false;

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();
    final productCtrl = context.watch<ProductController>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          leading: isWating
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: Icon(
                    productCtrl.isFav(widget.product.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () async {
                    setState(() {
                      isWating = true;
                    });
                    await productCtrl.toggleFavoriteStatus(widget.product.id);
                    setState(() {
                      isWating = false;
                    });
                  },
                ),
          subtitle: Text(
            widget.product.price.toString(),
            textAlign: TextAlign.center,
          ),
          title: Text(
            widget.product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              debugPrint(widget.product.id);
              cart.addItem(widget.product.id, widget.product.price,
                  widget.product.title);
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
                      cart.removeSingleItem(widget.product.id);
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
              arguments: widget.product.id,
            );
          },
          //a temp photo to have fade animation on loading image
          child: Hero(
            tag: widget.product.id,
            child: CachedNetworkImage(
              cacheKey: widget.product.id,
              imageUrl: widget.product.imageUrl,
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
