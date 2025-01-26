import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notey_task/Views/Bottom_Navbar.dart';
import 'package:notey_task/Views/Registration/Firebease_Auth.dart';
import 'package:notey_task/Views/Registration/Signup.dart';

class Edit extends StatefulWidget {
  const Edit({super.key});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  // Controllers for Signup Form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _currentpasswordController =
      TextEditingController();

  //
  //
  // Editing User Account Details
  bool isloading = false;

  void dispose() {
    super.dispose();
    _nameController.dispose();
    _newpasswordController.dispose();
    _currentpasswordController.dispose();
  }

  // Updating User Method
  void updateUser() async {
    // Check if Field are empty or not
    if (_nameController.text.isNotEmpty &&
        _currentpasswordController.text.isNotEmpty &&
        _newpasswordController.text.isNotEmpty) {
      // Implementing Values in Edit Method
      String res = await AuthServices().updateUser(
        currentPassword: _currentpasswordController.text,
        newPassword: _newpasswordController.text,
        name: _nameController.text,
      );

      // If Method Works, Navigate to Home Page
      if (res == "User updated successfully") {
        setState(() {
          isloading = true;
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Bottom_Navbar()));
      }
      // If Method Doesn't Work, Show the Error
      else {
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
    }
  }

  //
  //
  // Fetching User Account Details
  // Saving User Details
  String userName = "";
  String userPassword = "";

  // Fetching User from Firestore Collection
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
          userPassword = userDoc[
              'Password']; // Fetch the 'password' field from Firestore document
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Calling the Function
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    // Size for Responsiveness
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      //
      // Appbar Start
      //
      appBar: AppBar(
        // Appbar Title
        title: Text(
          "Notey Task",
          style: TextStyle(color: Colors.white, fontSize: size.width * 0.045),
        ),
        centerTitle: true,
        // Appbar Background Color
        backgroundColor: const Color(0xFF1C1C28),
        // IconTheme
        iconTheme: const IconThemeData(color: Colors.white),
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
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.08),
                      // Edit Account Title
                      Text(
                        "Edit Account",
                        style: TextStyle(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: size.height * 0.12),
                      // Name Field
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: userName,
                          hintStyle: const TextStyle(color: Colors.white),
                          labelText: "Name",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2B2B3B),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      // Current Password Field
                      TextField(
                        controller: _currentpasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: userPassword,
                          hintStyle: const TextStyle(color: Colors.white),
                          labelText: "Current Password",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2B2B3B),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      // New Password Field
                      TextField(
                        controller: _newpasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "New Password",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2B2B3B),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      // Edit Account Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: updateUser,
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: const Color(0xFF2B2F3A),
                              elevation: 1),
                          child: Text(
                            "Edit Account",
                            style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //
            //
            // Delete Account Dialog
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Delete Account Text
                    Text(
                      "Want to delete account?",
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                    // Delete Account Dialog Button
                    GestureDetector(
                      onTap: () {
                        // Alert Dialog Method
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // Dialog Background Color
                              backgroundColor: const Color(0xFF2B2F3A),
                              // Dialog Title
                              title: const Text(
                                "Confirm Deletion",
                                style: TextStyle(color: Colors.white),
                              ),
                              // Dialog Content
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Please enter your password to confirm account deletion.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _currentpasswordController,
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: "Password",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              // Dialog Actions
                              actions: [
                                // Cancel Button
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                // Delete Button
                                TextButton(
                                  onPressed: () async {
                                    String password =
                                        _currentpasswordController.text;

                                    if (password.isNotEmpty) {
                                      String res = await AuthServices()
                                          .deleteUserWithPassword(password);

                                      if (res == "User deleted successfully") {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Signup()),
                                          (route) => false,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(res)),
                                        );
                                      }
                                    } else if (password.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: const Text(
                                                'Password is empty')),
                                      );
                                    } else {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    }
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        " Delete",
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //
      // Body End
      //
    );
  }
}
