import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tourcompass/config.dart';

class GuideOrderPage extends StatefulWidget {
  final String id;
  const GuideOrderPage({required this.id, super.key});

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
        Uri.parse('${url}bookings/${widget.id}/traveler'),
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
            ? Center(child: CircularProgressIndicator())
            : travelerList.isEmpty
                ? Center(
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
                      return BookingCard(
                        firstname: travelerList[index]['firstname'],
                        lastname: travelerList[index]['lastname'],
                        destination: travelerList[index]['destination'],
                        status: travelerList[index]['status'],
                        travelDate: travelerList[index]['travelDate'],
                      );
                    },
                  ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String? firstname;
  final String? lastname;
  final String? destination;
  final String? status;
  final String? travelDate;

  const BookingCard({
    required this.firstname,
    required this.lastname,
    required this.destination,
    required this.status,
    required this.travelDate,
  });

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
            '${firstname ?? 'Unknown'} ${lastname ?? 'Unknown'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(destination ?? 'Unknown'),
              SizedBox(
                height: 4,
              ),
              Text(
                travelDate != null
                    ? '${DateTime.parse(travelDate!).month}/${DateTime.parse(travelDate!).day}/${DateTime.parse(travelDate!).year}'
                    : "Unknown",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Confirm'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Cancel'),
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
