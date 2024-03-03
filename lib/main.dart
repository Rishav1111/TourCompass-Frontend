import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tourcompass/Login%20and%20Signup/admin_login.dart';
import 'package:tourcompass/Login%20and%20Signup/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminLoginPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 69, 0, 1),
      body: Center(
        child: Image.asset(
          'assets/Logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
