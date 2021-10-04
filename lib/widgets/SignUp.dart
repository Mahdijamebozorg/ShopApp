import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/Auth.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _form = GlobalKey<FormState>();
  String _userName;
  String _password;
  String _emailAdress;
  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _signUp() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) return;
    _form.currentState.save();
    setState(
      () {
        _isLoading = true;
      },
    );
    final ParseResponse response =
        await Provider.of<Auth>(context, listen: false).singUp(
      username: _userName,
      password: _password,
      emailAddress: _emailAdress,
    );
    if (response.error != null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(response.error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            )
          ],
        ),
      );
    } else
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success!"),
          content: Text(
            "User was successfully created, Please verify email address before Login",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            )
          ],
        ),
      );
    setState(
      () {
        _isLoading = false;
      },
    );
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Size _screenSize = MediaQuery.of(context).size;
    return Container(
      transform: Matrix4.rotationZ(-0.05),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: _screenSize.width * 0.3,
          vertical: _screenSize.height * 0.2,
        ),
        elevation: 20,
        child: LayoutBuilder(builder: (context, boxConstraints) {
          double _formHeight = boxConstraints.maxHeight * 0.7;
          double _buttonHeight = boxConstraints.maxHeight * 0.13;
          return Container(
            transform: Matrix4.rotationZ(0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: _formHeight,
                  // width: boxConstraints.maxWidth * 0.8,
                  margin: EdgeInsets.symmetric(
                    horizontal: boxConstraints.maxWidth * 0.05,
                  ),

                  child: Form(
                    key: _form,
                    child: ListView(
                      children: [
                        //_________________________________ Email
                        Container(
                          height: _formHeight / 3,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Email address",
                              labelStyle: TextStyle(
                                fontSize: _formHeight / 3 * 0.25,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle:
                                  TextStyle(fontSize: _formHeight / 3 * 0.15),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value.isEmpty)
                                return "Enter a valid email";
                              else
                                return null;
                            },
                            onSaved: (value) {
                              _emailAdress = value;
                            },
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_usernameFocusNode),
                          ),
                        ),
                        //_________________________________ Username
                        Container(
                          height: _formHeight / 3,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(
                                fontSize: _formHeight / 3 * 0.25,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle:
                                  TextStyle(fontSize: _formHeight / 3 * 0.15),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value.isEmpty)
                                return "Enter a valid username";
                              else
                                return null;
                            },
                            onSaved: (value) {
                              _userName = value;
                            },
                            focusNode: _usernameFocusNode,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocusNode),
                          ),
                        ),
                        //_________________________________ Password
                        Container(
                          height: _formHeight / 3,
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                fontSize: _formHeight / 3 * 0.25,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle:
                                  TextStyle(fontSize: _formHeight / 3 * 0.15),
                            ),
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value.isEmpty)
                                return "Enter a valid password";
                              else
                                return null;
                            },
                            onSaved: (value) {
                              _password = value;
                            },
                            focusNode: _passwordFocusNode,
                            onFieldSubmitted: (_) => _signUp(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxHeight * 0.1,
                ),
                Container(
                  // transform: Matrix4.rotationZ(-0.05),
                  height: _buttonHeight,
                  width: boxConstraints.maxWidth * 0.5,
                  child: ElevatedButton(
                    onPressed: () => _signUp(),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).accentColor)
                        : Text(
                            "Sign up",
                            style: TextStyle(fontSize: _buttonHeight * 0.3),
                          ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
