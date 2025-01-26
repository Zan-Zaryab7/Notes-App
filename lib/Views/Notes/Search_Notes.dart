import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Search_Notes extends StatefulWidget {
  const Search_Notes({Key? key}) : super(key: key);

  @override
  State<Search_Notes> createState() => _Search_NotesState();
}

class _Search_NotesState extends State<Search_Notes> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _myNotes = [];
  List<Map<String, dynamic>> _sharedNotes = [];

  Future<void> searchNotes(String query) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Search in My Notes
      QuerySnapshot myNotesSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Notes')
          .where('Title', isGreaterThanOrEqualTo: query)
          .where('Title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Search in Shared Notes
      QuerySnapshot sharedNotesSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Shared_Notes')
          .where('Title', isGreaterThanOrEqualTo: query)
          .where('Title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      setState(() {
        _myNotes = myNotesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        _sharedNotes = sharedNotesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during search: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            searchNotes(value);
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _myNotes = [];
                _sharedNotes = [];
              });
            },
          ),
        ],
      ),
      body: Container(
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
        child: ListView(
          children: [
            // Display My Notes Section
            if (_myNotes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "My Notes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ..._myNotes.map((note) => ListTile(
                        title: Text(
                          note['Title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          note['Body'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          // Navigate to note details
                        },
                      )),
                ],
              ),
            // Display Shared Notes Section
            if (_sharedNotes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Shared Notes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ..._sharedNotes.map((note) => ListTile(
                        title: Text(
                          note['Title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          note['Body'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          // Navigate to shared note details
                        },
                      )),
                ],
              ),
            if (_myNotes.isEmpty && _sharedNotes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No results found.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
