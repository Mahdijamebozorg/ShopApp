import 'package:flutter/foundation.dart';
// import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  // static ParseObject _cartsOnServer = new ParseObject("Cart");

  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void clearCart() {
    // _cartsOnServer.;
    _items.clear();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Future getCartFromServer() async {
  //   try {
  // final data = await _cartsOnServer.getAll();
  // if (data.results != null) {
  // _items.clear();
  // data.results.forEach(
  //   (element) {
  //     _items.putIfAbsent(
  //       element["objectId"],
  //       () => CartItem(
  //         id: element["objectId"],
  //         title: element["Data"]["title"],
  //         price: element["Data"]["price"],
  //         quantity: element["Data"]["quantity"],
  //       ),
  //     );
  //   },
  // );

  // notifyListeners();
  // }
  // }
  //custome error
  // catch (error) {
  //   debugPrint(error.toString());
  //   throw error;
  // }
  // }

  void addItem(
    String productId,
    double price,
    String title,
  ) async {
    if (_items.containsKey(productId)) {
      // change quantity...
      // debugPrint("adding item quantity");
      // CartItem existingCartItem = _items[productId];
      // debugPrint(existingCartItem.title);
      // _cartsOnServer.objectId = productId;
      // _cartsOnServer.set(
      //   "Data",
      //   {
      //     "title": existingCartItem.title,
      //     "price": existingCartItem.price,
      //     "quantity": existingCartItem.quantity + 1,
      //   },
      // );
      // await _cartsOnServer.save();
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // debugPrint("creaitng item");
      // _cartsOnServer.objectId = productId;
      // _cartsOnServer.set(
      //   "Data",
      //   {
      //     "title": title,
      //     "price": price,
      //     "quantity": 1,
      //   },
      // );
      // await _cartsOnServer.create();
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) async {
    // _cartsOnServer.objectId = productId;
    // await _cartsOnServer.delete();
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      // CartItem? existingCartItem = _items[productId];
      // _cartsOnServer.objectId = productId;
      // _cartsOnServer.set(
      //   "Data",
      //   {
      //     "title": existingCartItem.title,
      //     "price": existingCartItem.price,
      //     "quantity": existingCartItem.quantity - 1,
      //   },
      // );
      // await _cartsOnServer.save();
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      // _cartsOnServer.objectId = productId;
      // await _cartsOnServer.delete();
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
