import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/config.dart';
import 'package:tourcompass/login.dart';
import 'package:tourcompass/signup_guide.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final bool isEmail;
  final bool isPhoneNumber;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isEmail = false,
    this.isPhoneNumber = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

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
                height: 53,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: widget.controller,
                  obscureText: obscureText && widget.isPassword,
                  keyboardType: widget.isPhoneNumber
                      ? TextInputType.phone
                      : TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12)),
                    labelText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  onChanged: (value) {
                    setState(() {
                      // Handle validation based on widget type
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        if (widget.isEmail && _validateEmail(widget.controller.text) != null)
          Padding(
            padding: EdgeInsets.only(left: 35, top: 5),
            child: Text(
              _validateEmail(widget.controller.text)!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (widget.isPassword &&
            _validatePassword(widget.controller.text) != null)
          Padding(
            padding: EdgeInsets.only(left: 35, top: 5),
            child: Text(
              _validatePassword(widget.controller.text)!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (widget.isPhoneNumber &&
            _validatePhoneNumber(widget.controller.text) != null)
          Padding(
            padding: EdgeInsets.only(left: 35, top: 5),
            child: Text(
              _validatePhoneNumber(widget.controller.text)!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  String? _validateEmail(String value) {
    // Email validation regex
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = new RegExp(emailPattern);

    if (value != null && value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    // Password validation regex
    String passwordPattern = r'^.{8,}$';
    RegExp regExp = new RegExp(passwordPattern);

    if (value != null && value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Password must contain at least 8 characters';
    }
    return null;
  }

  String? _validatePhoneNumber(String value) {
    // Phone number validation
    if (value != null && value.isNotEmpty && value.length != 10) {
      return 'Phone number must have exactly 10 digits';
    }
    return null;
  }
}

class Signup extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Function to show a dialog with a success message
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Successfully signed up!"),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Your existing register function
  void register(BuildContext context) async {
    // Check if any of the required fields are empty
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      print('Please fill in all the required fields.');
      return;
    }

    // Prepare the registration body
    var regBody = {
      'firstname': firstNameController.text,
      'lastname': lastNameController.text,
      'email': emailController.text,
      'phoneNumber': phoneNumberController.text,
      'password': passwordController.text,
      'confirmPassword': confirmPasswordController.text,
    };

    try {
      var response = await http.post(
        Uri.parse(signupTraveller),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        // Successful registration
        print('User registered successfully');
        // Show success dialog
        _showSuccessDialog(context);
      } else {
        // Registration failed
        print('Failed to register user: ${response.statusCode}');
        // Display an error message or handle the failure appropriately
      }
    } catch (e) {
      // Exception occurred during registration
      print('Exception during registration: $e');
      // Handle the exception appropriately
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
                      width: 150,
                      height: 110,
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
              // Wrap with SingleChildScrollView
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(249, 225, 211, 1),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: <Widget>[
                                  CustomTextField(
                                    icon: Icons.account_circle,
                                    hintText: "Firstname",
                                    controller: firstNameController,
                                  ),
                                  SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.account_circle,
                                    hintText: "Lastname",
                                    controller: lastNameController,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    icon: Icons.email,
                                    hintText: "Email",
                                    controller: emailController,
                                    isEmail: true,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    icon: Icons.phone,
                                    hintText: "Phone Number",
                                    controller: phoneNumberController,
                                    isPhoneNumber: true,
                                  ),
                                  SizedBox(
                                    height: 10,
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
                                  CustomTextField(
                                    icon: Icons.lock,
                                    hintText: "Confirmed Password",
                                    controller: confirmPasswordController,
                                    isPassword: true,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      register(context);
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
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
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
                                                      LoginPage(),
                                                ),
                                              );
                                            },
                                            // Adjust the spacing as needed
                                            child: Text(
                                              "Login",
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
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to SignupPage
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Signup_guide(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Signup as a Tour Guide",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
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
            ),
          ],
        ),
      ),
    );
  }
}
