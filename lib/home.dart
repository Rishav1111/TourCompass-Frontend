import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourcompass/config.dart';
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

  const HomeContent({
    Key? key,
    required this.fName,
    required this.token,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(27.6710221, 85.4298197), zoom: 14);

  Set<Marker> markers = {};
  // LatLng myLatLong = const LatLng(27.6710221, 85.4298197);
  List<String> autocompleteResults = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode =
      FocusNode(); // Add a FocusNode for the search bar

  @override
  void dispose() {
    _searchFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'TourCompass',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
        body: Stack(
          children: [
            _buildGoogleMap(),
            _buildSearchBar(),
            _buildAutocompleteList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Position position = await _determinePosition();

            googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 14)));
            markers.clear();
            markers.add(Marker(
                markerId: const MarkerId('CurrentLocation'),
                position: LatLng(position.latitude, position.longitude)));

            setState(() {});
          },
          label: const Text("Current Location"),
          icon: const Icon(Icons.location_history),
        ));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location Service are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission are permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      markers: markers,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        googleMapController = controller;
      },
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 0,
      left: 10,
      right: 10,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode, // Assign the FocusNode to the search bar
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onChanged: _fetchAutocompleteResults,
          onTap: () {
            _updateAutocompleteResults();
          },
        ),
      ),
    );
  }

  Widget _buildAutocompleteList() {
    return Visibility(
      visible: autocompleteResults.isNotEmpty &&
          _searchFocusNode
              .hasFocus, // Only show if suggestions are available and search bar is focused
      child: Positioned(
        top: kToolbarHeight + 20,
        left: 10,
        right: 10,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: autocompleteResults.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(autocompleteResults[index]),
                onTap: () {
                  _updateSearchBarText(autocompleteResults[index]);
                  _searchFocusNode
                      .unfocus(); // Unfocus the search bar after selecting a suggestion
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateSearchBarText(String newText) {
    setState(() {
      _searchController.text = newText;
    });
  }

  void _fetchAutocompleteResults(String input) async {
    String baseUrl = 'http://192.168.1.5:5000/api/autocomplete';
    String url = '$baseUrl?input=$input&radius=500';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          autocompleteResults = List<String>.from(json
              .decode(response.body)['predictions']
              .map((prediction) => prediction['description']));
        });
      } else {
        print('Failed to load autocomplete results');
      }
    } catch (error) {
      print('Error fetching autocomplete results: $error');
    }
  }

  void _updateAutocompleteResults() {
    _fetchAutocompleteResults(_searchController.text);
  }
}
