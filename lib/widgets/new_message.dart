import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget{
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewMessageState();
  }

}

class _NewMessageState extends State<NewMessage>{
  final _messageController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  void _submitMessage() async {


    //Focus.of(context).unfocus();
    final enteredMessage = _messageController.text;

    if(enteredMessage.trim().isEmpty){
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text' : enteredMessage,
      'createdAt' : Timestamp.now(),
      'userId' : user.uid,
      'username' : userData.data()!['username'],
      'userImage' : userData.data()!['image_url'],

    });

    _messageController.clear();


  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child:Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  labelText: 'Enter a message'
                ),
              ),
            ),

            IconButton(
                  onPressed: _submitMessage,
                  icon: const Icon(Icons.send_rounded)),

          ],
        ),
    );
  }

}