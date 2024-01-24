import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_craft/widgets/message_bubble.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Message Found'),
            );
          }

          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final loadMessages = chatSnapshots.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(left: 13, right: 13, bottom: 30),
              itemCount: loadMessages.length,
              reverse: true,
              itemBuilder: (ctx, index) {
                final chatMessage = loadMessages[index].data();
                final nextChatMessage = index + 1 < loadMessages.length
                    ? loadMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;

                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });

    return const Center(
      child: Text('No Message Found'),
    );
  }
}
