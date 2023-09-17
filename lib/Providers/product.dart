import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  final String userDataId;
  // String token;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.userId,
    required this.userDataId,
    // required this.token,
    this.isFavorite = false,
  });

  Future toggleFavoriteStatus(BuildContext context) async {
    ParseObject userDataOnServer = ParseObject("UsersData");

    if (isFavorite) {
      userDataOnServer.setRemove("Favorites", id);
    } else {
      userDataOnServer.setAddUnique("Favorites", id);
    }

    userDataOnServer.objectId = userDataId;
    await userDataOnServer.save();

    isFavorite = !isFavorite;
    notifyListeners();
  }
}
