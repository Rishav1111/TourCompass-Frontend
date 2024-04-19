import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Utils/button.dart';
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

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
                      final isConfirmed = status == 'Confirmed';
                      return BookingCard(
                        firstname: travelerList[index]['firstname'],
                        lastname: travelerList[index]['lastname'],
                        negotiatedPrice: travelerList[index]['negotiatedPrice'],
                        destination: travelerList[index]['destination'],
                        status: status,
                        travelDate: travelerList[index]['travelDate'],
                        travelerList: travelerList,
                        index: index,
                        isConfirmed: isConfirmed,
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
  final int? negotiatedPrice;
  final String? destination;
  final String? status;
  final String? travelDate;
  final List<Map<String, dynamic>> travelerList;
  final int index;
  final bool isConfirmed;

  const BookingCard({
    Key? key,
    required this.firstname,
    required this.lastname,
    required this.negotiatedPrice,
    required this.destination,
    required this.status,
    required this.travelDate,
    required this.travelerList,
    required this.index,
    required this.isConfirmed,
  }) : super(key: key);

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isConfirmed = false;
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
        setState(() {
          _isConfirmed = true;
        });
      } else {
        print('Failed to confirm booking: ${response.body}');
      }
    } catch (error) {
      print('Error confirming booking: $error');
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
              const SizedBox(height: 10),
              widget.isConfirmed
                  ? ElevatedButton(
                      onPressed: () {},
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        CustomButton(
                          text: "Confirm",
                          onPressed: () {
                            setState(() {
                              _isConfirmed = true;
                            });
                            confirmBooking(
                                widget.travelerList[widget.index]['bookingId']);
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
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
