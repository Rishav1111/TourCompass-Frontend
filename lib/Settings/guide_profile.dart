import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Settings/guide_edit_profile.dart';
import 'package:tourcompass/button.dart';

class GuideProfile extends StatefulWidget {
  final String id;
  final String token;

  const GuideProfile({required this.id, required this.token, Key? key})
      : super(key: key);

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
        Uri.parse('http://192.168.1.3:5000/api/getGuide/${widget.id}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
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
                            ClipOval(
                              child: Image.network(
                                data['licensePhoto'],
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Edit Photo",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
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
                              token: widget.token,
                              id: widget.id,
                              firstName: data['firstname'],
                              lastName: data['lastname'],
                              email: data['email'],
                              phoneNumber: data['phoneNumber'],
                              licenseNumber: data['licenseNumber'],
                              guidePrice: data['guidePrice'],
                              bio: data['bio'],
                            ),
                          ),
                        );
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
