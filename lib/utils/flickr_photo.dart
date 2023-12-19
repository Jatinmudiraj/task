// lib/models/flickr_photo.dart
class FlickrPhoto {
  final String id;
  final String owner;
  // Add other fields as needed
  final String imageUrl;

  FlickrPhoto({
    required this.id,
    required this.owner,
    // Add other fields as needed
    required this.imageUrl,
  });

  // Factory constructor to convert JSON to FlickrPhoto
  factory FlickrPhoto.fromJson(Map<String, dynamic> json) {
    return FlickrPhoto(
      id: json['id'] ?? '',
      owner: json['owner'] ?? '',
      // Add other fields...
      imageUrl: json['url_s'] ?? '',
    );
  }
}
