import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:tourcompass/order.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationItem>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture = fetchNotifications();
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final isGuide = userToken["userType"] == "guide";
    final String travelerId = userToken["id"];
    final String guideId = userToken["id"];
    final apiUrl = isGuide
        ? '$url/getGuideNotification/$guideId'
        : '$url/getTravelerNotification/$travelerId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (!responseBody['success']) {
          return [];
        } else {
          final List<dynamic> jsonData = responseBody['notifications'];
          final List<NotificationItem> notifications =
              jsonData.map((data) => NotificationItem.fromJson(data)).toList();

          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return notifications;
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notifications',
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
      body: FutureBuilder<List<NotificationItem>>(
        future: notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load notifications.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          } else {
            final notifications = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(6.0),
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        title: Text(notification.message),
                        subtitle: Text(
                          _formatTime(notification.createdAt),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

// Define the NotificationItem class
class NotificationItem {
  final String message;
  final DateTime createdAt;

  NotificationItem({
    required this.message,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAtString = json['createdAt'] as String?;
    if (createdAtString == null) {
      throw Exception('CreatedAt field is null in the notification data');
    }

    final createdAt = DateTime.parse(createdAtString);

    return NotificationItem(
      message: json['message'],
      createdAt: createdAt,
    );
  }
}
