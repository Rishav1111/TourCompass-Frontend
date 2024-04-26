import 'package:flutter/material.dart';
import 'package:tourcompass/Login%20and%20Signup/login.dart';
import 'package:tourcompass/Settings/change_password.dart';
import 'package:tourcompass/Settings/guide_profile.dart';
import 'package:tourcompass/Settings/profile_info.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:http/http.dart' as http;

class SettingGestureRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SettingGestureRow({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class Setting extends StatefulWidget {
  const Setting({
    super.key,
  });

  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isSwitched = false;

  Future<void> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('${url}/deleteTraveller/${userToken['id']}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Account deleted successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        print('Failed to delete account: ${response.body}');
      }
    } catch (error) {
      print('Error deleting account: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          'Settings',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(228, 225, 222, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingGestureRow(
                    label: 'View Profile',
                    onTap: () {
                      if (userToken['userType'] == "traveller") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Profile(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuideProfile(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1.2,
                    color: Color.fromARGB(255, 54, 54, 54),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                  const SizedBox(height: 8),
                  SettingGestureRow(
                    label: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePassword(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(228, 225, 222, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isSwitched,
                          onChanged: (value) {
                            setState(() {
                              _isSwitched = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor:
                              const Color.fromRGBO(23, 230, 44, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(228, 225, 222, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red),
                        ),
                        content: const Text(
                          "Do you want to Delete Account?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Yes"),
                            onPressed: () {
                              deleteAccount();
                            },
                          ),
                          TextButton(
                            child: const Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delete Account',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: CustomButton(
                  text: "Logout",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Do you want to Logout?"),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Yes"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                                // Close the dialog
                              },
                            ),
                            TextButton(
                              child: const Text("No"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
