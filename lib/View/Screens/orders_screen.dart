import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Controller/order_controller.dart';

import 'package:shop_app/View/Widgets/app_drawer.dart';
import 'package:shop_app/View/Widgets/order_item.dart';


class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _orders;

  //cause we have providers, should use this method
  Future getOrders() {
    return context.read<OrderController>().getOrdersFromServer();
  }

  @override
  void initState() {
    _orders = getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = context.watch<OrderController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: orderData.orders.isEmpty
          ? const Center(child: Text("You have no orders!"))
          : FutureBuilder(
              future: _orders,
              builder: (context, data) {
                if (data.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (data.error != null) {
                  return const Center(child: Text("an error happened"));
                } else {
                  return ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  );
                }
              },
            ),
    );
  }
}
