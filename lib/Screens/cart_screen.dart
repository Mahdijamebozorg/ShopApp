import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  //to prevent loop in request
  // Future _data;
  // Future _getData() async {
  // await Provider.of<Cart>(context, listen: false).getCartFromServer();
  // }

  // @override
  // void initState() {
  //   _data = _getData();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final Cart cart = Provider.of<Cart>(context);
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
                        color: Theme.of(context).primaryTextTheme.titleLarge!.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                cart.items.values.toList()[i].id,
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
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: _isLoading ? const CircularProgressIndicator() : const Text('ORDER NOW'),
      onPressed: () async {
        if (widget.cart.totalAmount > 0 && !_isLoading) {
          setState(
            () {
              _isLoading = true;
            },
          );
          await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cart.items.values.toList(),
            double.parse(widget.cart.totalAmount.toStringAsFixed(2)),
          );
          setState(
            () {
              widget.cart.clear();
              _isLoading = false;
            },
          );
        }
      },
    );
  }
}
