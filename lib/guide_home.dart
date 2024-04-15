import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourcompass/config.dart';

class GuideHomeContent extends StatefulWidget {
  final String token;
  final String id;

  const GuideHomeContent({
    Key? key,
    required this.id,
    required this.token,
  }) : super(key: key);

  @override
  State<GuideHomeContent> createState() => _GuideHomeContentState();
}

class _GuideHomeContentState extends State<GuideHomeContent> {
  late GoogleMapController googleMapController;
  Position? _currentPosition;
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _getInitialCameraPosition();
  }

  Future<void> _getInitialCameraPosition() async {
    try {
      final String apiUrl = '${url}getUserLocation/${widget.id}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final double latitude = data['latitude'];
        final double longitude = data['longitude'];

        setState(() {
          _initialCameraPosition =
              CameraPosition(target: LatLng(latitude, longitude), zoom: 14);
        });
      } else {
        throw Exception('Failed to fetch initial camera position');
      }
    } catch (e) {
      print('Error fetching initial camera position: $e');
      // Handle error
    }
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
      'userId': widget.id,
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
