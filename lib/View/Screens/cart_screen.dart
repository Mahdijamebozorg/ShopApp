import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Controller/cart_controller.dart';
import 'package:shop_app/Controller/order_controller.dart';
import 'package:shop_app/View/Widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  const OrderButton()
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => Cart(
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();
    final order = context.read<OrderController>();
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('ORDER NOW'),
      onPressed: () async {
        if (cart.totalAmount > 0 && !_isLoading) {
          setState(
            () {
              _isLoading = true;
            },
          );
          await order.addOrder(
            cart.items.values.toList(),
            double.parse(cart.totalAmount.toStringAsFixed(2)),
          );
          setState(
            () {
              cart.clear();
              _isLoading = false;
            },
          );
        }
      },
    );
  }
}
