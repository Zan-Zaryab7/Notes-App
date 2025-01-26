import 'package:flutter/material.dart';
import 'package:notey_task/Views/Bottom_Navbar.dart';
import 'package:notey_task/Views/Notes/Notes_Firebase.dart';

class Add_Notes extends StatefulWidget {
  const Add_Notes({super.key});

  @override
  State<Add_Notes> createState() => _Add_NotesState();
}

class _Add_NotesState extends State<Add_Notes> {
  // Controllers for Notes
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  void dispose() {
    super.dispose();
    _titleController.dispose();
    _bodyController.dispose();
  }

  bool isloading = false;

  //
  // Create Note Method
  void createNote() async {
    // Check if title and body fields are not empty
    if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
      // Show loading indicator
      setState(() {
        isloading = true;
      });

      try {
        // Call the createNote service
        String res = await NotesServices().createNote(
          title: _titleController.text,
          body: _bodyController.text,
        );

        if (res == "Success") {
          // Navigate to Bottom_Navbar on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Bottom_Navbar()),
          );
        } else {
          // Show error message if service fails
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
        // Hide loading indicator
        setState(() {
          isloading = false;
        });
      }
    } else {
      // Show error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Notes",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C28),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: createNote,
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          )
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
            // Title TextField Start
            //
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _titleController,
                maxLines: 1,
                style: TextStyle(
                    fontSize: size.width * 0.045,
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
      //
      // Body End
      //
    );
  }
}
