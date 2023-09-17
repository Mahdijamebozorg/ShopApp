import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _orders;

  //cause we have providers, should use this method
  Future getOrders() {
    return Provider.of<Orders>(context, listen: false).getOrdersFromServer();
  }

  @override
  void initState() {
    _orders = getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(Navigator.of(context).pushReplacementNamed),
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
