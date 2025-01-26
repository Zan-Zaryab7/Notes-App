import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> notifications = [];
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Fetch notifications from Firestore
  Future<void> fetchNotifications() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Notifications')
          .orderBy('Date', descending: true)
          .get();

      setState(() {
        notifications = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Add document ID for reference
          return data;
        }).toList();

        // Count unread notifications
        unreadCount =
            notifications.where((note) => note['isRead'] == false).length;
      });
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final User? user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Update the UI
      fetchNotifications();
    }
  }

  // Format the date for display
  String formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('dd MMM, HH:mm').format(date);
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final collection = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Notifications');

      final batch = FirebaseFirestore.instance.batch();

      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      setState(() {
        notifications.clear();
        unreadCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        title:
            const Text("Notification", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Notifications"),
                  content: const Text(
                      "Are you sure you want to delete all notifications?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteAllNotifications();
                        Navigator.pop(context);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Container(
              //
              // Background Color Start
              //
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                tileMode: TileMode.clamp,
                colors: [
                  Color(0xFF1C1C28),
                  Color(0xFF2B2B3B),
                ],
              )),
              //
              // Background Color End
              //
              child: const Center(
                child: Text(
                  "No notifications available.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : Container(
              //
              // Background Color Start
              //
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                tileMode: TileMode.clamp,
                colors: [
                  Color(0xFF1C1C28),
                  Color(0xFF2B2B3B),
                ],
              )),
              //
              // Background Color End
              //
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final bool isRead = notification['isRead'] ?? false;

                  return GestureDetector(
                    onTap: () {
                      if (!isRead) {
                        markAsRead(notification['id']);
                      }
                    },
                    child: Card(
                      color: isRead ? Colors.white : Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      elevation: 4.0,
                      child: ListTile(
                        leading: const Icon(Icons.notifications, size: 40),
                        title: Text(
                          notification['Title'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['Body'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              "Shared By: ${notification['Shared_By'] ?? 'Unknown'}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              "Time: ${formatDate(notification['Date'])}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
