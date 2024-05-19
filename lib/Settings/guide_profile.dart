import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Settings/guide_edit_profile.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/Utils/scaffold.dart';
import 'package:tourcompass/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:tourcompass/main.dart';

class GuideProfile extends StatefulWidget {
  const GuideProfile({Key? key}) : super(key: key);

  @override
  State<GuideProfile> createState() => _GuideProfileState();
}

class _GuideProfileState extends State<GuideProfile> {
  late Future<Map<String, dynamic>> _profileData;

  @override
  void initState() {
    super.initState();

    _profileData = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('${url}getGuide/${userToken['id']}'),
        headers: {'Authorization': 'Bearer ${token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load user profile data');
      }
    } catch (error) {
      throw Exception('Error fetching user profile data: $error');
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        Container(
          height: 1.2,
          color: const Color.fromARGB(255, 125, 122, 122),
          margin: const EdgeInsets.symmetric(vertical: 1),
        ),
      ],
    );
  }

  Future<void> _uploadPhoto() async {
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

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final decodedData = json.decode(responseData);
          final guidePhotoUrl = decodedData['secure_url'];

          // Update the guide photo URL in the database
          final updatedData = {'guidePhoto': guidePhotoUrl};
          await updateUser(updatedData);

          // Show success message
          showCustomSnackBar(context, 'Image Uploaded Successfully',
              backgroundColor: Colors.green);
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

  Future<void> updateUser(Map<String, dynamic> updatedData) async {
    final String apiUrl = '${url}updateGuide/${userToken['id']}';

    try {
      final http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        // Successful update
        print('User updated successfully');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
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
          'Personal Info',
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
      body: FutureBuilder(
        future: _profileData,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _uploadPhoto,
                              child: Column(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      data['guidePhoto'],
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Edit Photo",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    buildInfoRow('First Name', data['firstname']),
                    buildInfoRow('Last Name', data['lastname']),
                    buildInfoRow('Email', data['email']),
                    buildInfoRow('Phone Number', data['phoneNumber']),
                    buildInfoRow('License', data['licenseNumber'].toString()),
                    buildInfoRow('Guide Price', data['guidePrice'].toString()),
                    buildInfoRow('Bio', data['bio']),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: "Edit",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuideEditProfile(
                              firstName: data['firstname'],
                              lastName: data['lastname'],
                              email: data['email'],
                              phoneNumber: data['phoneNumber'],
                              licenseNumber: data['licenseNumber'],
                              guidePrice: data['guidePrice'],
                              bio: data['bio'],
                            ),
                          ),
                        ).then((_) {
                          fetchData();
                        });
                        ;
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
