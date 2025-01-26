import 'package:flutter/material.dart';
import 'package:notey_task/Views/Bottom_Navbar.dart';
import 'package:notey_task/Views/Registration/Firebease_Auth.dart';
import 'package:notey_task/Views/Registration/Forgot_Password.dart';
import 'package:notey_task/Views/Registration/Signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers for Signup Form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  //
  // Signin User Method
  void loginUser() async {
    // Implementing Values in Login Method
    String res = await AuthServices().loginUser(
        email: _emailController.text, password: _passwordController.text);

    // If Method Works, Navigate to Home Page
    if (res == "Success") {
      setState(() {
        isLoading = true;
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const Bottom_Navbar()));
    }
    // If Method Doesn't Work, Show the Error
    else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Size For Responsiveness
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
                          "Login",
                          style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
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
                      SizedBox(height: size.height * 0.03),
                      // Forgot Password Dialog Component
                      const Forgot_Password(),
                      SizedBox(height: size.height * 0.05),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: const Color(0xFF2B2F3A),
                              elevation: 1),
                          child: Text(
                            "Login",
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
                      "Don't have an account?",
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
                                builder: (context) => const Signup()));
                      },
                      child: Text(
                        " Sign Up",
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
