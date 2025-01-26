import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notey_task/Views/Notes/Add_Notes.dart';
import 'package:notey_task/Views/Notes/Edit_Notes.dart';
import 'package:intl/intl.dart';
import 'package:notey_task/Views/Notes/Search_Notes.dart'; // Import for formatting dates

class Notes extends StatefulWidget {
  Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  // Save My_Note Details from Notes
  List<Map<String, dynamic>> myNote = [];

  // Fetch My Notes from Users Sub-Collection Notes
  Future<void> fetchMyNotes() async {
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
          myNote = notesSnapshot.docs
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

  // Save Shared_Note Details from Shared_Notes
  List<Map<String, dynamic>> sharedNotes = [];

  // Fetch Shared Notes from Users Sub-Collection Shared_Notes
  Future<void> fetchSharedNotes() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        // Check if the user document exists
        if (userDoc.exists) {
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('Shared_Notes')
              .orderBy('Date', descending: true)
              .get();

          // Check if there are any documents in the Shared_Notes collection
          if (snapshot.docs.isNotEmpty) {
            sharedNotes = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                ...data,
                'id': doc.id, // Optionally include the document ID
              };
            }).toList();
          } else {
            print("No shared notes available");
          }
        } else {
          print("User document does not exist");
        }
      }
    } catch (e) {
      print("Error fetching shared notes: $e");
    } finally {
      setState(() {});
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

      // Refresh Shared Notes
      fetchSharedNotes();

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

  void initState() {
    super.initState();
    fetchMyNotes();
    fetchSharedNotes();
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a') // Format the date as needed
        .format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    // Size for responsiveness
    Size size = MediaQuery.of(context).size;

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
      // Appbar Start
      //
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        title: const Text(
          "Notes",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          //
          // Search Bar
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Search_Notes()));
            },
          ),
          //
          // Delete Notes Options
          PopupMenuButton<String>(
            onSelected: (value) async {
              //
              // Delete All Notes
              if (value == 'delete_all') {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete All"),
                    content: const Text("Are you sure you want to delete all?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirmDelete) {
                  try {
                    final User? user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    // Delete from MyNotes
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Notes')
                        .get()
                        .then((snapshot) {
                      for (var doc in snapshot.docs) {
                        doc.reference.delete();
                      }
                    });

                    // Delete from SharedNotes
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Shared_Notes')
                        .get()
                        .then((snapshot) {
                      for (var doc in snapshot.docs) {
                        doc.reference.delete();
                      }
                    });

                    // Delete from Notifications
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Notifications')
                        .get()
                        .then((snapshot) {
                      for (var doc in snapshot.docs) {
                        doc.reference.delete();
                      }
                    });

                    fetchMyNotes();
                    fetchSharedNotes();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("All notes deleted successfully.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting notes: $e")),
                    );
                  }
                }
              }
              //
              // Delete My Notes
              else if (value == 'delete_my_notes') {
                final User? user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete My Notes"),
                    content: const Text(
                        "Are you sure you want to delete all My Notes?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirmDelete) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Notes')
                        .get()
                        .then((snapshot) {
                      for (var doc in snapshot.docs) {
                        doc.reference.delete();
                      }
                    });

                    fetchMyNotes();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("My Notes deleted successfully.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting My Notes: $e")),
                    );
                  }
                }
              }
              //
              // Delete Shared Notes
              else if (value == 'delete_shared_notes') {
                final User? user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Shared Notes"),
                    content: const Text(
                        "Are you sure you want to delete all Shared Notes?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirmDelete) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Shared_Notes')
                        .get()
                        .then((snapshot) {
                      for (var doc in snapshot.docs) {
                        doc.reference.delete();
                      }
                    });

                    fetchSharedNotes();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Shared Notes deleted successfully.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Error deleting Shared Notes: $e")),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text("Delete All"),
              ),
              const PopupMenuItem(
                value: 'delete_my_notes',
                child: Text("Delete My Notes"),
              ),
              const PopupMenuItem(
                value: 'delete_shared_notes',
                child: Text("Delete Shared Notes"),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      //
      // Appbar End
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
            // My Notes Start
            //
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
              child: myNote.isEmpty
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
                        itemCount: myNote.length,
                        itemBuilder: (context, index) {
                          final note = myNote[index];

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
                                            fetchMyNotes()); // Refresh notes after editing
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
                                              fetchMyNotes();

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
            // My Notes End
            //

            //
            // Shared Notes Start
            //
            Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Shared Notes:",
                  style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
            Expanded(
              child: sharedNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No Shared Notes Available',
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
                        itemCount: sharedNotes.length,
                        itemBuilder: (context, index) {
                          final note = sharedNotes[index];

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
                                      note['Title'] ?? 'Untitled',
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
                                      note['Body'] ?? 'No content available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: size.width * 0.035,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Text(
                                      "Shared By: ${note['Shared_By'] ?? 'Unknown'}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: size.width * 0.03,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDate(note[
                                          'Date']), // Format your timestamp here
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
                                      if (value == 'edit') {
                                        // Navigate to Edit Notes Screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Edit_Notes(
                                                noteId: note[
                                                    'id']), // Ensure `id` exists
                                          ),
                                        ).then((_) => fetchSharedNotes());
                                      } else if (value == 'delete') {
                                        // Delete the shared note
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Delete Note"),
                                            content: const Text(
                                                "Are you sure you want to delete this shared note?"),
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
                                            User? user = FirebaseAuth
                                                .instance.currentUser;
                                            if (user != null) {
                                              // Remove from Firestore
                                              await FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(user.uid)
                                                  .collection('Shared_Notes')
                                                  .doc(note['id'])
                                                  .delete();

                                              // Refresh Shared Notes
                                              fetchSharedNotes();

                                              // Show success message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "Shared note deleted successfully")),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Error deleting note: $e")),
                                            );
                                          }
                                        }
                                      } else if (value == 'share') {
                                        // Share the note again
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
                                            String recipientEmail =
                                                emailController.text.trim();

                                            try {
                                              // Query recipient user
                                              QuerySnapshot userQuery =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Users')
                                                      .where('Email',
                                                          isEqualTo:
                                                              recipientEmail)
                                                      .get();

                                              if (userQuery.docs.isNotEmpty) {
                                                String recipientUid =
                                                    userQuery.docs.first.id;

                                                // Share the note
                                                shareNote(recipientUid, note);
                                                // Save the Notifications
                                                notification(
                                                    recipientUid, note);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Recipient email not found")),
                                                );
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
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Email field is empty")),
                                            );
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
            // Shared Notes End
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
