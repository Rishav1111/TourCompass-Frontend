import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tourcompass/config.dart';
import 'package:http/http.dart' as http;
import 'package:tourcompass/guide_details.dart';

class GuideListPage extends StatefulWidget {
  final String token;

  const GuideListPage({super.key, required this.token});

  @override
  State<GuideListPage> createState() => _GuideListPageState();
}

class _GuideListPageState extends State<GuideListPage> {
  List guides = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('${url}getAllGuide'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          guides = items;
        });
      } else {
        setState(() {
          guides = [];
        });
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
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
    return ListView.builder(
        itemCount: guides.length,
        itemBuilder: (context, index) {
          return getCard(guides[index]);
        });
  }

  Widget getCard(index) {
    var firstName = index["firstname"];
    var lastName = index["lastname"];
    var guidePhotoUrl = index["guidePhoto"];
    var bio = index["bio"];
    var expertPlace = index["expertPlace"];
    var guidePrice = index["guidePrice"];

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            Icon(
                              Icons.star,
                              color: Colors.yellow[700],
                            ),
                            const Text(
                              "0",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          expertPlace.toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 94, 93, 93),
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