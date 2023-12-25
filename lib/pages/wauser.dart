import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // Fetch user profile data
      DocumentSnapshot<Map<String, dynamic>> userProfile =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userProfile.exists) {
        // If user data exists, populate the display name
        String displayName = userProfile.data()!['displayName'];
        _displayNameController.text = displayName;
      }
    }
  }

  Future<void> _saveUserProfile() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // Save or update user profile data
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': _displayNameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile saved successfully!'),
                  ),
                );
              },
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}


