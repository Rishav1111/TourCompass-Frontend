import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tourcompass/config.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/Traveler_View/guide_details.dart';

class GuideListPage extends StatefulWidget {
  final String? token;
  final String userId;
  final String searchedPlace;
  final String selectedDate;

  const GuideListPage(
      {super.key,
      required this.token,
      required this.userId,
      required this.searchedPlace,
      required this.selectedDate});

  @override
  State<GuideListPage> createState() => _GuideListPageState();
}

class _GuideListPageState extends State<GuideListPage> {
  List guides = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUser(widget.searchedPlace, widget.selectedDate);
  }

  Future<void> fetchUser(String searchedPlace, String selectedDate) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            '${url}getGuideBySearch?search=$searchedPlace&date=$selectedDate'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        print(searchedPlace);
        print(selectedDate);
        setState(() {
          guides = items;
          isLoading = false;
        });
      } else {
        setState(() {
          guides = [];
          isLoading = false;
        });
      }
    } catch (error) {
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Guide List',
          style: TextStyle(
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
      body: getBody(),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (guides.isEmpty) {
      return const Center(
        child: Text(
          "No guides available",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: guides.length,
        itemBuilder: (context, index) {
          return getCard(guides[index]);
        },
      );
    }
  }

  Widget getCard(Map<String, dynamic> index) {
    var firstName = index["firstname"];
    var lastName = index["lastname"];
    var guidePhotoUrl = index["guidePhoto"];
    var bio = index["bio"];
    var expertPlace = index["expertPlace"];
    var guidePrice = index["guidePrice"];
    var guideId = index["_id"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Guide_Details(
                firstName: firstName,
                lastName: lastName,
                bio: bio,
                guidePrice: guidePrice,
                guidePhotoUrl: guidePhotoUrl,
                searchedPlace: widget.searchedPlace,
                userId: widget.userId,
                selectedDate: widget.selectedDate.toString(),
                guideId: guideId,
              ),
            ),
          );
        },
        child: Card(
          // color: Color.fromARGB(255, 231, 236, 238),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(60 / 2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(guidePhotoUrl),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          expertPlace.toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 94, 93, 93),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Rs. $guidePrice",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
