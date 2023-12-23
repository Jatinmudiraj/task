import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project7/pages/flicker_page.dart';
import 'package:project7/pages/home.dart';
import 'package:project7/pages/search.dart';
// import 'package:project4/pages/Profile.dart';
// import 'package:project4/pages/Search_Page.dart';
// import 'package:project4/pages/create_gig.dart';
// import 'package:project4/pages/history.dart';
// import 'package:project4/pages/todayScreen.dart';
import 'package:project7/pages/welcome_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final String? userName = FirebaseAuth.instance.currentUser?.displayName;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        UserAccountsDrawerHeader(
          accountName: Text('Mess App'),
          accountEmail: Text("Hello $userName"),
          currentAccountPicture: CircleAvatar(
            child: ClipOval(
              child: Image.network(
                "https://firebasestorage.googleapis.com/v0/b/project3-917bd.appspot.com/o/gig_images%2Fprofile.png?alt=media&token=e244aaa7-3cf2-4754-97d5-c84201d32bff",
                color: Colors.white,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            image: DecorationImage(
              image: NetworkImage(
                  'https://firebasestorage.googleapis.com/v0/b/project3-917bd.appspot.com/o/gig_images%2FMess_Image_1.jpeg?alt=media&token=5fd37849-2bdc-4e78-9c3f-eba8a5162ef2'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home_outlined),
          title: Text('Home'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.functions_outlined),
          title: Text('Flicker Page with Paging'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Flicker(),
              ),
            );
          },
        ),
        ListTile(
            leading: Icon(Icons.share), title: Text('Refer'), onTap: () {}),
        ListTile(
          leading: Icon(Icons.search_outlined),
          title: Text('Search'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(),
              ),
            );
          },
        ),
        // ListTile(
        //   leading: Icon(Icons.safety_check_outlined),
        //   title: Text('Attandance History'),
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => MyWidget(),
        //       ),
        //     );
        //   },
        // ),
        // Divider(),
        // ListTile(
        //   leading: Icon(Icons.settings),
        //   title: Text('Settings'),
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => Profile(),
        //       ),
        //     );
        //   },
        // ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Exit'),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const WelcomeScreen();
            }));
          },
        ),
      ]),
    );
  }
}
