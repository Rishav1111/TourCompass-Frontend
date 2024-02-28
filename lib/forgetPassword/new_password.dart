import 'package:flutter/material.dart';
import 'package:tourcompass/Login%20and%20Signup/login.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/button.dart';
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/forgetPassword/otp_code.dart';
import 'package:tourcompass/password_textfield.dart' as CustomTextField;

class NewPassword extends StatefulWidget {
  final String email;
  const NewPassword({Key? key, required this.email}) : super(key: key);

  @override
  State<NewPassword> createState() => __NewPasswordState();
}

class __NewPasswordState extends State<NewPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void newPassword(BuildContext context) async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      print("Password is empty");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      print("Passwords do not match");
      return;
    }

    var newpasswordBody = {
      'email': widget.email,
      'newpassword': passwordController.text,
    };

    try {
      var response = await http.post(
        Uri.parse(resetpassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newpasswordBody),
      );

      if (response.statusCode == 200) {
        print("Password reset Successfully");

        // Show snackbar message using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset successfully.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3), // Optional: Set the duration
          ),
        );

        // Navigate to login page after showing the snackbar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        setState(() {
          passwordController.text = '';
          confirmPasswordController.text = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reset password.'),
            duration: Duration(seconds: 3), // Optional: Set the duration
          ),
        );
        print("Error reset");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(249, 225, 211, 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 30,
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            Center(
              child: Image.asset(
                'assets/NewPassword.png',
                width: 160,
                height: 160,
              ),
            ),
            Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Create New Password',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Enter your new password',
                    style: TextStyle(
                      color: Color.fromRGBO(54, 54, 54, 1),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextField.CustomTextField(
                    icon: Icons.lock,
                    hintText: "Password",
                    controller: passwordController,
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField.CustomTextField(
                    icon: Icons.lock,
                    hintText: "Confirmed Password",
                    controller: confirmPasswordController,
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 67,
                  ),
                  Center(
                    child: CustomButton(
                        text: "Change",
                        onPressed: () {
                          newPassword(context);
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
