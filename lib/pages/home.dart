import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project7/widgets/Top_Bar.dart';

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

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<FlickrPhoto> photos = [];

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    final Uri url = Uri.parse(
      'https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=20&page=1&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonString = response.body.replaceFirst('jsonFlickrApi(', '').replaceAll(')', '');

      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> photoList = data['photos']['photo'];

      setState(() {
        photos = photoList.map((json) => FlickrPhoto.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flickr Photo Gallery'),
      ),
      drawer: NavBar(),
      body: photos.isNotEmpty
          ? ListView.builder(
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          photos[index].imageUrl,
                          height: 200.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          photos[index].title,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
