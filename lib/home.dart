import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourcompass/choose_date.dart';
import 'package:tourcompass/config.dart';

class HomeContent extends StatefulWidget {
  final String token;
  final String id;

  const HomeContent({
    Key? key,
    required this.id,
    required this.token,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late GoogleMapController googleMapController;
  Position? _currentPosition;
  bool _placeSearched = false;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(27.6710221, 85.4298197), zoom: 14);

  Set<Marker> markers = {};
  List<String> autocompleteResults = [];
  List<String> selectedPlaceIds = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          _buildConfirmPlaceButton(),
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

  Widget _buildConfirmPlaceButton() {
    return Positioned(
      bottom: 90, // Adjust as per your UI requirements
      left: 0,
      right: 0,
      child: Visibility(
        visible: _placeSearched && _searchController.text.isNotEmpty,
        child: Center(
          child: SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => choose_date(
                      userId: widget.id,
                      token: widget.token,
                      searchedPlace: _searchController.text,
                      placeId: selectedPlaceIds.isNotEmpty
                          ? selectedPlaceIds[0]
                          : null,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[900],
              ),
              child: const Text(
                "Confirm Place",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onChanged: _fetchAutocompleteResults,
          onTap: _updateAutocompleteResults,
        ),
      ),
    );
  }

  Widget _buildAutocompleteList() {
    return Visibility(
      visible: autocompleteResults.isNotEmpty && _searchFocusNode.hasFocus,
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
                  _searchFocusNode.unfocus();
                  displaySuggestion(selectedPlaceIds[index]);
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
    try {
      final response = await http
          .get(Uri.parse('$url/autocomplete?input=$input&radius=500'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic>? predictions = data['responseData']['predictions'];

        if (predictions != null) {
          List<String> suggestions = [];
          List<String> placeIds = [];

          for (var prediction in predictions) {
            String description = prediction['description'];
            suggestions.add(description);
            String placeId = prediction['place_id'];
            placeIds.add(placeId);
          }

          setState(() {
            autocompleteResults = suggestions;
            selectedPlaceIds = placeIds;
          });
        } else {
          setState(() {
            autocompleteResults = [];
            selectedPlaceIds = [];
          });
        }
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

  Future<void> displaySuggestion(String placeId) async {
    String url =
        'https://map-places.p.rapidapi.com/details/json?place_id=$placeId';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        // 'X-RapidAPI-Key': '9ca9f46dc5msh278ffc74a5d57fbp1b02eajsn8c41589d1474',
        // 'X-RapidAPI-Host': 'map-places.p.rapidapi.com',
        'X-RapidAPI-Key': 'ac32ecde13mshf879c91aebb3615p16b249jsnbbd5daf1b7ca',
        'X-RapidAPI-Host': 'map-places.p.rapidapi.com'
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        double latitude = data['result']['geometry']['location']['lat'];
        double longitude = data['result']['geometry']['location']['lng'];

        LatLng selectedPlaceLocation = LatLng(latitude, longitude);
        _showPlaceOnMap(selectedPlaceLocation);
        setState(() {
          _placeSearched = true;
        });
      } else {
        print('Failed to load place details');
      }
    } catch (error) {
      print('Error fetching place details: $error');
    }
  }

  Future<void> _showPlaceOnMap(LatLng location) async {
    CameraPosition kSelectedPlace = CameraPosition(
      target: location,
      zoom: 14,
    );

    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(kSelectedPlace));

    setState(() {
      // markers.clear();
      markers.add(Marker(
        markerId: const MarkerId('SelectedPlace'),
        position: location,
        infoWindow: const InfoWindow(
          title: 'Selected Place',
          snippet: 'Place Description',
        ),
      ));

      if (_currentPosition != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('CurrentLocation'),
            position:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          ),
        );
      }
    });
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

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Handle success
        print('Location saved successfully');
      } else {
        // Handle other status codes
        print('Failed to save location. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      print('Error saving location: $error');
    }
    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude, longitude),
        14,
      ),
    );

    // markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('CurrentLocation'),
        position: LatLng(latitude, longitude),
      ),
    );

    setState(() {});
  }
}
