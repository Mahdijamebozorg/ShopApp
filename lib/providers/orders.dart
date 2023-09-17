import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import './cart.dart';

class OrderItem {
  // final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  // final String userDataId;

  OrderItem({
    // required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    // required this.userDataId,
  });
}

class Orders with ChangeNotifier {
  ParseObject _serverOrders = new ParseObject("UsersData");

  final String userDataId;
  Orders(this.userDataId, this._orders);
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> getOrdersFromServer() async {
    try {
      final _response = await _serverOrders.getObject(userDataId);
      if (_response.result["Orders"] == null) return;

      _orders.clear();
      final List<dynamic> _webOrders = _response.result["Orders"];
      _webOrders.forEach(
        (element) {
          final List<dynamic> _products = element["products"];
          final List<CartItem> _listedProds = _products
              .map(
                (cartItem) => new CartItem(
                  id: cartItem["id"],
                  title: cartItem["title"],
                  price: cartItem["price"],
                  quantity: cartItem["quantity"],
                ),
              )
              .toList();
          OrderItem _newOreder = new OrderItem(
            // id: element["objectId"],
            amount: element["amount"],
            dateTime: DateTime.parse(element["dateTime"]),
            products: _listedProds,
          );
          _orders.add(_newOreder);
        },
      );
      notifyListeners();
    }
    //custome error
    catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final time = DateTime.now();
    _serverOrders.setAddUnique(
      "Orders",
      {
        "amount": total,
        "dateTime": time.toIso8601String(),
        "products": cartProducts
            .map(
              (cartItem) => {
                "id": cartItem.id,
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
        OrderItem(
          // id: _response.result["objectId"],
          amount: total,
          dateTime: time,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }
}
