import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'package:shop_app/Model/cart.dart';
import 'package:shop_app/Model/order.dart';

class OrderController with ChangeNotifier {
  final ParseObject _serverOrders = ParseObject("UsersData");

  final String userDataId;
  OrderController(this.userDataId, this._orders);

  final List<Order> _orders;

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> getOrdersFromServer() async {
    try {
      final response = await _serverOrders.getObject(userDataId);
      if (response.result["Orders"] == null) return;

      _orders.clear();
      final List<dynamic> webOrders = response.result["Orders"];

      // add all orders
      for (var order in webOrders) {
        final List<Cart> cartItems = order["products"]
            .map(
              (cartItem) => Cart(
                title: cartItem["title"],
                price: cartItem["price"],
                quantity: cartItem["quantity"],
              ),
            )
            .toList();
        Order newOreder = Order(
          amount: order["amount"],
          dateTime: DateTime.parse(order["dateTime"]),
          products: cartItems,
        );
        _orders.add(newOreder);
      }
      notifyListeners();
    }
    //custome error
    catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> addOrder(List<Cart> cartProducts, double total) async {
    final time = DateTime.now();
    _serverOrders.setAddUnique(
      "Orders",
      {
        "amount": total,
        "dateTime": time.toIso8601String(),
        "products": cartProducts
            .map(
              (cartItem) => {
                "price": cartItem.price,
                "title": cartItem.title,
                "quantity": cartItem.quantity
              },
            )
            .toList(),
      },
    );
    try {
      _serverOrders.objectId = userDataId;
      await _serverOrders.save();
      _orders.insert(
        0,
        Order(
          amount: total,
          dateTime: time,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }
}
