// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Login%20and%20Signup/verify_travelleremail.dart';
import 'package:tourcompass/Utils/Scaffold.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/Login%20and%20Signup/login.dart';
import 'package:tourcompass/Login%20and%20Signup/signup_guide.dart';

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
  State<CustomTextField> createState() => _CustomTextFieldState();
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
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 53,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: widget.controller,
                  obscureText: obscureText && widget.isPassword,
                  keyboardType: widget.isPhoneNumber
                      ? TextInputType.phone
                      : TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12)),
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
            padding: const EdgeInsets.only(left: 45, top: 5),
            child: Text(
              _validateEmail(widget.controller.text)!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (widget.isPassword &&
            _validatePassword(widget.controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(left: 45, top: 5),
            child: Text(
              _validatePassword(widget.controller.text)!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (widget.isPhoneNumber &&
            _validatePhoneNumber(widget.controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(left: 45, top: 5),
            child: Text(
              _validatePhoneNumber(widget.controller.text)!,
              style: const TextStyle(color: Colors.red),
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
    String passwordPattern = r'^(?=.*[A-Z])(?=.*\W)[A-Za-z\d\W]{8,}$';
    RegExp regExp = RegExp(passwordPattern);

    if (value != null && value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Password must contain at least 8 characters, one uppercase letter, and one special character';
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

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  void register(BuildContext context) async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      // Show a snackbar with an error message
      showCustomSnackBar(context, 'Please fill in all the required fields.',
          backgroundColor: Colors.red);
      return;
    }

    // Check if password and confirmed password match
    if (passwordController.text != confirmPasswordController.text) {
      // Show a snackbar with an error message
      setState(() {
        passwordController.text = '';
        confirmPasswordController.text = '';
      });
      showCustomSnackBar(context, 'Password do not match.',
          backgroundColor: Colors.red);
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

      var jsonRespone = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyTravellerEmailOtp(
              email: emailController.text,
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              password: passwordController.text,
              confirmPassword: confirmPasswordController.text,
              phoneNumber: phoneNumberController.text,
            ),
          ),
        );
      } else {
        showCustomSnackBar(context, '${jsonRespone['msg']}',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      showCustomSnackBar(context, 'Exception during registration: $e',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      width: 150,
                      height: 110,
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
              // Wrap with SingleChildScrollView
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                        const SizedBox(
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
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.account_circle,
                                    hintText: "Lastname",
                                    controller: lastNameController,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    icon: Icons.email,
                                    hintText: "Email",
                                    controller: emailController,
                                    isEmail: true,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    icon: Icons.phone,
                                    hintText: "Phone Number",
                                    controller: phoneNumberController,
                                    isPhoneNumber: true,
                                  ),
                                  const SizedBox(
                                    height: 10,
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
                                  CustomTextField(
                                    icon: Icons.lock,
                                    hintText: "Confirmed Password",
                                    controller: confirmPasswordController,
                                    isPassword: true,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomButton(
                                      text: "Sign Up",
                                      onPressed: () {
                                        register(context);
                                      }),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  const SizedBox(
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
                                        child: const Text(
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
