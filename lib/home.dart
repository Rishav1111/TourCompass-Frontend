import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Home extends StatefulWidget {
  final String token;
  const Home({required this.token, Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String email;

  @override
  void initState() {
    super.initState();
    _decodeToken();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    print(decodedToken);
    email = decodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TourCompass'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person), // Replace 'Icons.person' with your desired icon
            SizedBox(
                width: 10), // Adjust spacing between icon and text as needed
            Text("Welcome, $email"),
          ],
        ),
      ),
    );
  }
}
