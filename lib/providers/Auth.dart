import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Auth with ChangeNotifier {
  final String parseServerUrl;
  final String applicationId;
  final String clientKey;
   ParseUser? _user;
   String? _userId;
   DateTime? _expireDate;
   String? _token;
   String? _userDataId;

  Auth(this.parseServerUrl, this.applicationId, this.clientKey);

  Future<ParseResponse> singUp({
    required String username,
    required String password,
    required String emailAddress,
  }) async {
    _user = ParseUser(username, password, emailAddress);

    return _user!.signUp();
  }

  Future<ParseResponse> signIn({
    required String username,
    required String password,
  }) async {
    _user = ParseUser(username, password, null);
    final ParseResponse response = await _user!.login();
    if (response.success) {
      _expireDate = DateTime.parse(response.result["createdAt"].toString())
          .add(Duration(days: 365));
      _token = response.result["sessionToken"];
      this._userId = _user!.objectId!;
      await Parse().initialize(
        applicationId,
        parseServerUrl,
        clientKey: clientKey,
        autoSendSessionId: true,
        sessionId: _token,
        debug: true,
      );
      print("user id in Auth: $userId");

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

  Future<ParseResponse> logOut() async {
    ParseUser tempUser = _user!;
    this._user = null;
    this._expireDate = null;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("UserData");

    return tempUser.logout();
  }

  Future<bool> tryAutoLogin() async {
    print("trying auto login...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("UserData")) return false;

    final Map<String, String> userData =
        json.decode(prefs.getString("UserData")!) as Map<String, String>;

    final exp = DateTime.parse(userData["expiryDate"]!);

    if (exp.isBefore(DateTime.now())) return false;

    print(userData);

    this._token = userData["token"];
    this._userId = userData["userId"];
    this._user =
        new ParseUser(userData["username"], userData["password"], null);
    this._user!.objectId = _userId;
    this._userDataId = userData["userDataId"];
    this._expireDate = DateTime.parse(userData["expiryDate"]!);

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

//_____________________________________________________________________________ checkUserData

  Future<void> checkUserData() async {
    ParseObject _serverUsersData = ParseObject("UsersData");
    ParseResponse response = await _serverUsersData.getAll();

    response.results = response.results ?? [];

    for (var i = 0; i < response.results!.length; i++) {
      if (response.results![i]["UserId"] == this.userId) {
        this._userDataId = response.results![i]["objectId"];
        notifyListeners();
        print("data id : $_userDataId");
        return;
      }
    }

    //if object hasn't created yet
    _serverUsersData.set("UserId", this.userId);
    final rsp = await _serverUsersData.create();
    this._userDataId = rsp.result["objectId"];
    notifyListeners();
  }

  void resetToken(String newToken) {
    this._token = newToken;
    notifyListeners();
  }

  bool get isAuth {
    if (_user == null)
      return false;
    else
      return (_expireDate!.isAfter(DateTime.now()));
  }

  String? get token {
    return this._token;
  }

  String? get userId {
    if (_user == null) return null;
    return this._userId;
  }

  String? get userDataId {
    return this._userDataId;
  }
}
