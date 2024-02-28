import 'package:flutter/material.dart';
import 'package:tourcompass/button.dart';

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
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 53,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: widget.controller,
                  obscureText: obscureText && widget.isPassword,
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
        if (widget.isPassword &&
            _validatePassword(widget.controller.text) != null)
          Padding(
            padding: EdgeInsets.only(left: 40, top: 5),
            child: Text(
              _validatePassword(widget.controller.text)!,
              style: TextStyle(color: Colors.red),
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
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 227, 217, 1),
      appBar: AppBar(
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
            SizedBox(
              height: 30,
            ),
            CustomTextField(
              icon: Icons.lock,
              hintText: "Current Password",
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              icon: Icons.lock,
              hintText: "New Password",
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              icon: Icons.lock,
              hintText: "Confirmed New Password",
              controller: confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(
              height: 30,
            ),
            Center(child: CustomButton(text: "Change", onPressed: () {})),
          ],
        ),
      ),
    );
  }
}
