import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Controller/cart_controller.dart';
import 'package:shop_app/Controller/product_controller.dart';
import 'package:shop_app/View/Screens/cart_screen.dart';
import 'package:shop_app/View/Widgets/app_drawer.dart';
import 'package:shop_app/View/Widgets/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = "/ProductsOverviewScreen";

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  FilterOptions selectedFilter = FilterOptions.all;

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProductController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              setState(() {
                selectedFilter = value;
              });
            },
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favorites,
                child: Text('Only Favorites'),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text('Show All'),
              ),
            ],
          ),
          Consumer<CartController>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              // value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(() {}),
      // loading products
      body: FutureBuilder(
          future: products.getProductsFromServer(),
          builder: (context, data) {
            // on loading
            if (data.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // on error
            else if (data.error != null) {
              return Center(
                child: Text(data.error.toString()),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () => products.getProductsFromServer(),
                child: ProductsGrid(
                  onlyFavs:
                      selectedFilter == FilterOptions.favorites ? true : false,
                ),
              );
            }
          }),
    );
  }
}
