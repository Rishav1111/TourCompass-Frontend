import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tourcompass/Settings/profile_info.dart';
import 'package:tourcompass/button.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  CustomTextField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            TextFormField(
              controller: controller,
              style: TextStyle(
                fontSize: 20,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class EditProfile extends StatefulWidget {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  EditProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the initial values for the controllers
    firstNameController.text = widget.firstName;
    lastNameController.text = widget.lastName;
    emailController.text = widget.email;
    phoneNumberController.text = widget.phoneNumber;
  }

  Future<void> updateUser(Map<String, dynamic> updatedData) async {
    final String apiUrl =
        'http://192.168.1.3:5000/api/updateTraveller/${widget.id}';

    try {
      final http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        // Successful update
        print('User updated successfully');
        print(updatedData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              id: widget.id,
            ),
          ),
        );
      } else {
        // Handle API error
        print('Failed to update user. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error updating user: $error');
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    Map<String, dynamic> updatedData = {
      'firstname': firstNameController.text,
      'lastname': lastNameController.text,
      'email': emailController.text,
      'phoneNumber': phoneNumberController.text,
    };

    try {
      await updateUser(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile Updated Successfullly!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3), // Optional: Set the duration
        ),
      );
    } catch (error) {
      // Handle errors and show an error alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fail to update Profile'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3), // Optional: Set the duration
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(255, 227, 217, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: firstNameController,
              label: 'First Name',
            ),
            CustomTextField(
              controller: lastNameController,
              label: 'Last Name',
            ),
            CustomTextField(
              controller: emailController,
              label: 'Email',
            ),
            CustomTextField(
              controller: phoneNumberController,
              label: 'Phone Number',
            ),
            SizedBox(height: 35),
            Center(
              child: CustomButton(
                  text: "Save",
                  onPressed: () {
                    updateProfile(context);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
