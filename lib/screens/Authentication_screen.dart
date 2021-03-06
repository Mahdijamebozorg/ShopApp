import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/SignIn.dart';
import 'package:flutter_complete_guide/widgets/SignUp.dart';

class AuthenticationScreen extends StatefulWidget {
  static const routeName = "/authentication";


  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int index = 0;
  List<Widget> page = [SignIn(), SignUp()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(index == 0 ? "Don have an account? " : "Have an acount? "),
              TextButton(
                onPressed: () {
                  setState(
                    () {
                      index == 0 ? index = 1 : index = 0;
                    },
                  );
                },
                child: Text(
                  index == 0 ? "Sign up" : "Sign in",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: page[index],
      ),
    );
  }
}
