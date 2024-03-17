// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tourcompass/Utils/Scaffold.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/forgetPassword/send_email.dart';
import 'package:tourcompass/forgetPassword/new_password.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class VerifyOtp extends StatefulWidget {
  final String email;
  const VerifyOtp({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  bool isResending = false; // Track whether OTP is currently being resent

  void otp(BuildContext context, String pin) async {
    if (pin.isEmpty) {
      print("PIN is empty");
      return;
    }

    var otpBody = {
      'pin': pin,
      'email': widget.email,
    };

    try {
      var response = await http.post(
        Uri.parse(verifypin),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(otpBody),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'OTP verified successfully.',
            backgroundColor: Colors.green);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPassword(email: widget.email),
          ),
        );
      } else {
        showCustomSnackBar(context, 'Invalid Pin!',
            backgroundColor: Colors.green);

        print("PIN not verified");
      }
    } catch (e) {
      print(e);
    }
  }

  void resentemail() async {
    var emailBody = {
      'email': widget.email,
    };

    try {
      var response = await http.post(Uri.parse(forgetPassword),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(emailBody));

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'OTP resent successfully.',
            backgroundColor: Colors.green);
      } else {
        showCustomSnackBar(context, 'Failed to send email. Please try again.',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 30,
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SendEmail()),
                );
              },
            ),
            Center(
              child: Image.asset(
                'assets/EnterOTP.png',
                width: 200,
                height: 200,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'OTP Code',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Please enter the OTP code that you have received in the email address',
                    style: TextStyle(
                      color: Color.fromRGBO(54, 54, 54, 1),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  OTPTextField(
                    length: 4,
                    width: MediaQuery.of(context).size.width,
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldWidth: 55,
                    fieldStyle: FieldStyle.box,
                    outlineBorderRadius: 12,
                    style: const TextStyle(fontSize: 20),
                    onCompleted: (pin) {
                      print("Completed: " + pin);
                      otp(context,
                          pin); // Pass the entered PIN to the otp method
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: CustomButton(
                        text: "Verify",
                        onPressed: () {
                          otp(context, "");
                        }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Didn't receive OTP code?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            resentemail();
                            // Navigate to SignupPage
                          },
                          // Adjust the spacing as needed
                          child: Text(
                            "Resend OTP",
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
      ),
    );
  }
}
