import 'package:flutter/material.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/signup.dart';
import 'package:tourcompass/GuideHome.dart';
import 'package:tourcompass/forgetPassword/sendEmail.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/home.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  String? _validateEmail(String? value) {
    // Email validation regex
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = new RegExp(emailPattern);

    if (value != null && value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Icon(widget.icon),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: obscureText && widget.isPassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.black),
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) {
                    setState(() {}); // Trigger rebuild to update error message
                  },
                  validator: widget.isPassword ? _validateEmail : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        if (!widget.isPassword &&
            _validateEmail(widget.controller.text) != null)
          Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              _validateEmail(widget.controller.text)!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences prefs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void login(BuildContext context) async {
    // Check if any of the required fields are empty
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      print('Please fill in all the required fields.');
      return;
    }

    // Prepare the login body
    var loginBody = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    try {
      var response = await http.post(
        Uri.parse(loginUser),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginBody),
      );

      if (response.statusCode == 200) {
        // Successful login
        var responseBody = jsonDecode(response.body);
        var token = responseBody['token'];
        var userType =
            responseBody['user']['userType'] as String?; // Add null check

        if (token != null && userType != null) {
          // Save token and userType in SharedPreferences or another storage mechanism
          await prefs.setString('token', token);
          await prefs.setString('userType', userType);

          // Navigate based on userType
          if (userType == 'traveller') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(token: token),
              ),
            );
          } else if (userType == 'guide') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GuideHome(token: token),
              ),
            );
          }
        } else {
          print('Token or userType is null');
        }
      } else {
        // Login failed
        print('Failed to login user: ${response.statusCode}');
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Login Failed"),
              content: Text("Invalid email or password. Please try again."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Exception occurred during login
      print('Exception during login: $e');
      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login Error"),
            content:
                Text("An error occurred during login. Please try again later."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 69, 0, 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/Logo.png',
                      width: 200,
                      height: 150,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Navigate Your Journey with Experts",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 225, 225, 225),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(249, 225, 211, 1),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Log In",
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: <Widget>[
                                  CustomTextField(
                                    icon: Icons.email,
                                    hintText: "Email",
                                    controller: emailController,
                                  ),
                                  SizedBox(
                                    height: 17,
                                  ),
                                  CustomTextField(
                                    icon: Icons.lock,
                                    hintText: "Password",
                                    controller: passwordController,
                                    isPassword: true,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to SignupPage
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SendEmail(),
                                        ),
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: Colors.orange[900],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      login(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors
                                          .orange[900], // Background color
                                      onPrimary: Colors.white, // Text color
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15), // Button padding
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            25), // Button border radius
                                      ),
                                      minimumSize: Size(180,
                                          10), // Minimum button size (width, height)
                                    ),
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  Container(
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Don't have an account?",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              // Navigate to SignupPage
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Signup(),
                                                ),
                                              );
                                            },
                                            // Adjust the spacing as needed
                                            child: Text(
                                              "Signup",
                                              style: TextStyle(
                                                color: Colors.orange[900],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
