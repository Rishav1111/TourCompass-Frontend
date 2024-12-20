import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/Utils/scaffold.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/Utils/navbar.dart';

class Guide_Details extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int guidePrice;
  final String guidePhotoUrl;
  final String bio;
  final String guideId;
  final String userId;
  final String searchedPlace;
  final String selectedDate;

  const Guide_Details({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.guidePrice,
    required this.guidePhotoUrl,
    required this.bio,
    required this.guideId,
    required this.searchedPlace,
    required this.selectedDate,
    required this.userId,
  }) : super(key: key);

  @override
  State<Guide_Details> createState() => _Guide_DetailsState();
}

class _Guide_DetailsState extends State<Guide_Details> {
  double averageRating = 0.0;
  late int guidePrice;
  List<Map<String, dynamic>> reviews = []; // State variable to store reviews

  @override
  void initState() {
    super.initState();
    guidePrice = widget.guidePrice;
    fetchReviews();
    fetchAverageRating().then((rating) {
      setState(() {
        averageRating = rating;
      });
    });
  }

  Future<double> fetchAverageRating() async {
    try {
      final response = await http.get(
        Uri.parse('$url/getReviewByGuideId/${widget.guideId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reviews = data['travelerDetails'];

        double totalRating = 0.0;
        for (var review in reviews) {
          totalRating += review['rating'];
        }

        double averageRating = totalRating / reviews.length;

        return averageRating;
      } else {
        throw Exception(
            'Failed to fetch reviews. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
      return 0.0;
    }
  }

  // Fetch reviews from the backend
  Future<void> fetchReviews() async {
    try {
      final response = await http
          .get(Uri.parse('$url/getReviewByGuideId/${widget.guideId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reviews = List<Map<String, dynamic>>.from(data['reviews']);
        });
      } else {
        print('Failed to fetch reviews. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  // Decrease guide price
  void decreasePrice() {
    setState(() {
      if (guidePrice >= 10) {
        guidePrice -= 10;
      }
    });
  }

  // Create booking request
  Future<void> createBookingRequest(int negotiatedPrice) async {
    try {
      final requestBody = {
        'travelerId': widget.userId,
        'guideId': widget.guideId,
        'destination': widget.searchedPlace,
        'travelDate': widget.selectedDate,
        'negotiatedPrice': negotiatedPrice,
      };

      final response = await http.post(
        Uri.parse('$url/booking'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Booking requested successfully');
        showCustomSnackBar(context, "Your booking request has been sent!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      } else {
        print('Failed to create booking. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error creating booking: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${widget.firstName} ${widget.lastName} Details',
          style: const TextStyle(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(90, 0, 20, 0),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(60),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(widget.guidePhotoUrl),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow[700],
                              ),
                              const SizedBox(width: 5),
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "${widget.firstName} ${widget.lastName}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.bio,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 48,
                        width: 125,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.orange[700],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: decreasePrice,
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              guidePrice.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "All Reviews",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Container that displays the reviews
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: reviews.isEmpty
                        ? const Center(
                            child: Text(
                            "No reviews available",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display the traveler's name and rating
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${review["firstname"]} ${review["lastname"]}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (starIndex) => Icon(
                                                  starIndex < review["rating"]
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          review["feedback"],
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Send Request",
                onPressed: () async {
                  await createBookingRequest(guidePrice);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
