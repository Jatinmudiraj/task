// lib/view_models/gallery_view_model.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project7/utils/flickr_photo.dart';

class GalleryViewModel extends ChangeNotifier {
  final Dio _dio = Dio();
  final String apiKey = 'https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=20&page=1&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s';

  Future<List<FlickrPhoto>> getRecentPhotos() async {
    try {
      final response = await _dio.get(
        'https://api.flickr.com/services/rest/',
        queryParameters: {
          'method': 'flickr.photos.getRecent',
          'per_page': 20,
          'page': 1,
          'api_key': apiKey,
          'format': 'json',
          'nojsoncallback': 1,
          'extras': 'url_s',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic> photosData = jsonResponse['photos']['photo'];

        // Map the list of dynamic data to a list of FlickrPhoto objects
        final List<FlickrPhoto> photos = photosData
            .map((dynamic data) => FlickrPhoto.fromJson(data))
            .toList();

        return photos;
      } else {
        // Handle non-200 status code
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
      return [];
    }
  }
}