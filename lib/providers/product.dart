import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final num price;
  final String imageUrl;
  final String userId;
  final String userDataId;
  // String token;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.userId,
    this.userDataId,
    // @required this.token,
    this.isFavorite = false,
  });

  Future toggleFavoriteStatus(BuildContext context) async {
    ParseObject _userDataOnServer = new ParseObject("UsersData");

    if (this.isFavorite)
      _userDataOnServer.setRemove("Favorites", this.id);
    else
      _userDataOnServer.setAddUnique("Favorites", this.id);

    _userDataOnServer.objectId = userDataId;
    await _userDataOnServer.save();

    isFavorite = !isFavorite;
    notifyListeners();
  }
}
