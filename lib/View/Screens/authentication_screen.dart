import 'package:flutter/material.dart';

import 'package:shop_app/View/Widgets/sign_in.dart';
import 'package:shop_app/View/Widgets/sign_up.dart';

class AuthenticationScreen extends StatefulWidget {
  static const routeName = "/authentication";

  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  // pages
  int _index = 0;
  final List<Widget> _pages = [const SignIn(), const SignUp()];

  // animation
  final _animDuraton = const Duration(milliseconds: 250);
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _animDuraton);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: child,
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    _index == 0 ? "Don have an account? " : "Have an acount? "),
                TextButton(
                  onPressed: () async {
                    _animationController.reverse();
                    await Future.delayed(_animDuraton);

                    setState(() {
                      _index == 0 ? _index = 1 : _index = 0;
                    });

                    _animationController.forward();
                    await Future.delayed(_animDuraton);
                  },
                  child: Text(
                    _index == 0 ? "Sign up" : "Sign in",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: AnimatedContainer(
          duration: _animDuraton,
          width: screenSize.width * 0.8,
          height:
              _index == 0 ? screenSize.height * 0.4 : screenSize.height * 0.5,
          child: Card(
            elevation: 10,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: child,
                );
              },
              child: _pages[_index],
            ),
          ),
        ),
      ),
    );
  }
}
