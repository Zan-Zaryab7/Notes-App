import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notey_task/Views/Notes/Add_Notes.dart';
import 'package:notey_task/Views/Notes/Edit_Notes.dart';
import 'package:intl/intl.dart';
import 'package:notey_task/Views/Notifications/Notifications.dart'; // Import for formatting dates

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Save UserName from Users
  String userName = "";

  //
  // Fetch User from Users Collection
  Future<void> fetchUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName =
              userDoc['Name']; // Fetch the 'name' field from Firestore document
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Save Note Details from Notes
  List<Map<String, dynamic>> notes = [];

  //
  // Fetch My Notes from Users Sub-Collection Notes
  Future<void> fetchNotes() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot notesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Notes')
            .orderBy('Date', descending: true)
            .get();

        setState(() {
          notes = notesSnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  //
  // Shere Note Method
  Future<void> shareNote(String recipientUid, Map<String, dynamic> note) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('User not logged in.');
        return;
      }

      // Save shared note in recipient's Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(recipientUid)
          .collection('Shared_Notes')
          .add({
        "Title": note['Title'],
        "Body": note['Body'],
        "Shared_By": user.email,
        "Date": FieldValue.serverTimestamp(),
      });

      print('Note successfully shared in Firestore.');
    } catch (e) {
      print('Error sharing note: $e');
    }
  }

  //
  // Save Notification Method
  Future<void> notification(
      String recipientUid, Map<String, dynamic> note) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('User not logged in.');
        return;
      }

      // Save shared note in recipient's Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(recipientUid)
          .collection('Notifications')
          .add({
        "Title": note['Title'],
        "Body": note['Body'],
        "Shared_By": user.email,
        'isRead': false, // Set default as false
        "Date": FieldValue.serverTimestamp(),
      });

      print('Notification saved in Firestore.');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  //
  // Fetch unread notifications count
  int unreadCount = 0;

  Future<void> fetchUnreadNotifications() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Notifications')
          .where('isRead', isEqualTo: false)
          .get();

      setState(() {
        unreadCount = snapshot.docs.length; // Count unread notifications
      });
    }
  }

  void initState() {
    super.initState();
    fetchUser();
    fetchNotes();
    fetchUnreadNotifications();
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a') // Format the date as needed
        .format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    // Size for Responsiveness
    final size = MediaQuery.of(context).size;

    return Scaffold(
      //
      // Add Notes Button Start
      //
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Add_Notes()));
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: Icon(Icons.add, color: Colors.white, size: size.width * 0.065),
      ),
      //
      // Add Notes Button End
      //

      //
      // Body Start
      //
      body: Container(
        width: size.width,
        height: size.height,
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
        child: Column(
          children: [
            //
            // Appbar Start
            //
            Container(
              color: const Color(0xFF1C1C28),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 5, left: 5, right: 5),
                          child: Container(
                            width: size.width * 0.095,
                            height: size.height * 0.07,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black38,
                                image: DecorationImage(
                                    image: NetworkImage(
                                        "assets/profile_picture.jpg"),
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.025),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.035),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Notifications()),
                            ).then((_) =>
                                fetchUnreadNotifications()); // Refresh unread count on return
                          },
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: size.width * 0.06,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    )
                  ],
                ),
              ),
            ),
            //
            // Appbar End
            //

            //
            // Home Start
            //
            // My Notes Section
            Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
                child: Text(
                  "My Notes:",
                  style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Text(
                        'No Notes Available',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two items per row
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B2B3B),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                // Note Details
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note['Title'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.04,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      note['Body'],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: size.width * 0.035,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatDate(note['Date']),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: size.width * 0.03,
                                      ),
                                    ),
                                  ],
                                ),

                                // Popup Menu
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      //
                                      // Edit Note Link
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Edit_Notes(noteId: note['id']),
                                          ),
                                        ).then((_) =>
                                            fetchNotes()); // Refresh notes after editing
                                      }
                                      //
                                      // Delete Note Dialog
                                      else if (value == 'delete') {
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Delete Note"),
                                            content: const Text(
                                                "Are you sure you want to delete this note?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmDelete) {
                                          try {
                                            // Delete note from Firestore
                                            User? user = FirebaseAuth
                                                .instance.currentUser;
                                            if (user != null) {
                                              await FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(user.uid)
                                                  .collection('Notes')
                                                  .doc(note['id'])
                                                  .delete();

                                              // Refresh notes after deletion
                                              fetchNotes();

                                              // Show success message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "Note deleted successfully")),
                                              );
                                            }
                                          } catch (e) {
                                            // Show error message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Error deleting note: $e")),
                                            );
                                          }
                                        }
                                      }
                                      //
                                      // Share Note Dialog
                                      else if (value == 'share') {
                                        // Share functionality
                                        TextEditingController emailController =
                                            TextEditingController();

                                        bool confirmShare = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Share Note"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    "Enter the recipient's email address:"),
                                                TextField(
                                                  controller: emailController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        "Recipient's Email",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("Share"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmShare) {
                                          if (emailController.text.isNotEmpty) {
                                            // Share note functionality
                                            String recipientEmail =
                                                emailController.text.trim();
                                            try {
                                              QuerySnapshot userQuery =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Users')
                                                      .where('Email',
                                                          isEqualTo:
                                                              recipientEmail)
                                                      .get();

                                              if (userQuery.docs.isNotEmpty) {
                                                // User exists
                                                String recipientUid =
                                                    userQuery.docs.first.id;

                                                // Share note functionality
                                                shareNote(recipientUid, note);
                                                // Save the Notifications
                                                notification(
                                                    recipientUid, note);
                                                fetchUnreadNotifications();
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Error sharing note: $e")),
                                              );
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Email field is empty")));
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text("Edit"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text("Delete"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Text("Share"),
                                      ),
                                    ],
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: size.width * 0.05,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
            //
            // Home End
            //
          ],
        ),
      ),
      //
      // Body End
      //
    );
  }
}
