// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:tourcompass/Login%20and%20Signup/verify_guideemail.dart';
import 'package:tourcompass/Utils/Scaffold.dart';
import 'package:tourcompass/Utils/button.dart';
import '../config.dart';

class Signup_guide extends StatefulWidget {
  const Signup_guide({super.key});

  @override
  State<Signup_guide> createState() => _SignupPageState();
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
      showCustomSnackBar(context, "Password do not match.",
          backgroundColor: Colors.red);
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
        showCustomSnackBar(context, '${jsonRespone['msg']}',
            backgroundColor: Colors.red);
        return;
      }
    } catch (e) {
      print('Exception during registration: $e');
    }
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
          showCustomSnackBar(context, 'Image Uploaded Successfully',
              backgroundColor: Colors.green);
          return;
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
                          "Sign Up as a Tour Guide",
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
                                    hintText: "First Name",
                                    controller: firstNameController,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.account_circle,
                                    hintText: "Last Name",
                                    controller: lastNameController,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.email,
                                    hintText: "Email",
                                    controller: emailController,
                                    isEmail: true,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.phone,
                                    hintText: "Phone Number",
                                    controller: phoneNumberController,
                                    isPhoneNumber: true,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.lock,
                                    hintText: "Password",
                                    controller: passwordController,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.lock,
                                    hintText: "Confirm Password",
                                    controller: confirmPasswordController,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    icon: Icons.credit_card,
                                    hintText: "Guide License No.",
                                    controller: licenseNumberController,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    controller: placeOfExpertiseController,
                                    icon: Icons.place,
                                    hintText: "Name of place of your expertise",
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    controller: guidePriceController,
                                    icon: Icons.attach_money,
                                    hintText: "Guide Price",
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _uploadPhoto("license");
                                            },
                                            child: Text(
                                              licensePhotoUrl == null
                                                  ? "Upload License Photo"
                                                  : path.basename(
                                                      licensePhotoUrl!),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Color.fromARGB(
                                                    255, 215, 210, 210),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _uploadPhoto("user");
                                            },
                                            child: Text(
                                              userPhotoUrl == null
                                                  ? "Upload your Photo"
                                                  : path
                                                      .basename(userPhotoUrl!),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Color.fromARGB(
                                                    255, 215, 210, 210),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    controller: bioController,
                                    icon: Icons.account_circle,
                                    hintText: "Bio",
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  CustomButton(
                                      text: "Sign Up",
                                      onPressed: () {
                                        register(context);
                                      }),
                                  const SizedBox(
                                    height: 5,
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
            padding: const EdgeInsets.only(left: 35, top: 5),
            child: Text(
              _validateEmail(widget.controller.text)!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (widget.isPassword &&
            _validatePassword(widget.controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(left: 35, top: 5),
            child: Text(
              _validatePassword(widget.controller.text)!,
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

    if (value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    // Password validation regex
    String passwordPattern = r'^(?=.*[A-Z])(?=.*\W)[A-Za-z\d\W]{8,}$';
    RegExp regExp = RegExp(passwordPattern);

    if (value.isNotEmpty && !regExp.hasMatch(value)) {
      return 'Password must contain at least 8 characters, one uppercase letter, and one special character';
    }
    return null;
  }

  String? _validatePhoneNumber(String value) {
    // Phone number validation
    if (value.isNotEmpty && value.length != 10) {
      return 'Phone number must have exactly 10 digits';
    }
    return null;
  }
}
