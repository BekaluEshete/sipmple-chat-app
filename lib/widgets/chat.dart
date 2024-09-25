import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isNotEmpty) {
          return const Center(
            child: Text('there is no messages yet'),
          );
        }
        final loadMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 14, right: 14),
          itemCount: loadMessages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadMessages[index].data();
            final nextChatMessage = index + 1 < loadMessages.length
                ? loadMessages[index + 1].data()
                : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;
            if (nextUserIsSame) {
              MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            } else {
              MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['userName'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
