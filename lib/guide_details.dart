import 'package:flutter/material.dart';

class Guide_Details extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int guidePrice;
  final String guidePhotoUrl;
  final String bio;

  const Guide_Details({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.guidePrice,
    required this.guidePhotoUrl,
    required this.bio,
  }) : super(key: key);

  @override
  State<Guide_Details> createState() => _Guide_DetailsState();
}

class _Guide_DetailsState extends State<Guide_Details> {
  late int guidePrice;

  @override
  void initState() {
    super.initState();
    guidePrice = widget.guidePrice;
  }

  void increasePrice() {
    setState(() {
      guidePrice += 10;
    });
  }

  void decreasePrice() {
    setState(() {
      if (guidePrice >= 10) {
        guidePrice -= 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Text(
          '${widget.firstName} ${widget.lastName} Details',
          style: const TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 600,
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[300], // Adjusted color
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(90, 0, 20, 0),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(60),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.guidePhotoUrl),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow[700],
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "0",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  "${widget.firstName} ${widget.lastName}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900], // Adjusted color
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.bio,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 48,
                  width: 143,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.orange[700], // Adjusted color
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: decreasePrice,
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            guidePrice.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: increasePrice,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
