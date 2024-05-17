import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:tourcompass/notifications.dart';

class GuideHomeContent extends StatefulWidget {
  const GuideHomeContent({
    Key? key,
  }) : super(key: key);

  @override
  State<GuideHomeContent> createState() => _GuideHomeContentState();
}

class _GuideHomeContentState extends State<GuideHomeContent> {
  late GoogleMapController googleMapController;
  Position? _currentPosition;
  late final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(27.671022, 85.42982),
    zoom: 14,
  );
  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final response =
          await http.get(Uri.parse('$url/getUserLocation/${userToken['id']}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final double latitude = data['latitude'];
        final double longitude = data['longitude'];

        // Show user's last known location on the map
        _showPlaceOnMap(LatLng(latitude, longitude));
        await fetchTravelerLocation();
      } else {
        // Handle error
        print(
            'Failed to load user location. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      print('Error loading user location: $error');
    }
  }

  Future<void> fetchTravelerLocation() async {
    try {
      final response = await http
          .get(Uri.parse('$url/getTravelerLocation/${userToken['id']}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final travelerLocations = data['travelerLocation'];
        for (var travelerLocation in travelerLocations) {
          final latitude = travelerLocation['latitude'];
          final longitude = travelerLocation['longitude'];
          final markerId = MarkerId(travelerLocation['userId']);
          final marker = Marker(
            markerId: markerId,
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: 'Traveler Location'),
          );
          setState(() {
            markers.add(marker);
          });
        }
      } else {}
    } catch (error) {}
  }

  Set<Marker> markers = {};

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
        actions: [
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            iconSize: 30,
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildGoogleMap(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _determinePosition();
          _showCurrentLocation(position);
        },
        label: const Text("Current Location"),
        icon: const Icon(Icons.location_history),
      ),
    );
  }

  Future<void> _showCurrentLocation(Position position) async {
    double latitude = position.latitude;
    double longitude = position.longitude;
    String apiUrl = '$url/saveLocation';
    Map<String, dynamic> body = {
      'userId': userToken['id'],
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print(body);
        print('Location saved successfully');
      } else {
        print('Failed to save location. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error saving location: $error');
    }

    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude, longitude),
        14,
      ),
    );

    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('CurrentLocation'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
          ),
        ),
      );
    });
  }

  Future<void> _showPlaceOnMap(LatLng location) async {
    CameraPosition kSelectedPlace = CameraPosition(
      target: location,
      zoom: 12,
    );

    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(kSelectedPlace));
    setState(() {
      // Add a marker for the current location
      markers.add(Marker(
        markerId: const MarkerId('CurrentLocation'),
        position: location, // Set position to the selected location
        infoWindow: const InfoWindow(
          title: 'Current Location',
        ),
      ));
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      markers: markers,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        googleMapController = controller;
      },
    );
  }
}
