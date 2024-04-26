import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Utils/scaffold.dart';
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Map<String, dynamic>> guideList = [];
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
        Uri.parse('${url}bookings/${userToken['id']}/guide'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        guideList = List<Map<String, dynamic>>.from(json.decode(response.body));
        print(guideList);
      } else {
        throw Exception('Failed to load guide data');
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
            : guideList.isEmpty
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
                    itemCount: guideList.length,
                    itemBuilder: (context, index) {
                      return BookingCard(
                        firstname: guideList[index]['firstname'],
                        lastname: guideList[index]['lastname'],
                        phoneNumber: guideList[index]['phoneNumber'],
                        expertPlace: guideList[index]['expertPlace'],
                        guidePhoto: guideList[index]['guidePhoto'],
                        status: guideList[index]['status'],
                        negotiatedPrice: guideList[index]['negotiatedPrice'],
                        travelDate: guideList[index]['travelDate'],
                        bookingId: guideList[index]['bookingId'],
                      );
                    },
                  ),
      ),
    );
  }
}

class BookingCard extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String? phoneNumber;
  final String? expertPlace;
  final String guidePhoto;
  final String status;
  final String? travelDate;
  final int negotiatedPrice;
  final String bookingId;

  const BookingCard({
    required this.firstname,
    required this.lastname,
    this.expertPlace,
    required this.phoneNumber,
    required this.guidePhoto,
    required this.status,
    required this.bookingId,
    this.travelDate,
    required this.negotiatedPrice,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isCancelled = false;

  Future<void> cancelBooking(String bookingId) async {
    try {
      print(bookingId);
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
        setState(() {
          _isCancelled = true;
        });
      } else {
        print('Failed to cancelling booking: ${response.body}');
      }
    } catch (error) {
      print('Error cancelling booking: $error');
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
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(60 / 2),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(widget.guidePhoto),
              ),
            ),
          ),
          title: Text(
            '${widget.firstname} ${widget.lastname}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.expertPlace ?? 'Unknown'),
                    const SizedBox(height: 4),
                    Text(
                      widget.travelDate != null
                          ? '${DateTime.parse(widget.travelDate!).month}/${DateTime.parse(widget.travelDate!).day}/${DateTime.parse(widget.travelDate!).year}'
                          : "Unknown",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.status == "Requested")
                      Text(
                        widget.status,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    else if (widget.status == "Cancelled")
                      Text(
                        widget.status,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )
                    else if (widget.status == "Completed")
                      Row(
                        children: [
                          Text(
                            widget.status,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              minimumSize: const Size(80, 10),
                            ),
                            child: const Text(
                              "Rate",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (widget.status == "Confirmed")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.status,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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
                      ),
                    if (widget.status != "Cancelled" &&
                        widget.status != "Confirmed" &&
                        widget.status != "Completed")
                      ElevatedButton(
                        onPressed: () {
                          cancelBooking(widget.bookingId);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: const Size(190, 10),
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
              ),
              Text(
                "Rs. " + widget.negotiatedPrice.toString(),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  color: Color.fromARGB(255, 229, 40, 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
