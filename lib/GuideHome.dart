import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class GuideHome extends StatefulWidget {
  final String token;
  const GuideHome({required this.token, Key? key}) : super(key: key);

  @override
  _GuideHomeState createState() => _GuideHomeState();
}

class _GuideHomeState extends State<GuideHome> {
  late String email;

  @override
  void initState() {
    super.initState();
    _decodeToken();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);

    email = decodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TourCompass'),
      ),
      body: Center(
        child: Text("Welcome guide,$email"),
      ),
    );
  }
}
