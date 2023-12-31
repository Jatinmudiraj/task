import 'package:firebase_auth/firebase_auth.dart';
import 'package:project7/pages/audio_list_page.dart';
import 'package:project7/pages/create_gig.dart';
import 'package:project7/pages/fetchvechicle.dart';
import 'package:project7/pages/flicker_page.dart';
// import 'package:project4/pages/Profile.dart';
// import 'package:project4/pages/SearchWorking.dart';
// import 'package:project4/pages/Search_Page.dart';
// import 'package:project4/pages/create_gig.dart';
// import 'package:project4/pages/SearchWorking.dart';
import 'package:project7/pages/forget_passwor.dart';
// import 'package:project4/pages/functionalPage.dart';
// import 'package:project4/pages/history.dart';
import 'package:project7/pages/home.dart';
import 'package:project7/pages/login_screen.dart';
import 'package:project7/pages/search.dart';
// import 'package:project7/pages/maze_page.dart';
import 'package:project7/pages/signup_screen.dart';
import 'package:project7/pages/todayScreen.dart';
import 'package:project7/pages/todo.dart';
import 'package:project7/pages/uploadvehicle.dart';
import 'package:project7/pages/wa.dart';
import 'package:project7/pages/wamain.dart';
import 'package:project7/pages/wasingle.dart';
import 'package:project7/pages/wauser.dart';
// import 'package:project4/pages/todayScreen.dart';
import 'package:project7/pages/welcome_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedindex = 0;

  static final List<Widget> _screens = <Widget>[
    VehicleDetailsPage(),
    VehicleForm(),
    SearchPage(),
    WAMain(),
    // UserProfilePage(),
    // UserListPage(),
    // ChatScreen(),
    // Search(),
    // Functional(),
    // Profile(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  final String? userName = FirebaseAuth.instance.currentUser?.displayName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedindex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          color: Colors.white,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.grey,
        ),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.diamond_sharp),
              label: 'Home'),
          BottomNavigationBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.add_circle),
              label: 'Functional'),
          BottomNavigationBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.search),
              label: 'Search'),
          BottomNavigationBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.person),
              label: 'Profile'),
        ],
        currentIndex: _selectedindex,
        onTap: _onItemTapped,
      ),
    );
  }
}


// //LOG OUT Code

// Column(
//         children: [
//           Text("Hello $userName"),
//           ElevatedButton(
//               onPressed: () async {
//                 await FirebaseAuth.instance.signOut();
//                 if (!mounted) return;
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return const WelcomeScreen();
//                 }));
//               },
//               child: const Text("Sign Out")),
//         ],
//       ),