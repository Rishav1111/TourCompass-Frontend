import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/config.dart';

class OrderPage extends StatefulWidget {
  final String id;
  const OrderPage({required this.id, super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String firstname = '';
  String lastname = '';
  String expertPlace = '';
  String guidePhoto = '';
  String status = '';
  String travelDate = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch guide data when the widget is initialized
    fetchGuideData();
  }

  Future<void> fetchGuideData() async {
    try {
      final response = await http.get(
        Uri.parse('${url}bookings/${widget.id}/guide'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> guideList = json.decode(response.body);

        if (guideList.isNotEmpty) {
          final guideData = guideList[0] as Map<String, dynamic>;

          setState(() {
            firstname = guideData['firstname'];
            lastname = guideData['lastname'];
            expertPlace = guideData['expertPlace'];
            guidePhoto = guideData['guidePhoto'];
            status = guideData['status'];
            travelDate = guideData['travelDate'];
            isLoading = false;
          });
        } else {
          throw Exception('No guide data found');
        }
      } else {
        throw Exception('Failed to load guide data');
      }
    } catch (error) {
      print('Error fetching guide data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          'Order',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Expanded(
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : firstname.isNotEmpty
                          ? ListView(
                              shrinkWrap: true,
                              children: [
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(60 / 2),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(guidePhoto),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '$firstname $lastname',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(expertPlace),
                                          SizedBox(
                                              height:
                                                  4), // Add spacing between subtitle text and status
                                          Text(
                                            'Booking Status: $status',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Text(
                                            'Travel Date: ${travelDate != null ? '${DateTime.parse(travelDate).month}/${DateTime.parse(travelDate).day}/${DateTime.parse(travelDate).year}' : "Unknown"}',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'No Orders',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
