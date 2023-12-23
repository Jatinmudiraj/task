import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AudioUploadPage extends StatefulWidget {
  @override
  _AudioUploadPageState createState() => _AudioUploadPageState();
}

class _AudioUploadPageState extends State<AudioUploadPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Pop'; // Default category
  File? _imageFile;
  File? _audioFile;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Audio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Song Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _songNameController,
                decoration: InputDecoration(labelText: 'Song Name'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: ['Pop', 'Rock', 'Hip-Hop', 'Classical']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 20),
              Text(
                'Upload Files',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                  );

                  if (result != null) {
                    setState(() {
                      _imageFile = File(result.files.single.path!);
                    });
                  }
                },
                child: Text('Pick Image'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.audio,
                    allowMultiple: false,
                  );

                  if (result != null) {
                    setState(() {
                      _audioFile = File(result.files.single.path!);
                    });
                  }
                },
                child: Text('Pick Audio'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _uploadFiles();
                },
                child: _isUploading
                    ? CircularProgressIndicator() // Show loading indicator
                    : Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFiles() async {
    try {
      // Set _isUploading to true to show loading indicator
      setState(() {
        _isUploading = true;
      });

      // Upload image
      Reference imageStorageRef = _storage.ref().child('images/${DateTime.now()}.png');
      await imageStorageRef.putFile(_imageFile!);
      String imageUrl = await imageStorageRef.getDownloadURL();

      // Upload audio
      Reference audioStorageRef = _storage.ref().child('audio/${DateTime.now()}.mp3');
      await audioStorageRef.putFile(_audioFile!);
      String audioUrl = await audioStorageRef.getDownloadURL();

      // Get user data
      User? user = _auth.currentUser;
      String uid = user!.uid;
      String email = user.email!;

      // Get current date
      String currentDate = DateTime.now().toString();

      // Upload data to Firestore
      await _firestore.collection('audio').add({
        'songName': _songNameController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'userId': uid,
        'email': email,
        'uploadDate': currentDate,
      });

      // Clear controllers and files
      _songNameController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = 'Pop';
        _imageFile = null;
        _audioFile = null;
      });

      // Set _isUploading back to false after upload is completed
      setState(() {
        _isUploading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Audio Uploaded Successfully'),
      ));
    } catch (e) {
      // Set _isUploading back to false on error
      setState(() {
        _isUploading = false;
      });

      print('Error uploading audio: $e');
    }
  }
}
