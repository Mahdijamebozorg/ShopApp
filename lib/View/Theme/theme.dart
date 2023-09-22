import 'package:flutter/material.dart';

class AppTheme {
  static final theme = ThemeData(
    fontFamily: 'Lato',
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
        .copyWith(secondary: Colors.deepOrange),
  );
}
