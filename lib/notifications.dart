import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tourcompass/config.dart';
import 'package:tourcompass/main.dart';
import 'package:tourcompass/Traveler_View/order.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
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
          setState(() {
            notifications = [];
            isLoading = false;
          });
        } else {
          final List<dynamic> jsonData = responseBody['notifications'];
          final List<NotificationItem> fetchedNotifications =
              jsonData.map((data) => NotificationItem.fromJson(data)).toList();

          fetchedNotifications
              .sort((a, b) => b.createdAt.compareTo(a.createdAt));

          setState(() {
            notifications = fetchedNotifications;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      setState(() {
        notifications = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notifications.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteAllNotifications() async {
    final isGuide = userToken["userType"] == "guide";
    final String travelerId = userToken["id"];
    final String guideId = userToken["id"];
    final apiUrl = isGuide
        ? '$url/deleteAllGuideNotifications/$guideId'
        : '$url/deleteAllTravelerNotifications/$travelerId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        await fetchNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All notifications deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete all notifications');
      }
    } catch (error) {
      print('Error deleting notifications: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notifications.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> confirmDeleteAllNotifications() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete All Notifications'),
          content: Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteAllNotifications();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: confirmDeleteAllNotifications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications found.'))
              : Padding(
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
