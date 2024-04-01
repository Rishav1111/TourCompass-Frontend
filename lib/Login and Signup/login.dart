// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/Login%20and%20Signup/signup.dart';
import 'package:tourcompass/guide_home.dart';
import 'package:tourcompass/forgetPassword/send_email.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/home.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tourcompass/Utils/scaffold.dart';

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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  String? _validateEmail(String? value) {
    // Email validation regex
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);

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
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 53,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: obscureText && widget.isPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: widget.hintText,
                    hintStyle: const TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
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
        const SizedBox(height: 5),
        if (!widget.isPassword &&
            _validateEmail(widget.controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 5),
            child: Text(
              _validateEmail(widget.controller.text)!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
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
      showCustomSnackBar(context, 'Please fill in all the required fields.',
          backgroundColor: Colors.red);
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
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        String userType = decodedToken['userType'];
        String userid = decodedToken['id'];
        String firstname = decodedToken['firstname'];
        if (token != null) {
          // Save token and userType in SharedPreferences or another storage mechanism
          await prefs.setString('token', token);
          // await prefs.setString('userType', userType);

          print("hello");
          // Navigate based on userType
          if (userType == 'traveller') {
            showCustomSnackBar(context, 'Logged in successfully!',
                backgroundColor: Colors.green);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Home(id: userid, userType: userType, token: token),
              ),
            );
          } else if (userType == 'guide') {
            showCustomSnackBar(context, 'Logged in successfully!',
                backgroundColor: Colors.green);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GuideHome(
                  id: userid,
                  firstname: firstname,
                  userType: userType,
                  token: token,
                ),
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
              title: const Text("Login Failed"),
              content:
                  const Text("Invalid email or password. Please try again."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
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
            title: const Text("Login Error"),
            content: const Text(
                "An error occurred during login. Please try again later."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
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
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 69, 0, 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30),
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
                  const Center(
                    child: Text(
                      "Navigate Your Journey with Experts",
                      style: TextStyle(
                        color: Color.fromARGB(255, 225, 225, 225),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                      const SizedBox(
                        height: 60,
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                CustomTextField(
                                  icon: Icons.email,
                                  hintText: "Email",
                                  controller: emailController,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                CustomTextField(
                                  icon: Icons.lock,
                                  hintText: "Password",
                                  controller: passwordController,
                                  isPassword: true,
                                ),
                                const SizedBox(
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
                                const SizedBox(
                                  height: 40,
                                ),
                                CustomButton(
                                    text: "Log In",
                                    onPressed: () {
                                      login(context);
                                    }),
                                const SizedBox(
                                  height: 24,
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        "Don't have an account?",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to SignupPage
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Signup(),
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
                              ],
                            ),
                          ),
                        ],
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
