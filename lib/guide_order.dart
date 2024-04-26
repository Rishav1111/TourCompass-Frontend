import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Utils/button.dart';
import 'package:tourcompass/Utils/scaffold.dart';
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideOrderPage extends StatefulWidget {
  const GuideOrderPage({super.key});

  @override
  State<GuideOrderPage> createState() => _GuideOrderPageState();
}

class _GuideOrderPageState extends State<GuideOrderPage> {
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : travelerList.isEmpty
                ? const Center(
                    child: Text(
                      'No Orders',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: travelerList.length,
                    itemBuilder: (context, index) {
                      final status = travelerList[index]['status'];
                      return BookingCard(
                        firstname: travelerList[index]['firstname'],
                        lastname: travelerList[index]['lastname'],
                        phoneNumber: travelerList[index]['phoneNumber'],
                        negotiatedPrice: travelerList[index]['negotiatedPrice'],
                        destination: travelerList[index]['destination'],
                        status: status,
                        travelDate: travelerList[index]['travelDate'],
                        travelerList: travelerList,
                        index: index,
                      );
                    },
                  ),
      ),
    );
  }
}

class BookingCard extends StatefulWidget {
  final String? firstname;
  final String? lastname;
  final String? phoneNumber;
  final int? negotiatedPrice;
  final String? destination;
  final String status;
  final String? travelDate;
  final List<Map<String, dynamic>> travelerList;
  final int index;

  const BookingCard({
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
  }) : super(key: key);

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  Future<void> confirmBooking(String bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('${url}bookings/$bookingId/updateStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'action': 'confirm'}),
      );
      if (response.statusCode == 200) {
        print('Booking confirmed successfully');
        showCustomSnackBar(context, 'Booking Confirmed',
            backgroundColor: Colors.green);
      } else {
        print('Failed to confirm booking: ${response.body}');
      }
    } catch (error) {
      print('Error confirming booking: $error');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('${url}bookings/$bookingId/updateStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'action': 'cancel'}),
      );
      if (response.statusCode == 200) {
        print('Booking cancelled successfully');
        showCustomSnackBar(context, 'Booking Cancelled',
            backgroundColor: Colors.green);
      } else {
        print('Failed to cancelling booking: ${response.body}');
      }
    } catch (error) {
      print('Error cancelling booking: $error');
    }
  }

  Future<void> completeBooking(String bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('${url}bookings/$bookingId/updateStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'action': 'complete'}),
      );
      if (response.statusCode == 200) {
        print('Booking completed successfully');
        showCustomSnackBar(context, 'Booking Completed',
            backgroundColor: Colors.green);
      } else {
        print('Failed to complete booking: ${response.body}');
      }
    } catch (error) {
      print('Error complete booking: $error');
    }
  }

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
                    ElevatedButton(
                      onPressed: () {
                        completeBooking(
                            widget.travelerList[widget.index]['bookingId']);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        minimumSize: const Size(150, 10),
                      ),
                      child: const Text(
                        "Complete",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                )
              else if (widget.status != "Cancelled" &&
                  widget.status != "Completed")
                Row(
                  children: [
                    CustomButton(
                      text: "Confirm",
                      onPressed: () {
                        confirmBooking(
                            widget.travelerList[widget.index]['bookingId']);
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        cancelBooking(
                            widget.travelerList[widget.index]['bookingId']);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        minimumSize: const Size(150, 10),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
