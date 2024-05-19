import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Traveler_View/history.dart';
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/Utils/scaffold.dart';
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideHistoryPage extends StatefulWidget {
  const GuideHistoryPage({super.key});

  @override
  State<GuideHistoryPage> createState() => _GuideHistoryPageState();
}

class _GuideHistoryPageState extends State<GuideHistoryPage> {
  List<Map<String, dynamic>> travelerList = [];
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
        Uri.parse('${url}bookings/${userToken['id']}/traveler'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        travelerList =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        print(travelerList);
      } else {
        throw Exception('Failed to load traveler data');
      }
    } catch (error) {
      print('Error fetching guide data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedAndCancelledBookings = travelerList.where((booking) {
      return booking['status'] == 'Completed' ||
          booking['status'] == 'Cancelled';
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          'History',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : completedAndCancelledBookings.isEmpty
                ? const Center(
                    child: Text(
                      'No History ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: completedAndCancelledBookings.length,
                    itemBuilder: (context, index) {
                      return HistoryCard(
                          firstname: completedAndCancelledBookings[index]
                              ['firstname'],
                          lastname: completedAndCancelledBookings[index]
                              ['lastname'],
                          phoneNumber: completedAndCancelledBookings[index]
                              ['phoneNumber'],
                          negotiatedPrice: completedAndCancelledBookings[index]
                              ['negotiatedPrice'],
                          destination: completedAndCancelledBookings[index]
                              ['destination'],
                          status: completedAndCancelledBookings[index]
                              ['status'],
                          travelDate: completedAndCancelledBookings[index]
                              ['travelDate'],
                          travelerList: completedAndCancelledBookings,
                          index: index,
                          paymentStatus: completedAndCancelledBookings[index]
                              ['paymentStatus']);
                    },
                  ),
      ),
    );
  }
}

class HistoryCard extends StatefulWidget {
  final String? firstname;
  final String? lastname;
  final String? phoneNumber;
  final int? negotiatedPrice;
  final String paymentStatus;
  final String? destination;
  final String status;
  final String? travelDate;
  final List<Map<String, dynamic>> travelerList;
  final int index;

  const HistoryCard({
    Key? key,
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    required this.negotiatedPrice,
    required this.destination,
    required this.status,
    required this.travelDate,
    required this.travelerList,
    required this.index,
    required this.paymentStatus,
  }) : super(key: key);

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            '${widget.firstname ?? 'Unknown'} ${widget.lastname ?? 'Unknown'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.destination ?? 'Unknown'),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.travelDate != null
                        ? '${DateTime.parse(widget.travelDate!).month}/${DateTime.parse(widget.travelDate!).day}/${DateTime.parse(widget.travelDate!).year}'
                        : "Unknown",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    widget.negotiatedPrice != null
                        ? "Rs. ${widget.negotiatedPrice.toString()}"
                        : "Unknown",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 229, 40, 11),
                    ),
                  ),
                ],
              ),
              if (widget.status == "Cancelled")
                Text(
                  widget.status,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (widget.status == "Completed")
                Text(
                  widget.status,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (widget.status == "Confirmed" &&
                  widget.status != "Cancelled")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 50,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          Uri phoneUri =
                              Uri.parse('tel:+977${widget.phoneNumber}');

                          if (await launchUrl(phoneUri)) {
                            print('Phone dialer opened successfully');
                          } else {
                            print('Failed to open phone dialer');
                          }
                        },
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              Text(
                'Payment: ${widget.paymentStatus}',
                style: TextStyle(
                  color: Color.fromARGB(255, 6, 6, 158),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
