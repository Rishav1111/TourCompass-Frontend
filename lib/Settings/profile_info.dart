import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Settings/edit_profile.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String firstname = "";
  String lastname = "";
  String email = "";
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    String myToken = token;
    fetchData(myToken);
  }

  Future<void> fetchData(String myToken) async {
    try {
      final response = await http.get(
        Uri.parse('${url}getTraveller/${userToken['id']}'),
        headers: {'Authorization': 'Bearer $myToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstname = data['firstname'];
          lastname = data['lastname'];
          email = data['email'];
          phoneNumber = data['phoneNumber'];
        });
      } else {
        print(
            'Failed to load user profile data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
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
          color: Color.fromARGB(255, 125, 122, 122),
          margin: const EdgeInsets.symmetric(vertical: 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildInfoRow('First Name', firstname),
            buildInfoRow('Last Name', lastname),
            buildInfoRow('Email', email),
            buildInfoRow('Phone Number', phoneNumber),
            const SizedBox(height: 30),
            CustomButton(
                text: "Edit",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile(
                        firstName: firstname,
                        lastName: lastname,
                        email: email,
                        phoneNumber: phoneNumber,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
