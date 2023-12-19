import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:project7/pages/home_screen.dart';
// import 'package:trial/pages/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:project7/utils/gallery_view_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project7/pages/welcome_screen.dart';


// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const WelcomeScreen(),
//     );
//   }
// }


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class FlickrPhoto {
  final String id;
  final String owner;
  final String title;
  final String imageUrl;

  FlickrPhoto({
    required this.id,
    required this.owner,
    required this.title,
    required this.imageUrl,
  });

  factory FlickrPhoto.fromJson(Map<String, dynamic> json) {
    return FlickrPhoto(
      id: json['id'] ?? '',
      owner: json['owner'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['url_s'] ?? '',
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late List<FlickrPhoto> photos;

//   @override
//   void initState() {
//     super.initState();
//     fetchPhotos();
//   }

// Future<void> fetchPhotos() async {
//   final Uri url = Uri.parse(
//     'https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=20&page=1&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s',
//   );

//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     // Remove the "jsonFlickrApi(" and the trailing ")" from the response
//     final jsonString = response.body.replaceFirst('jsonFlickrApi(', '').replaceAll(')', '');

//     final Map<String, dynamic> data = json.decode(jsonString);
//     final List<dynamic> photoList = data['photos']['photo'];

//     setState(() {
//       photos = photoList.map((json) => FlickrPhoto.fromJson(json)).toList();
//     });
//   } else {
//     throw Exception('Failed to load photos');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flickr Photo Gallery'),
//       ),
//       body: photos != null
//           ? ListView.builder(
//               itemCount: photos.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(photos[index].title),
//                   leading: Image.network(photos[index].imageUrl),
//                 );
//               },
//             )
//           : Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }




class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GalleryViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flickr Gallery App',


      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
      ),
    );
  }
}

