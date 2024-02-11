// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:tourcompass/login.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'config.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final IconData icon;
//   final String hintText;
//   final VoidCallback? onUploadPressed;

//   const CustomTextField({
//     Key? key,
//     required this.icon,
//     required this.hintText,
//     this.onUploadPressed,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         Icon(icon),
//         SizedBox(width: 10),
//         Expanded(
//           child: Container(
//             height: 45,
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.black),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     // Remove the enabled: false property
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText: hintText,
//                       hintStyle: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//                 if (onUploadPressed != null)
//                   IconButton(
//                     icon: Icon(Icons.file_upload),
//                     onPressed: onUploadPressed,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class SignupPage_Guide2 extends StatefulWidget {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String phoneNumber;
//   final String password;
//   final String confirmPassword;

//   const SignupPage_Guide2({
//     Key? key,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phoneNumber,
//     required this.password,
//     required this.confirmPassword,
//   }) : super(key: key);

//   @override
//   _SignupPage_Guide2State createState() => _SignupPage_Guide2State();
// }

// class _SignupPage_Guide2State extends State<SignupPage_Guide2> {
//   String? licensePhotoName;
//   String? userPhotoName;

//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();
//   final TextEditingController licenseNumber = TextEditingController();
//   final TextEditingController placeOfExpertise = TextEditingController();
//   final TextEditingController guidePrice = TextEditingController();
//   final TextEditingController bio = TextEditingController();

//   void register(BuildContext context) async {
//     // Check if any of the required fields are empty
//     if (licenseNumber.text.isEmpty ||
//         placeOfExpertise.text.isEmpty ||
//         guidePrice.text.isEmpty ||
//         bio.text.isEmpty) {
//       print('Please fill in all the required fields.');
//       return;
//     }

//     // Prepare the registration body
//     var regBody = {
//       'firstname': firstNameController.text,
//       'lastname': lastNameController.text,
//       'email': emailController.text,
//       'phoneNumber': phoneNumberController.text,
//       'password': passwordController.text,
//       'confirmPassword': confirmPasswordController.text,
//       'licenseNumber': licenseNumber.text,
//       'placeOfExpertise': placeOfExpertise.text,
//       'guidePrice': guidePrice.text,
//       'licensePhoto': licensePhotoName,
//       'userPhoto': userPhotoName,
//       'bio': bio.text,
//     };

//     try {
//       var response = await http.post(
//         Uri.parse(signupGuide),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(regBody),
//       );

//       if (response.statusCode == 200) {
//         // Successful registration
//         print('User registered successfully');

//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//         );

//         // Show success dialog
//       } else {
//         // Registration failed
//         print('Failed to register user: ${response.statusCode}');
//         // Display an error message or handle the failure appropriately
//       }
//     } catch (e) {
//       // Exception occurred during registration
//       print('Exception during registration: $e');
//       // Handle the exception appropriately
//     }
//   }

//   void _uploadPhoto(String type) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       // Extract the file name from the path
//       String imageName = path.basename(pickedFile.path);

//       // Update the corresponding image name state variable
//       setState(() {
//         if (type == "license") {
//           licensePhotoName = imageName;
//         } else if (type == "user") {
//           userPhotoName = imageName;
//         }
//       });
//     } else {
//       // User canceled the image selection
//     }
//   }

//   String _getFileName(String path) {
//     return path.split('/').last;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Color.fromRGBO(255, 69, 0, 1),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.all(30),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Center(
//                     child: Image.asset(
//                       'assets/Logo.png',
//                       width: 150,
//                       height: 110,
//                     ),
//                   ),
//                   Center(
//                     child: Text(
//                       "Navigate Your Journey with Experts",
//                       style: TextStyle(
//                         color: const Color.fromARGB(255, 225, 225, 225),
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color.fromRGBO(249, 225, 211, 1),
//                   borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       children: <Widget>[
//                         Text(
//                           "Sign Up as a Tour Guide",
//                           style: TextStyle(
//                             color: Colors.orange[900],
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Container(
//                           child: Column(
//                             children: <Widget>[
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: Column(
//                                   children: <Widget>[
//                                     CustomTextField(
//                                       icon: Icons.credit_card,
//                                       hintText: "Guide License No.",
//                                       controller: licenseNumber,
//                                     ),
//                                     SizedBox(height: 10),
//                                     CustomTextField(
//                                       controller: placeOfExpertise,
//                                       icon: Icons.place,
//                                       hintText:
//                                           "Name of place of your expertise",
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     CustomTextField(
//                                       controller: guidePrice,
//                                       icon: Icons.attach_money,
//                                       hintText: "Guide Price",
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: <Widget>[
//                                         Expanded(
//                                           child: ElevatedButton.icon(
//                                             onPressed: () {
//                                               _uploadPhoto("license");
//                                             },
//                                             icon: Icon(Icons.camera_alt),
//                                             label: Text(licensePhotoName ??
//                                                 "Upload License Photo"),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: <Widget>[
//                                         Expanded(
//                                           child: ElevatedButton.icon(
//                                             onPressed: () {
//                                               _uploadPhoto("user");
//                                             },
//                                             icon: Icon(Icons.camera_alt),
//                                             label: Text(userPhotoName ??
//                                                 "Upload Your Photo"),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     CustomTextField(
//                                       controller: bio,
//                                       icon: Icons.account_circle,
//                                       hintText: "Bio",
//                                     ),
//                                     SizedBox(
//                                       height: 30,
//                                     ),
//                                     Container(
//                                       height: 40,
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 70),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         color: Colors.orange[900],
//                                       ),
//                                       child: InkWell(
//                                         onTap: () {
//                                           register(context);
//                                         },
//                                         child: Center(
//                                           child: Text(
//                                             "Sign Up",
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 5,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
