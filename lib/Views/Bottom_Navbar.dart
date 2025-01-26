import 'package:flutter/material.dart';
import 'package:notey_task/Views/Home.dart';
import 'package:notey_task/Views/Notes/Notes.dart';
import 'package:notey_task/Views/Profile.dart';

class Bottom_Navbar extends StatefulWidget {
  const Bottom_Navbar({super.key});

  @override
  State<Bottom_Navbar> createState() => _Bottom_NavbarState();
}

class _Bottom_NavbarState extends State<Bottom_Navbar> {
  int _selectedIndex = 0;
  var _pages = [Home(), Notes(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      //
      // Bottom Navbar Start
      //
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2B2B3B),
        selectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.note_alt_sharp,
            ),
            label: "Notes",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
            ),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (setValue) {
          setState(() {
            _selectedIndex = setValue;
          });
        },
      ),
      //
      // Bottom Navbar End
      //
    );
  }
}
