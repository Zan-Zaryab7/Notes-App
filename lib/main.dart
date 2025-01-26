import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notey_task/Views/Bottom_Navbar.dart';
import 'package:notey_task/Views/Registration/Signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const Notey_Task());
}

class Notey_Task extends StatelessWidget {
  const Notey_Task({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Bottom_Navbar();
          } else {
            return const Signup();
          }
        },
      ),
    );
  }
}
