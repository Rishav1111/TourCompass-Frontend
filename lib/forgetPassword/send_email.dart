import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tourcompass/Login%20and%20Signup/login.dart';
import 'package:tourcompass/button.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/forgetPassword/otp_code.dart';

class SendEmail extends StatefulWidget {
  @override
  _SendEmailState createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false; // Track whether the email is currently being sent

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Email"),
          content: Text(
              "Email sent Successfully! Please check your mail for OTP code."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifyOtp(
                      email: emailController.text,
                    ),
                  ),
                  (route) => false,
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Sending email..."),
            ],
          ),
        );
      },
    );
  }

  void email(BuildContext context) async {
    if (emailController.text.isEmpty || isLoading) {
      print("Email is empty or email is already being sent.");
      return;
    }

    setState(() {
      isLoading = true; // Set loading state to true when sending email
    });

    _showLoadingDialog(context); // Show loading dialog

    var emailBody = {
      'email': emailController.text,
    };

    try {
      var response = await http.post(Uri.parse(forgetPassword),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(emailBody));

      Navigator.pop(context); // Dismiss loading dialog

      if (response.statusCode == 200) {
        _showSuccessDialog(context);
        print("Email sent");
      } else {
        setState(() {
          isLoading =
              false; // Set loading state to false if email sending failed
          emailController.text = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
        print("Email not sent");
      }
    } catch (e) {
      setState(() {
        isLoading =
            false; // Set loading state to false if email sending failed due to an error
      });
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                'assets/ForgotPassword.png',
                width: 200,
                height: 200,
              ),
            ),
            Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Forgot Password?',
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
                    'Please enter your email address to receive OTP code',
                    style: TextStyle(
                      color: Color.fromRGBO(54, 54, 54, 1),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.email),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 53,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: "Email",
                              hintStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: CustomButton(
                        text: "Send",
                        onPressed: () {
                          email(context);
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
