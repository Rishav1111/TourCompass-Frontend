import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const Profile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Widget buildInfoRow(String label, String value) {
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
        SizedBox(height: 18),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          height: 1.2,
          color: Colors.black,
          margin: EdgeInsets.symmetric(vertical: 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 227, 217, 1),
      appBar: AppBar(
        title: Text(
          'Profile Info',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildInfoRow('First Name', firstName),
            buildInfoRow('Last Name', lastName),
            buildInfoRow('Email', email),
            buildInfoRow('Phone Number', phoneNumber),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                primary: Colors.orange[900], // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 15), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25), // Button border radius
                ),
                minimumSize: Size(180, 10),
              ),
              child: Text(
                "Edit",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
