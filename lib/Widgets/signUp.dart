import 'package:flutter/material.dart';
import 'package:shop_app/providers/Auth.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  String _userName = "";
  String _password = "";
  String _emailAdress = "";
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _signUp() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      _animationController.forward();
      return;
    }
    _form.currentState!.save();
    _animationController.reverse();
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
          title: const Text("Error"),
          content: Text(response.error!.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text(
            "User was successfully created, Please verify email address before Login",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
    setState(
      () {
        _isLoading = false;
      },
    );
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (ctx, ch) => Container(
        transform: Matrix4.rotationZ(_animation.value),
        child: ch,
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.3,
          vertical: screenSize.height * 0.2,
        ),
        elevation: 20,
        child: LayoutBuilder(builder: (context, boxConstraints) {
          double formHeight = boxConstraints.maxHeight * 0.7;
          double buttonHeight = boxConstraints.maxHeight * 0.13;
          return Container(
            // transform: Matrix4.rotationZ(0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: formHeight,
                  // width: boxConstraints.maxWidth * 0.8,
                  margin: EdgeInsets.symmetric(
                    horizontal: boxConstraints.maxWidth * 0.05,
                  ),

                  child: Form(
                    key: _form,
                    child: ListView(
                      children: [
                        //_________________________________ Email
                        SizedBox(
                          height: formHeight / 3,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Email address",
                              labelStyle: TextStyle(
                                fontSize: formHeight / 3 * 0.25,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle:
                                  TextStyle(fontSize: formHeight / 3 * 0.15),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a valid email";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _emailAdress = value!;
                            },
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_usernameFocusNode),
                          ),
                        ),
                        //_________________________________ Username
                        SizedBox(
                          height: formHeight / 3,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(
                                fontSize: formHeight / 3 * 0.25,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle:
                                  TextStyle(fontSize: formHeight / 3 * 0.15),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a valid username";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _userName = value!;
                            },
                            focusNode: _usernameFocusNode,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocusNode),
                          ),
                        ),
                        //_________________________________ Password
                        SizedBox(
                          height: formHeight / 3,
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                fontSize: formHeight / 3 * 0.25,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle:
                                  TextStyle(fontSize: formHeight / 3 * 0.15),
                            ),
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a valid password";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _password = value!;
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
                SizedBox(
                  // transform: Matrix4.rotationZ(-0.05),
                  height: buttonHeight,
                  width: boxConstraints.maxWidth * 0.5,
                  child: ElevatedButton(
                    onPressed: () => _signUp(),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary)
                        : Text(
                            "Sign up",
                            style: TextStyle(fontSize: buttonHeight * 0.3),
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
