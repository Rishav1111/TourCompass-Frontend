import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:tourcompass/Login%20and%20Signup/verify_guideemail.dart';
import 'package:tourcompass/button.dart';
import '../config.dart';
import 'login.dart';

class Signup_guide extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<Signup_guide> {
  String? licensePhotoUrl;
  String? userPhotoUrl;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController placeOfExpertiseController =
      TextEditingController();
  final TextEditingController guidePriceController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  void register(BuildContext context) async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        licenseNumberController.text.isEmpty ||
        placeOfExpertiseController.text.isEmpty ||
        guidePriceController.text.isEmpty ||
        bioController.text.isEmpty ||
        licensePhotoUrl == null ||
        userPhotoUrl == null) {
      print('Please fill in all the required fields.');
      return;
    }
    // Check if password and confirmed password match
    if (passwordController.text != confirmPasswordController.text) {
      // Show a snackbar with an error message
      setState(() {
        passwordController.text = '';
        confirmPasswordController.text = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Password and confirmed password do not match.",
            style: TextStyle(color: Colors.white), // Set text color
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red, // Set background color to red
        ),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(signupGuide),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'firstname': firstNameController.text,
          'lastname': lastNameController.text,
          'email': emailController.text,
          'phoneNumber': phoneNumberController.text,
          'password': passwordController.text,
          'confirmPassword': confirmPasswordController.text,
          'licenseNumber': licenseNumberController.text,
          'expertPlace': placeOfExpertiseController.text,
          'guidePrice': guidePriceController.text,
          'licensePhoto': licensePhotoUrl,
          'guidePhoto': userPhotoUrl,
          'bio': bioController.text,
        }),
      );
      var jsonRespone = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyGuideEmailOtp(
              email: emailController.text,
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              password: passwordController.text,
              phoneNumber: phoneNumberController.text,
              licenseNumber: licenseNumberController.text,
              expertPlace: placeOfExpertiseController.text,
              guidePrice: guidePriceController.text,
              licensePhoto: licensePhotoUrl,
              guidePhoto: userPhotoUrl,
              bio: bioController.text,
            ),
          ),
        );
      } else {
        print('Failed to register user: ${response.statusCode}');
        showSnackbar(context, '${jsonRespone['msg']}');
      }
    } catch (e) {
      print('Exception during registration: $e');
    }
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white), // Set text color
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red, // Set background color to red
      ),
    );
  }

  Future<void> _uploadPhoto(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final url =
            Uri.parse('https://api.cloudinary.com/v1_1/dxk0tmis1/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'tn0z9oer'
          ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path,
              filename: path.basename(pickedFile.path)));

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var decodedData = json.decode(responseData);
          setState(() {
            if (type == "license") {
              licensePhotoUrl = decodedData['secure_url'];
            } else if (type == "user") {
              userPhotoUrl = decodedData['secure_url'];
            }
          });
        } else {
          print('Failed to upload image: ${response.statusCode}');
        }
      } catch (e) {
        print('Exception during image upload: $e');
      }
    } else {
      // User canceled the image selection
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
                          "Sign Up as a Tour Guide",
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
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
                                      icon: Icons.account_circle,
                                      hintText: "First Name",
                                      controller: firstNameController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.account_circle,
                                      hintText: "Last Name",
                                      controller: lastNameController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.email,
                                      hintText: "Email",
                                      controller: emailController,
                                      isEmail: true,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.phone,
                                      hintText: "Phone Number",
                                      controller: phoneNumberController,
                                      isPhoneNumber: true,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.lock,
                                      hintText: "Password",
                                      controller: passwordController,
                                      isPassword: true,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.lock,
                                      hintText: "Confirm Password",
                                      controller: confirmPasswordController,
                                      isPassword: true,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.credit_card,
                                      hintText: "Guide License No.",
                                      controller: licenseNumberController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      controller: placeOfExpertiseController,
                                      icon: Icons.place,
                                      hintText:
                                          "Name of place of your expertise",
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    CustomTextField(
                                      controller: guidePriceController,
                                      icon: Icons.attach_money,
                                      hintText: "Guide Price",
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: SizedBox(
                                            height: 53,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                _uploadPhoto("license");
                                              },
                                              icon: Icon(Icons.camera_alt),
                                              label: Text(
                                                  licensePhotoUrl == null
                                                      ? "Upload License Photo"
                                                      : path.basename(
                                                          licensePhotoUrl!)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: SizedBox(
                                            height: 53,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                _uploadPhoto("user");
                                              },
                                              icon: Icon(Icons.camera_alt),
                                              label: Text(userPhotoUrl == null
                                                  ? "Upload Your Photo"
                                                  : path
                                                      .basename(userPhotoUrl!)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    CustomTextField(
                                      controller: bioController,
                                      icon: Icons.account_circle,
                                      hintText: "Bio",
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    CustomButton(
                                        text: "Sign Up",
                                        onPressed: () {
                                          register(context);
                                        }),
                                    SizedBox(
                                      height: 5,
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
            ),
          ],
        ),
      ),
    );
  }
}

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
    String passwordPattern =
        r'^(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regExp = new RegExp(passwordPattern);

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
