import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tourcompass/Order.dart';
import 'package:tourcompass/Settings.dart';
import 'package:tourcompass/login.dart';
import 'package:tourcompass/navBar.dart';

class Home extends StatefulWidget {
  final token;
  const Home({required this.token, Key? key}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  String fName = '';
  String lName = '';
  String email = '';
  String phoneNumber = '';

  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    fName = decodedToken['firstname'];
    lName = decodedToken['lastname'];
    email = decodedToken['email'];
    phoneNumber = decodedToken['phoneNumber'];

    _pages = [
      HomeContent(fName: fName),
      const OrderPage(),
      Setting(
        firstName: fName,
        lastName: lName,
        email: email,
        phoneNumber: phoneNumber,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.orange[900],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final String fName;

  const HomeContent({required this.fName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 227, 217, 1),
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        title: const Text(
          'TourCompass',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: Colors.black,
              ),
              const SizedBox(width: 10),
              Text(
                'Welcome, $fName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
