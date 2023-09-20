import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Providers/product.dart';
import 'package:shop_app/Screens/product_detail_screen.dart';



class ProductItem extends StatefulWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();
    final Cart cart = context.read<Cart>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => _isLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  )
                : IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await product.toggleFavoriteStatus(context);
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
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
                    label: 'UNDO',
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
            child: FadeInImage(
              placeholder: const AssetImage("assets/images/..."),
              fit: BoxFit.cover,
              image: NetworkImage(
                product.imageUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
