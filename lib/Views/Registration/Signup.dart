import 'package:flutter/material.dart';
import 'package:notey_task/Views/Bottom_Navbar.dart';
import 'package:notey_task/Views/Registration/Firebease_Auth.dart';
import 'package:notey_task/Views/Registration/Login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers for Signup Form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isloading = false;

  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  //
  // Signup User Method
  void signupUser() async {
    // Implementing Values in Signup Method
    String res = await AuthServices().signupUser(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text);

    // If Method Works, Navigate to Home Page
    if (res == "Success") {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
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
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "Welcome to\n Notey Task",
                        style: TextStyle(
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: size.height * 0.1),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        autofocus: true,
                        decoration: InputDecoration(
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
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2B2B3B),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2B2B3B),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signupUser,
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: const Color(0xFF2B2F3A),
                              elevation: 1),
                          child: Text(
                            "Create Account",
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      },
                      child: Text(
                        " Login",
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
