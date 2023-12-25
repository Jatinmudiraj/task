import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UserListPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(user['displayName']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        sender: _auth.currentUser!.uid,
                        receiver: user['uid'],
                        receiverName: user['displayName'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String sender;
  final String receiver;
  final String receiverName;

  ChatScreen({
    required this.sender,
    required this.receiver,
    required this.receiverName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  late BehaviorSubject<List<DocumentSnapshot>> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = BehaviorSubject<List<DocumentSnapshot>>();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    // Fetch messages sent by the current user to the selected user
    Stream<QuerySnapshot> sentMessagesStream = _firestore
        .collection('singleMessages')
        .where('sender', isEqualTo: widget.sender)
        .where('receiver', isEqualTo: widget.receiver)
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Fetch messages sent by the selected user to the current user
    Stream<QuerySnapshot> receivedMessagesStream = _firestore
        .collection('singleMessages')
        .where('sender', isEqualTo: widget.receiver)
        .where('receiver', isEqualTo: widget.sender)
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Combine both streams using RxDart
    Rx.combineLatest2(
      sentMessagesStream,
      receivedMessagesStream,
      (QuerySnapshot sent, QuerySnapshot received) {
        final List<DocumentSnapshot> combined = []
          ..addAll(sent.docs)
          ..addAll(received.docs);
        return combined;
      },
    ).listen((List<DocumentSnapshot> snapshots) {
      _streamController.add(snapshots);
    });
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      await _firestore.collection('singleMessages').add({
        'text': messageText,
        'sender': widget.sender,
        'receiver': widget.receiver,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!;
                List<Widget> messageWidgets = [];

                if (messages.isEmpty) {
                  messageWidgets.add(
                    Center(
                      child: Text('No messages till now.'),
                    ),
                  );
                } else {
                  for (var message in messages) {
                    final messageText = message['text'];
                    final messageSender = message['sender'];

                    final messageWidget = MessageWidget(
                      sender: messageSender,
                      text: messageText,
                      isMe: widget.sender == messageSender,
                    );
                    messageWidgets.add(messageWidget);
                  }
                }

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageWidget({
    required this.sender,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isMe ? 'You' : sender,
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          Material(
            borderRadius: BorderRadius.circular(8.0),
            elevation: 5.0,
            color: isMe ? Colors.blue : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16.0,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
