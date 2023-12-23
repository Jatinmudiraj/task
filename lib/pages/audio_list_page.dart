import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio List'),
      ),
      body: AudioList(),
    );
  }
}

class AudioList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('audio').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: FutureBuilder<String>(
                future: _getImageUrl(data['imageUrl']),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState == ConnectionState.done && imageSnapshot.hasData) {
                    return Image.network(
                      imageSnapshot.data!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Image.network(
                      'https://via.placeholder.com/50', // Replace with your default image URL
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
              title: Text(data['songName']),
              onTap: () {
                _showDetailsDialog(context, data);
              },
            );
          },
        );
      },
    );
  }

  Future<String> _getImageUrl(String imagePath) async {
  try {
    final ref = _storage.ref().child(imagePath);
    final metadata = await ref.getMetadata();
    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print('Error fetching image URL: $e');
    return 'https://via.placeholder.com/500'; // Replace with your default image URL
  }
}


  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['songName']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: _getImageUrl(data['imageUrl']),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState == ConnectionState.done && imageSnapshot.hasData) {
                    return Image.network(
                      imageSnapshot.data!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Image.network(
                      'https://thumbs.dreamstime.com/z/yoga-beautiful-background-harmony-life-meditation-practice-silhouette-woman-sitting-lotus-position-pier-lake-211252572.jpg', // Replace with your default image URL
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
              SizedBox(height: 10),
              Text('Description: ${data['description']}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _playAudio(data['audioUrl']);
                },
                child: Text('Play Audio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _playAudio(String audioUrl) {
    // Implement audio play functionality
  }
}
