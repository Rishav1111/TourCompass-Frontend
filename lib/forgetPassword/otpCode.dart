import 'package:flutter/material.dart';
import 'package:tourcompass/forgetPassword/sendEmail.dart';
import 'package:tourcompass/forgetPassword/NewPassword.dart';
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
        print("PIN verified");

        // Show snackbar message using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verified successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3), // Optional: Set the duration
          ),
        );

        // Navigate to the NewPassword page after showing the snackbar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPassword(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid Pin!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3), // Optional: Set the duration
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP resent successfully.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3), // Optional: Set the duration
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
        print("Email not sent");
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: EdgeInsets.all(30),
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
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Please enter the OTP code that you have received in the email address',
                    style: TextStyle(
                      color: Color.fromRGBO(54, 54, 54, 1),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  OTPTextField(
                    length: 4,
                    width: MediaQuery.of(context).size.width,
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldWidth: 55,
                    fieldStyle: FieldStyle.box,
                    outlineBorderRadius: 12,
                    style: TextStyle(fontSize: 20),
                    onCompleted: (pin) {
                      print("Completed: " + pin);
                      otp(context,
                          pin); // Pass the entered PIN to the otp method
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // You can also call otp(context, otpController.text) here if needed
                        otp(context, ""); // Ensure the PIN is not empty
                      },
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange[900], // Background color
                        onPrimary: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(25), // Button border radius
                        ),
                        minimumSize: Size(
                            180, 10), // Minimum button size (width, height)
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Didn't receive OTP code?",
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          SizedBox(width: 10),
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
