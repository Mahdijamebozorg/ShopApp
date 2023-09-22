import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shop_app/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class User with ChangeNotifier {
  final String parseServerUrl = Urls.parseServerUrl;
  final String applicationId = Urls.applicationId;
  final String clientKey = Urls.clientKey;
  ParseUser? _user;
  String? _userId;
  DateTime? _expireDate;
  String? _token;
  String? _userDataId;

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
    debugPrint("Signin in...");
    final ParseResponse response = await _user!.login();
    if (response.success) {
      _expireDate = DateTime.parse(response.result["createdAt"].toString())
          .add(const Duration(days: 365));

      _token = response.result["sessionToken"];
      _userId = _user!.objectId!;

      log("user token: $_token");
      log("user id: $_userId");

      await Parse().initialize(
        applicationId,
        parseServerUrl,
        clientKey: clientKey,
        autoSendSessionId: true,
        sessionId: _token,
        debug: true,
      );

      //checking userData
      await checkUserData();

      //save data in device
      debugPrint("saving login data ...");
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

    if (!prefs.containsKey("UserData")) {
      log("no login data found!");
      return false;
    }

    final userData =
        json.decode(prefs.getString("UserData")!) as Map<String, dynamic>;

    log("login data: ${userData.toString()}");

    final exp = DateTime.parse(userData["expiryDate"]!);
    if (exp.isBefore(DateTime.now())) {
      log("user is expired!");
      return false;
    }

    _token = userData["token"];
    _userId = userData["userId"];
    _user = ParseUser(userData["username"], userData["password"], null);
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
    debugPrint("checking user data...");
    ParseObject serverUsersData = ParseObject("UsersData");
    ParseResponse response = await serverUsersData.getAll();

    response.results = response.results ?? [];

    for (var i = 0; i < response.results!.length; i++) {
      if (response.results![i]["UserId"] == userId) {
        _userDataId = response.results![i]["objectId"];
        notifyListeners();
        return;
      }
    }

    //if object hasn't created yet
    serverUsersData.set("UserId", userId);
    final rsp = await serverUsersData.create();
    _userDataId = rsp.result["objectId"];

    log("userDataId: $_userDataId");

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
