import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shop_app/Model/product.dart';

class ProductController with ChangeNotifier {
  static final ParseObject _productsOnServer = ParseObject("Products");
  // static final ParseObject _userDataOnServer = ParseObject("UsersData");

  final String _userId;
  final String _userDataId;
  final List<Product> _items;
  final List<String> _favItems;
  bool gotInits = false;

  ProductController(
      this._items, this._favItems, this._userId, this._userDataId);

  Future getProductsFromServer() async {
    debugPrint("Getting Products from server...");
    try {
      final ParseResponse data = await _productsOnServer.getAll();
      log("product data: ${data.results.toString()}");
      if (data.results != null) {
        // final ParseResponse response =
        //     await _userDataOnServer.getObject(_userDataId);
        // final userData = response.result ?? {};
        // final favsIDs = userData["Favorites"] ?? [];

        _items.clear();
        for (var element in data.results!) {
          Product prod = Product(
            id: element["objectId"],
            title: element["Data"]["title"],
            description: element["Data"]["description"],
            imageUrl: element["Data"]["imageUrl"],
            price: (element["Data"]["price"]),
            userId: element["Data"]["userId"],
          );
          _items.add(prod);
        }
        notifyListeners();
      }
    }
    //cuostome error
    catch (error) {
      debugPrint("in getting products from server: ${error.toString()}");
      rethrow;
    }

    // get favs only for the first time
    debugPrint("Getting Favs from server...");
    if (!gotInits) {
      try {
        ParseObject userDataOnServer = ParseObject("UsersData");
        final ParseResponse response =
            await userDataOnServer.getObject(_userDataId);
        final userData = response.result ?? {};
        log("favs: ${userData["Favorites"].toString()}");
        if (userData["Favorites"] != null && userData["Favorites"].isNotEmpty) {
          userData["Favorites"].forEach((element) {
            _favItems.add(element.toString());
          });
        }
      }
      //cuostome error
      catch (error) {
        debugPrint("in getting favs from server: ${error.toString()}");
        rethrow;
      }
    }
  }

  List<Product> getProduct({bool onlyFav = false}) {
    if (onlyFav) {
      return _items.where((element) => _favItems.contains(element.id)).toList();
    } else {
      return [..._items];
    }
  }

  List<String> get getFavs {
    return [..._favItems];
  }

  bool isFav(String id) {
    return _favItems.contains(id);
  }

  Future toggleFavoriteStatus(String id) async {
    ParseObject userDataOnServer = ParseObject("UsersData");

    if (isFav(id)) {
      _favItems.remove(id);
      userDataOnServer.setRemove("Favorites", id);
    } else {
      _favItems.add(id);
      userDataOnServer.setAddUnique("Favorites", id);
    }

    userDataOnServer.objectId = _userDataId;
    await userDataOnServer.save();

    notifyListeners();
  }

  List<Product> get userItems {
    return _items.where((prod) => prod.userId == _userId).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future addProduct(Product product) async {
    debugPrint("Adding product to server...");
    try {
      _productsOnServer.set(
        "Data",
        {
          "title": product.title,
          "imageUrl": product.imageUrl,
          "description": product.description,
          "price": product.price,
          "userId": product.userId,
        },
      );
      ParseResponse response = await _productsOnServer.create();
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        userId: product.userId,
        id: response.result["objectId"],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      debugPrint("in adding products on server: ${error.toString()}");
      rethrow;
    }
  }

  Future updateProduct(String id, Product newProduct) async {
    debugPrint("Updating product in server...");
    try {
      final prodIndex = _items.indexWhere((prod) => prod.id == id);
      if (prodIndex >= 0) {
        _items[prodIndex] = newProduct;
        _productsOnServer.objectId = id;
        _productsOnServer.set(
          "Data",
          {
            "title": newProduct.title,
            "imageUrl": newProduct.imageUrl,
            "description": newProduct.description,
            "price": newProduct.price,
            "userId": newProduct.userId,
          },
        );
        _productsOnServer.save();
        notifyListeners();
      } else {
        debugPrint('...');
      }
    } catch (error) {
      debugPrint("in updating products on server: ${error.toString()}");
      rethrow;
    }
  }

  Future deleteProduct(String id) async {
    debugPrint("Deleteing product from server...");
    try {
      await _productsOnServer.delete(
        id: _items.firstWhere((element) => element.id == id).id,
      );

      _items.removeWhere((prod) => prod.id == id);
      _favItems.remove(id);
      notifyListeners();
    } catch (error) {
      debugPrint("in deleting products on server: ${error.toString()}");
      rethrow;
    }
  }
}
