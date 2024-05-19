import 'package:flutter/material.dart';

export 'package:flutter/material.dart' show Color;

void showCustomSnackBar(BuildContext context, String message,
    {Color backgroundColor = Colors.green}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 4),
    ),
  );
}
