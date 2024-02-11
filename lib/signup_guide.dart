import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'config.dart';
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Guide, Successfully signed up!"),
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

      if (response.statusCode == 200) {
        _showSuccessDialog(context);
      } else {
        print('Failed to register user: ${response.statusCode}');
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
                                      icon: Icons.person,
                                      hintText: "First Name",
                                      controller: firstNameController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.person,
                                      hintText: "Last Name",
                                      controller: lastNameController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.email,
                                      hintText: "Email",
                                      controller: emailController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.phone,
                                      hintText: "Phone Number",
                                      controller: phoneNumberController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.lock,
                                      hintText: "Password",
                                      controller: passwordController,
                                    ),
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      icon: Icons.lock,
                                      hintText: "Confirm Password",
                                      controller: confirmPasswordController,
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
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _uploadPhoto("license");
                                            },
                                            icon: Icon(Icons.camera_alt),
                                            label: Text(licensePhotoUrl == null
                                                ? "Upload License Photo"
                                                : path.basename(
                                                    licensePhotoUrl!)),
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
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _uploadPhoto("user");
                                            },
                                            icon: Icon(Icons.camera_alt),
                                            label: Text(userPhotoUrl == null
                                                ? "Upload Your Photo"
                                                : path.basename(userPhotoUrl!)),
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
                                    Container(
                                      height: 40,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 70),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.orange[900],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          register(context);
                                        },
                                        child: Center(
                                          child: Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final VoidCallback? onUploadPressed;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.hintText,
    this.onUploadPressed,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (onUploadPressed != null)
                  IconButton(
                    icon: Icon(Icons.file_upload),
                    onPressed: onUploadPressed,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
