import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Controller/auth.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _password = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _signIn(BuildContext context) async {
    final auth = context.read<User>();

    if (!_form.currentState!.validate()) return;

    _form.currentState!.save();
    setState(
      () {
        _isLoading = true;
      },
    );
    final ParseResponse response =
        await auth.signIn(username: _userName.text, password: _password.text);

    if (response.error != null && context.mounted) {
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
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // form
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //_________________________________ Username
                    TextFormField(
                      controller: _userName,
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter a valid username";
                        } else {
                          return null;
                        }
                      },
                      focusNode: _usernameFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_passwordFocusNode),
                    ),
                    //_________________________________ Password
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter a valid password";
                        } else {
                          return null;
                        }
                      },
                      focusNode: _passwordFocusNode,
                      onFieldSubmitted: (_) => _signIn(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // button
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            // transform: Matrix4.rotationZ(0.05),
            height: 50,
            width: 160,
            child: ElevatedButton(
              onPressed: () => _signIn(context),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary)
                  : const Text("Sign in"),
            ),
          ),
        ],
      );
    });
  }
}
