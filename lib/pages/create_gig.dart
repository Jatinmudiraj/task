import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGig extends StatefulWidget {
  const CreateGig({Key? key}) : super(key: key);

  @override
  State<CreateGig> createState() => _CreateGigState();
}

class _CreateGigState extends State<CreateGig> {
  final TextEditingController _MessNameController = TextEditingController();
  final TextEditingController _MessDiscriptionController =
      TextEditingController();
  final TextEditingController _MessDatelineController =
      TextEditingController(text: 'Mess Deadline');
  final TextEditingController _MessTypeController =
      TextEditingController(text: 'Select Mess Category');

  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Product')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(7.0),
          child: Card(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Text(
                        "Please Fill Form",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _MessNameController,
                          decoration: InputDecoration(labelText: 'Mess Name'),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _MessDiscriptionController,
                          decoration:
                              InputDecoration(labelText: 'Mess Description'),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _pickVideo,
                          child: Text('Select Video'),
                        ),
                        SizedBox(height: 16.0),
                        _videoFile != null
                            ? Text('Selected Video: ${_videoFile!.path}')
                            : Container(),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            // Handle form submission here
                            // You can access the entered values using _MessNameController.text,
                            // _MessDiscriptionController.text, and _videoFile
                            print('Mess Name: ${_MessNameController.text}');
                            print('Mess Description: ${_MessDiscriptionController.text}');
                            print('Selected Video: ${_videoFile?.path}');
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
