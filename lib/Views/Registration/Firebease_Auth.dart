import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // Firebase Firestore Database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase Authentication Database
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //
  // User Signup Method
  Future<String> signupUser(
      {required String email,
      required String password,
      required String name}) async {
    var res = "Fields are empty";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        // Creating User in Authentication Collection
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        //
        // Creating User in Firestore Collection
        // Save user details and device token in Firestore
        await _firestore.collection("Users").doc(credential.user!.uid).set({
          "Name": name,
          "Email": email,
          "Password": password,
          "Date": DateTime.now(),
          "uid": credential.user!.uid,
        });

        // Initialize an empty Shared_Notes sub-collection
        await _firestore
            .collection("Users")
            .doc(credential.user!.uid)
            .collection("Shared_Notes")
            .doc("_init") // Dummy document ID to initialize the collection
            .set({
          "initialized": true,
        });

        // Initialize an empty Notifications sub-collection
        await _firestore
            .collection("Users")
            .doc(credential.user!.uid)
            .collection("Notifications")
            .doc("_init") // Dummy document ID to initialize the collection
            .set({
          "initialized": true,
        });

        res = "Success";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //
  // User Login Method
  Future<String> loginUser(
      {required String email, required String password}) async {
    var res = "Some Error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // Checking User in Authentication Collection
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Fields are empty";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //
  // User Logout Method
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  //
  // Update User Method
  Future<String> updateUser({
    required String currentPassword,
    required String newPassword,
    required String name,
  }) async {
    String res = "Something went wrong";

    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Debug: Check the user's email
        print("Re-authenticating user with email: ${user.email}");

        // Re-authenticate the user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password:
              currentPassword, // Ensure this is the correct current password
        );

        await user.reauthenticateWithCredential(credential);

        // Update password in Firebase Authentication
        if (newPassword.isNotEmpty) {
          await user.updatePassword(newPassword);
        }

        // Update name in Firestore
        await _firestore.collection('Users').doc(user.uid).update({
          'Name': name,
          'Password': newPassword,
        });

        res = "User updated successfully";
      } else {
        res = "No user is currently signed in";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        res = "The current password is incorrect. Please try again.";
      } else if (e.code == 'requires-recent-login') {
        res = "Please re-authenticate and try again.";
      } else {
        res = e.message ?? "An error occurred.";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  //
  // Delete User Method
  Future<String> deleteUserWithPassword(String password) async {
    String res = "Something went wrong";

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Re-authenticate the user with the entered password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);

        // Delete Firestore document
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .delete();

        // Delete the user from Firebase Authentication
        await user.delete();

        res = "User deleted successfully";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}
