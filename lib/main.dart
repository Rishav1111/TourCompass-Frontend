import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:tourcompass/Login%20and%20Signup/login.dart';
import 'package:tourcompass/order.dart';

late Map<String, dynamic> userToken;
late String token;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey:
          "test_public_key_a7fd8a500862483c988ec3e4dae7146a",
      enabledDebugging: true, // Set to false for production
      builder: (context, navKey) {
        return MaterialApp(
          navigatorKey: navKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SplashScreen(),
          localizationsDelegates: const [KhaltiLocalizations.delegate],
        );
      },
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
      Duration(seconds: 1),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
