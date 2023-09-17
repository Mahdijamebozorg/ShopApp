import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Auth with ChangeNotifier {
  final String parseServerUrl = Urls.parseServerUrl;
  final String applicationId = Urls.applicationId;
  final String clientKey = Urls.clientKey;
  ParseUser? _user;
  String? _userId;
  DateTime? _expireDate;
  String? _token;
  String? _userDataId;

  Auth();

  Future<ParseResponse> singUp({
    required String username,
    required String password,
    required String emailAddress,
  }) async {
    _user = ParseUser(username, password, emailAddress);

    return _user!.signUp();
  }

//_____________________________________________________________________________

  Future<ParseResponse> signIn({
    required String username,
    required String password,
  }) async {
    _user = ParseUser(username, password, null);
    final ParseResponse response = await _user!.login();
    if (response.success) {
      _expireDate = DateTime.parse(response.result["createdAt"].toString())
          .add(const Duration(days: 365));
      _token = response.result["sessionToken"];
      _userId = _user!.objectId!;
      await Parse().initialize(
        applicationId,
        parseServerUrl,
        clientKey: clientKey,
        autoSendSessionId: true,
        sessionId: _token,
        debug: true,
      );
      debugPrint("user id in Auth: $userId");

      //checking userData
      await checkUserData();

      //save data in device
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          "username": _user!.username,
          "password": _user!.password,
          "token": token,
          "userId": userId,
          "expiryDate": _expireDate!.toIso8601String(),
          "userDataId": _userDataId,
        },
      );
      await prefs.setString("UserData", userData);

      notifyListeners();
    }
    return response;
  }

//_____________________________________________________________________________

  Future<ParseResponse> logOut() async {
    ParseUser tempUser = _user!;
    _user = null;
    _expireDate = null;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("UserData");

    return tempUser.logout();
  }

//_____________________________________________________________________________

  Future<bool> tryAutoLogin() async {
    debugPrint("trying auto login...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("UserData")) return false;

    final Map<String, String> userData =
        json.decode(prefs.getString("UserData")!) as Map<String, String>;

    final exp = DateTime.parse(userData["expiryDate"]!);

    if (exp.isBefore(DateTime.now())) return false;

    debugPrint(userData.toString());

    _token = userData["token"];
    _userId = userData["userId"];
    _user =
        ParseUser(userData["username"], userData["password"], null);
    _user!.objectId = _userId;
    _userDataId = userData["userDataId"];
    _expireDate = DateTime.parse(userData["expiryDate"]!);

    await Parse().initialize(
      applicationId,
      parseServerUrl,
      clientKey: clientKey,
      autoSendSessionId: true,
      sessionId: _token,
      debug: true,
    );

    notifyListeners();
    return true;
  }

//_____________________________________________________________________________

  Future<void> checkUserData() async {
    ParseObject serverUsersData = ParseObject("UsersData");
    ParseResponse response = await serverUsersData.getAll();

    response.results = response.results ?? [];

    for (var i = 0; i < response.results!.length; i++) {
      if (response.results![i]["UserId"] == userId) {
        _userDataId = response.results![i]["objectId"];
        notifyListeners();
        debugPrint("data id : $_userDataId");
        return;
      }
    }

    //if object hasn't created yet
    serverUsersData.set("UserId", userId);
    final rsp = await serverUsersData.create();
    _userDataId = rsp.result["objectId"];
    notifyListeners();
  }

//_____________________________________________________________________________

  void resetToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

//_____________________________________________________________________________

  bool get isAuth {
    if (_user == null) {
      return false;
    } else {
      return (_expireDate!.isAfter(DateTime.now()));
    }
  }

//_____________________________________________________________________________

  String? get token {
    return _token;
  }

//_____________________________________________________________________________

  String? get userId {
    if (_user == null) return null;
    return _userId;
  }

//_____________________________________________________________________________

  String? get userDataId {
    return _userDataId;
  }
}
