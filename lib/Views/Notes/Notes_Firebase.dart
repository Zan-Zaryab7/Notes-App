import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesServices {
  // Firebase Firestore Database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase Authentication Database
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //
  // Create Notes Method
  Future<String> createNote({
    required String title,
    required String body,
  }) async {
    String res = "Fields are empty";
    try {
      // Validate fields
      if (title.isNotEmpty && body.isNotEmpty) {
        // Fetch current user ID
        User? user = _auth.currentUser;

        if (user == null) {
          return "User not logged in";
        }

        // Create a unique document for the note in a sub-collection
        await _firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Notes")
            .add({
          "Title": title,
          "Body": body,
          "Date": FieldValue.serverTimestamp(),
        });

        res = "Success";
      }
    } catch (e) {
      res = "An error occurred while creating the note. Please try again.";
    }
    return res;
  }

  //
  // Update My Notes Method
  Future<String> updateMyNote({
    required String noteId,
    required String title,
    required String body,
  }) async {
    String res = "Fields are empty";
    try {
      // Validate fields
      if (title.isNotEmpty && body.isNotEmpty) {
        // Fetch current user ID
        User? user = _auth.currentUser;

        if (user == null) {
          return "User not logged in";
        }

        // Update the note in Firestore
        await _firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Notes")
            .doc(noteId)
            .update({
          "Title": title,
          "Body": body,
        });

        res = "Success";
      }
    } catch (e) {
      res = "An error occurred while updating the note. Please try again.";
    }
    return res;
  }

  //
  // Update My Notes Method
  Future<String> updateSharedNote({
    required String noteId,
    required String title,
    required String body,
  }) async {
    String res = "Fields are empty";
    try {
      // Validate fields
      if (title.isNotEmpty && body.isNotEmpty) {
        // Fetch current user ID
        User? user = _auth.currentUser;

        if (user == null) {
          return "User not logged in";
        }

        // Update the note in Firestore
        await _firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Shared_Notes")
            .doc(noteId)
            .update({
          "Title": title,
          "Body": body,
        });

        res = "Success";
      }
    } catch (e) {
      res = "An error occurred while updating the note. Please try again.";
    }
    return res;
  }
}
