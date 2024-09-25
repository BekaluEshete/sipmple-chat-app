import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    FocusScope.of(context).unfocus(); // Dismiss the keyboard
    _messageController.clear();

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userData.exists && userData.data() != null) {
      FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userName': userData.data()?['username'] ?? 'Unknown',
        'userImage': userData.data()?['imageurl'] ?? ''
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 2, bottom: 4),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: "Send a message"),
          )),
          IconButton(
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
