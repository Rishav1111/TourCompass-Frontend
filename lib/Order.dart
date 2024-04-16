import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

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
            ? Center(child: CircularProgressIndicator())
            : guideList.isEmpty
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
                    itemCount: guideList.length,
                    itemBuilder: (context, index) {
                      return BookingCard(
                        firstname: guideList[index]['firstname'],
                        lastname: guideList[index]['lastname'],
                        expertPlace: guideList[index]['expertPlace'],
                        guidePhoto: guideList[index]['guidePhoto'],
                        status: guideList[index]['status'],
                        negotiatedPrice: guideList[index]['negotiatedPrice'],
                        travelDate: guideList[index]['travelDate'],
                      );
                    },
                  ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String firstname;
  final String lastname;
  final String? expertPlace;
  final String guidePhoto;
  final String status;
  final String? travelDate;
  final int negotiatedPrice;

  const BookingCard({
    required this.firstname,
    required this.lastname,
    this.expertPlace,
    required this.guidePhoto,
    required this.status,
    this.travelDate,
    required this.negotiatedPrice,
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
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(60 / 2),
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
                    Text(expertPlace ?? 'Unknown'),
                    SizedBox(height: 4),
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
                    Text(
                      status,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Rs. " + negotiatedPrice.toString(),
                style: TextStyle(
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
