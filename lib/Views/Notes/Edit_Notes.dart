import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notey_task/Views/Notes/Notes_Firebase.dart';

class Edit_Notes extends StatefulWidget {
  final String noteId; // Pass the note's ID for editing

  const Edit_Notes({super.key, required this.noteId});

  @override
  State<Edit_Notes> createState() => _Edit_NotesState();
}

class _Edit_NotesState extends State<Edit_Notes> {
  // Firebase services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for Notes
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  //
  // Fetch My Note Details
  //
  void _fetchMyNoteDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get the note document from Firestore
      final noteDoc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Notes')
          .doc(widget.noteId)
          .get();

      if (noteDoc.exists) {
        setState(() {
          _titleController.text = noteDoc['Title'] ?? '';
          _bodyController.text = noteDoc['Body'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching note: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //
  // Fetch Share Note Details
  //
  void _fetchShareNoteDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get the note document from Firestore
      final noteDoc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Shared_Notes')
          .doc(widget.noteId)
          .get();

      if (noteDoc.exists) {
        setState(() {
          _titleController.text = noteDoc['Title'] ?? '';
          _bodyController.text = noteDoc['Body'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching note: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //
  // Update Note Method
  //
  void _updateNote() async {
    // Check if the title and body fields are not empty
    if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        String res;

        final User? user = _auth.currentUser;

        // Check if the note exists in the Shared_Notes collection
        final sharedNoteDoc = await _firestore
            .collection('Users')
            .doc(user?.uid)
            .collection('Shared_Notes')
            .doc(widget.noteId)
            .get();

        if (sharedNoteDoc.exists) {
          // Update the note in Shared_Notes
          res = await NotesServices().updateSharedNote(
            noteId: widget.noteId,
            title: _titleController.text,
            body: _bodyController.text,
          );
        } else {
          // Update the note in Notes
          res = await NotesServices().updateMyNote(
            noteId: widget.noteId, // Pass the noteId to update
            title: _titleController.text,
            body: _bodyController.text,
          );
        }

        if (res == "Success") {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );

          // Navigate back to the previous screen
          Navigator.pop(context);
        } else {
          // Show error message if the service fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res)),
          );
        }
      } catch (e) {
        // Handle unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMyNoteDetails(); // Fetch my note details when the view is initialized
    _fetchShareNoteDetails(); // Fetch shared note details when the view is initialized
  }

  @override
  Widget build(BuildContext context) {
    // Size for Responsiveness
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      //
      // AppBar Start
      //
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Note",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C28),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _updateNote,
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      //
      // AppBar End
      //

      //
      // Body Start
      //
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                  // Title TextField Start
                  //
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _titleController,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Title",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Color(0xFF2B2B3B),
                      ),
                    ),
                  ),
                  //
                  // Title TextField End
                  //

                  //
                  // Body TextField Start
                  //
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _bodyController,
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        style: TextStyle(
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Body",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFF2B2B3B),
                        ),
                      ),
                    ),
                  ),
                  //
                  // Body TextField End
                  //
                ],
              ),
            ),
    );
  }
}
