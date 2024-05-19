import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

class Guide_Rating_Page extends StatefulWidget {
  const Guide_Rating_Page({super.key});

  @override
  State<Guide_Rating_Page> createState() => _Guide_Rating_PageState();
}

class _Guide_Rating_PageState extends State<Guide_Rating_Page> {
  List<Map<String, dynamic>> reviews = [];
  late String GuideId = userToken["id"];

  @override
  void initState() {
    super.initState();

    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final response =
          await http.get(Uri.parse('$url/getReviewByGuideId/$GuideId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reviews = List<Map<String, dynamic>>.from(data['reviews']);
          print(reviews);
        });
      } else {
        print('Failed to fetch reviews. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          title: Text(
            'Rating and Feedback',
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reviews.isEmpty
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
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                          );
                        },
                      ),
              ],
            ),
          ),
        ));
  }
}
