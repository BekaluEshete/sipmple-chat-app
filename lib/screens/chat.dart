import 'package:chat_app/widgets/chat.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('chat app')),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.exit_to_app),
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
        body: Column(
          children: [
            const ChatMessages(),
            Expanded(child: const NewMessages())
          ],
        ));
  }
}
