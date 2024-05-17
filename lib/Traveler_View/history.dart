import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:tourcompass/Traveler_View/rating_feedback.dart';
import 'dart:convert';

import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> guideList = [];
  bool isLoading = true;
  String userId = userToken["id"]; // Your user ID from the userToken map

  @override
  void initState() {
    super.initState();
    fetchGuideData();
  }

  Future<void> fetchGuideData() async {
    try {
      final response = await http.get(
        Uri.parse('${url}bookings/$userId/guide'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response and filter the guide list for "Completed" and "Cancelled" statuses
        List data = jsonDecode(response.body);
        guideList = data
            .where((guide) =>
                guide['status'] == 'Completed' ||
                guide['status'] == 'Cancelled')
            .map<Map<String, dynamic>>((guide) => guide as Map<String, dynamic>)
            .toList();
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
        centerTitle: true,
        title: const Text('Order',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
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
                    child: Text('No Orders',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )
                : ListView.builder(
                    itemCount: guideList.length,
                    itemBuilder: (context, index) {
                      final guide = guideList[index];
                      return HistoryCard(
                        guideId: guide["guideId"],
                        firstname: guide['firstname'],
                        lastname: guide['lastname'],
                        phoneNumber: guide['phoneNumber'],
                        expertPlace: guide['expertPlace'],
                        guidePhoto: guide['guidePhoto'],
                        status: guide['status'],
                        negotiatedPrice: guide['negotiatedPrice'],
                        travelDate: guide['travelDate'],
                        bookingId: guide['bookingId'],
                      );
                    },
                  ),
      ),
    );
  }
}

class HistoryCard extends StatefulWidget {
  final String guideId;
  final String firstname;
  final String lastname;
  final String? phoneNumber;
  final String? expertPlace;
  final String guidePhoto;
  final String status;
  final int negotiatedPrice;
  final String? travelDate;
  final String bookingId;

  const HistoryCard({
    required this.guideId,
    required this.firstname,
    required this.lastname,
    this.phoneNumber,
    this.expertPlace,
    required this.guidePhoto,
    required this.status,
    required this.bookingId,
    this.travelDate,
    required this.negotiatedPrice,
  });

  @override
  _HistoryCardState createState() => _HistoryCardState();
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
        padding: const EdgeInsets.all(4.0),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.expertPlace ?? 'Unknown'),
                    Text(
                      widget.travelDate != null
                          ? '${DateTime.parse(widget.travelDate!).month}/${DateTime.parse(widget.travelDate!).day}/${DateTime.parse(widget.travelDate!).year}'
                          : 'Unknown',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    if (widget.status == 'Cancelled')
                      Text(
                        widget.status,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else if (widget.status == 'Completed')
                      Row(
                        children: [
                          Text(
                            widget.status,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 40),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => RatingFeedbackDialog(
                                  guideid: widget.guideId,
                                ),
                              );
                            },
                            child: const Text('Rate'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 5),
                    if (widget.status == 'Completed')
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Choose Payment Method'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // handleCashInHand();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 32),
                                        minimumSize: const Size(200, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cash in Hand',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                        paywithKhalti(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 32),
                                        minimumSize: const Size(200, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Pay with Khalti',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Choose Payment Method'),
                      ),
                  ],
                ),
              ),
              Text(
                'Rs. ${widget.negotiatedPrice}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 229, 40, 11),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void paywithKhalti(BuildContext context) {
    KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: widget.negotiatedPrice * 100, // Convert to paisa
        productIdentity: widget.guideId,
        productName: '${widget.firstname} ${widget.lastname}',
      ),
      preferences: [
        PaymentPreference.khalti,
      ],
      onSuccess: (success) => onSuccess(context, success),
      onFailure: (failure) => onFailure(failure),
      onCancel: () => debugPrint('Khalti Payment Cancelled'),
    );
  }

  void onSuccess(BuildContext context, PaymentSuccessModel success) async {
    // Handle payment success
    final paymentData = {
      'travelerId': userToken['id'],
      'token': success.token,
      'guideId': success.productIdentity,
      'amount': success.amount,
      'guideName': success.productName,
    };

    final serverUrl = '${url}payment/confirm';

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: jsonEncode(paymentData),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Payment confirmation successful
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Payment Successful'),
              content: const Text('Your payment was successful.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to confirm payment');
      }
    } catch (error) {
      debugPrint('Error confirming payment: $error');
    }
  }

  void onFailure(PaymentFailureModel failure) {
    debugPrint('Khalti Payment Failure: $failure');
  }
}
