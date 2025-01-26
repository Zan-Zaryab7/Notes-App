import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notey_task/Views/Registration/Edit.dart';
import 'package:notey_task/Views/Registration/Firebease_Auth.dart';
import 'package:notey_task/Views/Registration/Login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Saving User Details
  String userName = "";
  String userEmail = "";
  String userPassword = "";
  String userDay = "";
  String userMonth = "";
  String userYear = "";

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
          userEmail = userDoc[
              'Email']; // Fetch the 'email' field from Firestore document
          userPassword = userDoc[
              'Password']; // Fetch the 'password' field from Firestore document
          DateTime date = (userDoc['Date'] as Timestamp)
              .toDate(); // Fetch the 'Date' field from Firestore document
          userDay = date.day.toString(); // Fetch 'Day' from date
          userMonth = date.month.toString(); // Fetch 'month' from date
          userYear = date.year.toString(); // Fetch 'year' from date
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Profile Picture and Name Section
                Center(
                  child: Column(
                    children: [
                      // Profile Picture
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF1A1D23),
                        backgroundImage: NetworkImage(
                            'assets/profile_picture.jpg'), // Replace with your image
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        // User Name
                        userName,
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Active Since
                      Text(
                        // User Created Date
                        'Active since - $userDay/$userMonth/$userYear',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Personal Information Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Edit()));
                        },
                        child: Row(
                          children: [
                            Text(
                              "Edit ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * 0.035),
                            ),
                            Icon(
                              Icons.edit,
                              color: Colors.grey,
                              size: size.width * 0.035,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                // Email
                ListTile(
                  leading: Icon(Icons.email,
                      color: Colors.white, size: size.width * 0.04),
                  title: Text(
                    'Email',
                    style: TextStyle(
                        color: Colors.white, fontSize: size.width * 0.04),
                  ),
                  trailing: Text(
                    // User Email
                    userEmail,
                    style: TextStyle(
                        color: Colors.white, fontSize: size.width * 0.03),
                  ),
                ),
                const SizedBox(height: 8),
                // Password
                ListTile(
                  leading: Icon(Icons.lock,
                      color: Colors.white, size: size.width * 0.04),
                  title: Text(
                    'Password',
                    style: TextStyle(
                        color: Colors.white, fontSize: size.width * 0.04),
                  ),
                  trailing: Text(
                    // User Password
                    '*' * userPassword.length,
                    style: TextStyle(
                        color: Colors.white, fontSize: size.width * 0.03),
                  ),
                ),
                const SizedBox(height: 32),
                // Utilities Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Utilities',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  onTap: () async {
                    await AuthServices().logoutUser();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  leading: Icon(Icons.logout,
                      color: Colors.white, size: size.width * 0.04),
                  title: Text(
                    'Log-Out',
                    style: TextStyle(
                        color: Colors.white, fontSize: size.width * 0.04),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      //
      // Body End
      //
    );
  }
}
