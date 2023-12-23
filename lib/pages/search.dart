import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<FlickrPhoto> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Photos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPhotos(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: (_searchResults.isNotEmpty)
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        FlickrPhoto photo = _searchResults[index];
                        return Card(
                          margin: EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  photo.imageUrl,
                                  height: 200.0,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  photo.title,
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text('No results found'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchPhotos(String searchTerm) async {
    final apiKey = '6f102c62f41998d151e5a1b48713cf13';
    final Uri url = Uri.parse(
      'https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=$apiKey&format=json&nojsoncallback=1&extras=url_s&text=$searchTerm',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> photoList = data['photos']['photo'];

      List<FlickrPhoto> newPhotos = photoList.map((json) => FlickrPhoto.fromJson(json)).toList();

      setState(() {
        _searchResults = newPhotos;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void _searchPhotos(String searchTerm) {
    _searchResults.clear();
    _fetchPhotos(searchTerm);
  }
}

