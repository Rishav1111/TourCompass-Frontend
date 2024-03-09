import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourcompass/guide_list.dart';
import 'package:tourcompass/order.dart';
import 'package:tourcompass/Settings/settings.dart';

class Home extends StatefulWidget {
  final id;
  final firstname;
  final userType;
  final token;
  const Home(
      {required this.id,
      required this.firstname,
      required this.token,
      required this.userType,
      Key? key})
      : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeContent(fName: widget.firstname, token: widget.token),
      const OrderPage(),
      Setting(
        token: widget.token,
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

class HomeContent extends StatefulWidget {
  final String fName;
  final String token;

  const HomeContent({super.key, required this.fName, required this.token});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  LatLng myLatLong = const LatLng(27.6710221, 85.4298197);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                // Navigate to the search results page when the user presses enter
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuideListPage(
                      token: widget.token,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: myLatLong,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("Home"),
                  position: myLatLong,
                  infoWindow: const InfoWindow(
                    title: 'Home',
                    snippet: 'Your current location',
                  ),
                ),
              },
            ),
          ),

          const SizedBox(height: 5),

          // Other widgets can be added below the search bar
        ],
      ),
    );
  }
}
