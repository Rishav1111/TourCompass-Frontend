// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tourcompass/Utils/Scaffold.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
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
        if (widget.isPassword)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 5),
            child: Text(
              widget.hintText == "Current Password"
                  ? ""
                  : _validatePassword(widget.controller.text) ?? "",
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  String? _validatePassword(String value) {
    // Password validation regex
    String passwordPattern =
        r'^(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regExp = new RegExp(passwordPattern);

    if (value != null && value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Password must contain at least 8 characters, one uppercase letter, and one special character';
    }
    return null;
  }
}

class ChangePassword extends StatefulWidget {
  final String token;

  const ChangePassword({
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmNewPasswordVisible = false;

  Future<void> changePassword() async {
    // Validate input

    if (currentPasswordController.text == newPasswordController.text) {
      showCustomSnackBar(context, "Please enter New Password.",
          backgroundColor: Colors.red);
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      showCustomSnackBar(
          context, "New password and confirm password do not match.",
          backgroundColor: Colors.red);

      return;
    }

    final Map<String, dynamic> requestData = {
      'currentPassword': currentPasswordController.text,
      'newPassword': newPasswordController.text,
      'confirmNewPassword': confirmNewPasswordController.text,
    };

    try {
      final http.Response response = await http.put(
        Uri.parse('${url}/changePassword/${userToken['id']}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'Password changed successfully',
            backgroundColor: Colors.green);
        print('Password changed successfully');
      } else if (response.statusCode == 401) {
        showCustomSnackBar(context, 'Incorrect current password',
            backgroundColor: Colors.red);

        print('Incorrect current password');
      } else {
        showCustomSnackBar(
            context, 'Failed to change password. Status code: ${response.body}',
            backgroundColor: Colors.red);

        print('Failed to change password. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      showCustomSnackBar(context, 'Error changing password: $error',
          backgroundColor: Colors.red);

      print('Error changing password: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            CustomTextField(
              icon: Icons.lock,
              hintText: "Current Password",
              controller: currentPasswordController,
              isPassword: true,
            ),
            const SizedBox(
              height: 5,
            ),
            CustomTextField(
              icon: Icons.lock,
              hintText: "New Password",
              controller: newPasswordController,
              isPassword: true,
            ),
            const SizedBox(
              height: 5,
            ),
            CustomTextField(
              icon: Icons.lock,
              hintText: "Confirm New Password",
              controller: confirmNewPasswordController,
              isPassword: true,
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: CustomButton(
                text: "Change",
                onPressed: () {
                  changePassword();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
