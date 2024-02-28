import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Settings/edit_profile.dart';
import 'package:tourcompass/Settings/guide_edit_profile.dart';
import 'package:tourcompass/button.dart';

class GuideProfile extends StatefulWidget {
  final String id;

  const GuideProfile({required this.id, super.key});

  @override
  State<GuideProfile> createState() => _GuideProfileState();
}

class _GuideProfileState extends State<GuideProfile> {
  String firstname = "";
  String lastname = "";
  String email = "";
  String phoneNumber = "";
  int licenseNumber = 0;
  int guidePrice = 0;
  String bio = "";
  String licensePhotoUrl = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.3:5000/api/getGuide/${widget.id}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstname = data['firstname'];
          lastname = data['lastname'];
          email = data['email'];
          phoneNumber = data['phoneNumber'];
          licenseNumber = data['licenseNumber'];
          guidePrice = data['guidePrice'];
          bio = data['bio'];
          licensePhotoUrl = data['licensePhoto'];
        });
        print('License Photo: $licensePhotoUrl');
        // print('Guide Price: $guidePrice');
        // print('Bio: $bio');
      } else {
        // Handle error
        print('Failed to load user profile data');
      }
    } catch (error) {
      print('Error fetching user profile data: $error');
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
            fontSize: 16,
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
          color: Color.fromARGB(255, 125, 122, 122),
          margin: const EdgeInsets.symmetric(vertical: 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 227, 217, 1),
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.network(
                  licensePhotoUrl,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              buildInfoRow('First Name', firstname),
              buildInfoRow('Last Name', lastname),
              buildInfoRow('Email', email),
              buildInfoRow('Phone Number', phoneNumber),
              buildInfoRow('License', licenseNumber.toString()),
              buildInfoRow('Guide Price', guidePrice.toString()),
              buildInfoRow('Bio', bio),
              const SizedBox(height: 30),
              CustomButton(
                  text: "Edit",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuideEditProfile(
                          id: widget.id,
                          firstName: firstname,
                          lastName: lastname,
                          email: email,
                          phoneNumber: phoneNumber,
                          licenseNumber: licenseNumber,
                          guidePrice: guidePrice,
                          bio: bio,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
