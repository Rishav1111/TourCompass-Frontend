import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:get/get.dart';
import 'Order.dart';
import 'Settings.dart';

class GuideHome extends StatefulWidget {
  final String token;
  const GuideHome({required this.token, Key? key}) : super(key: key);

  @override
  _GuideHomeState createState() => _GuideHomeState();
}

class _GuideHomeState extends State<GuideHome> {
  late String firstname;

  @override
  void initState() {
    super.initState();
    _decodeToken();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    print(decodedToken);
    firstname = decodedToken['firstname'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TourCompass, $firstname'),
      ),
    );
  }
}

// class NavigationController extends GetxController {
//   final Rx<int> selectedIndex = 0.obs;

//   // Define screens using Get.lazyPut to create them only when accessed
//   final screens = List<Widget>.generate(
//     3,
//     (index) {
//       switch (index) {
//         case 0:
//           return Container(color: Colors.green);
//         case 1:
//           return const OrderPage();
//         case 2:
//           return const Setting();
//         default:
//           throw Exception("Invalid screen index");
//       }
//     },
//   );
// }
