import 'package:flutter/foundation.dart';

import 'package:shop_app/Model/cart.dart';

class CartController with ChangeNotifier {
  Map<String, Cart> _items = {};

  Map<String, Cart> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) async {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCart) => Cart(
          title: existingCart.title,
          price: existingCart.price,
          quantity: existingCart.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => Cart(
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) async {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingCart) => Cart(
                title: existingCart.title,
                price: existingCart.price,
                quantity: existingCart.quantity - 1,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
