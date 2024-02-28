import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tourcompass/order.dart';
import 'package:tourcompass/Settings/settings.dart';
import 'package:tourcompass/Login%20and%20Signup/login.dart';

class GuideHome extends StatefulWidget {
  final id;
  final firstname;
  final userType;
  const GuideHome(
      {required this.id,
      required this.firstname,
      required this.userType,
      Key? key})
      : super(key: key);

  @override
  State<GuideHome> createState() => GuideHomeState();
}

class GuideHomeState extends State<GuideHome> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      GuideHomeContent(fName: widget.firstname),
      const OrderPage(),
      Setting(
        id: widget.id,
        userType: widget.userType,
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

class GuideHomeContent extends StatelessWidget {
  final String fName;

  const GuideHomeContent({required this.fName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 227, 217, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
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
                'Welcome Guide, $fName',
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
