import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import './product.dart';

class Products with ChangeNotifier {
  static ParseObject _productsOnServer = ParseObject("Products");
  static ParseObject _userDataOnServer = ParseObject("UsersData");

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
    print("*****user id in get products: $userId");
    print("*****data id in get products: $userDataId");
    print("Getting Products from server...");
    try {
      final ParseResponse data = await _productsOnServer.getAll();
      if (data.results != null) {
        final ParseResponse response =
            await _userDataOnServer.getObject(userDataId);
        final userData = response.result ?? {};
        final favsIDs = userData["Favorites"] ?? [];

        _items.clear();
        data.results.forEach(
          (element) {
            Product prod = new Product(
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
          },
        );
        notifyListeners();
      }
    }
    //cuostome error
    catch (error) {
      print("in getting products from server: ${error.toString()}");
      throw error;
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
    print("Adding product to server...");
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
      print("in adding products on server: ${error.toString()}");
      throw (error);
    }
  }

  Future updateProduct(String id, Product newProduct) async {
    print("Updating product in server...");
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
        print('...');
      }
    } catch (error) {
      print("in updating products on server: ${error.toString()}");
      throw error;
    }
  }

  Future deleteProduct(String id) async {
    print("Deleteing product from server...");
    try {
      await _productsOnServer.delete(
        id: items.firstWhere((element) => element.id == id).id,
      );

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
    } catch (error) {
      print("in deleting products on server: ${error.toString()}");
      throw error;
    }
  }
}
