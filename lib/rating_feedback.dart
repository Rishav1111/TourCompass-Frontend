import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tourcompass/Utils/scaffold.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';

class RatingFeedbackDialog extends StatefulWidget {
  final String guideid;

  const RatingFeedbackDialog({
    super.key,
    required this.guideid,
  });

  @override
  State<RatingFeedbackDialog> createState() => _RatingFeedbackDialogState();
}

class _RatingFeedbackDialogState extends State<RatingFeedbackDialog> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> submitRatingFeedback(
      String guideId, String travelerId, double rating, String feedback) async {
    try {
      // Create the review data as a JSON object
      final Map<String, dynamic> reviewData = {
        'guideId': guideId,
        'travelerId': travelerId,
        'rating': rating,
        'feedback': feedback,
      };
      final response = await http.post(
        Uri.parse("${url}createReview"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(reviewData),
      );
      if (response.statusCode == 201) {
        showCustomSnackBar(context, 'Review submitted successfully',
            backgroundColor: Colors.green);
      } else {
        showCustomSnackBar(context, 'Failed to submit review',
            backgroundColor: Colors.red);
      }
    } catch (error) {
      showCustomSnackBar(context, 'An error occurred',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text(
        'Rate and Feedback',
      )),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display a prompt to rate the experience
            const Text('Please rate your experience'),
            const SizedBox(height: 10),
            // Use a RatingBar from flutter_rating_bar package
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            submitRatingFeedback(widget.guideid, userToken['id'], _rating,
                _feedbackController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
