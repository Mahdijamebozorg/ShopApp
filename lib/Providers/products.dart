import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import './product.dart';

class Products with ChangeNotifier {
  static final ParseObject _productsOnServer = ParseObject("Products");
  static final ParseObject _userDataOnServer = ParseObject("UsersData");

  final String userId;
  final String userDataId;

  Products(
    this._items,
    this.userId,
    this.userDataId,
  );

  List<Product> _items = [];
  // var _showFavoritesOnly = false;

  Future getProductsFromServer() async {
    debugPrint("*****user id in get products: $userId");
    debugPrint("*****data id in get products: $userDataId");
    debugPrint("Getting Products from server...");
    try {
      final ParseResponse data = await _productsOnServer.getAll();
      if (data.results != null) {
        final ParseResponse response =
            await _userDataOnServer.getObject(userDataId);
        final userData = response.result ?? {};
        final favsIDs = userData["Favorites"] ?? [];

        _items.clear();
        for (var element in data.results!) {
          Product prod = Product(
            id: element["objectId"],
            title: element["Data"]["title"],
            description: element["Data"]["description"],
            imageUrl: element["Data"]["imageUrl"],
            price: (element["Data"]["price"]),
            isFavorite: favsIDs.contains(element["objectId"]),
            userId: element["Data"]["userId"],
            userDataId: userDataId,
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
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get userItems {
    return _items.where((prod) => prod.userId == userId).toList();
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
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
          userDataId: product.userDataId);
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
            "isFavorite": newProduct.isFavorite,
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
        id: items.firstWhere((element) => element.id == id).id,
      );

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
    } catch (error) {
      debugPrint("in deleting products on server: ${error.toString()}");
      rethrow;
    }
  }
}
