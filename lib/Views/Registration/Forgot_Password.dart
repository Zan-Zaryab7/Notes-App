import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Forgot_Password extends StatefulWidget {
  const Forgot_Password({super.key});

  @override
  State<Forgot_Password> createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {
  // Controller for Reset Password
  TextEditingController emailcon = TextEditingController();

  // Authentication Collection
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    //
    // Forgot Password Text Start
    //
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            myDialog(context);
          },
          child: Text(
            "Forgot Password",
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width * 0.035),
          ),
        ),
      ),
    );
    //
    // Forgot Password Text End
    //
  }

  //
  // Dialog to Reset User Password Start
  //
  void myDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Dialog
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Forgot Password Label
                    Text(
                      "Forgot your password",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w600),
                    ),
                    // Close Button
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                // Sizedbox for Spacing
                SizedBox(
                  // MediaQuery for Responsive Spacing
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                // Email Field
                TextField(
                    controller: emailcon,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter The Email",
                      hintText: "eg: example@gmail.com",
                    )),
                // Sizedbox for Spacing
                SizedBox(
                  // MediaQuery for Responsive Spacing
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Reset Password Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B2F3A)),
                  onPressed: () async {
                    // Resetting Password Method
                    if (emailcon.text.isNotEmpty) {
                      await auth
                          .sendPasswordResetEmail(email: emailcon.text)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "We have send you the reset password link to your email")));
                      }).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error: ${error.toString()}")));
                      });
                      Navigator.pop(context);
                      emailcon.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Email field is empty"),
                      ));
                    }
                  },
                  // Button Text
                  child: Text(
                    "Send",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  //
  // Dialog to Reset User Password End
  //
}
