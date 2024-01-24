import 'package:chat_craft/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _form = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticate = false;
  var _enteredUserName = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticate = true;
      });

      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        //for saving all the pictures into firebase

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageURL = await storageRef.getDownloadURL();
        print(imageURL);

        //specially throwing a firebase error in the catch

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUserName,
          'email': enteredEmail,
          'image_url': imageURL
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed')),
      );
      setState(() {
        _isAuthenticate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                      padding:
                          const EdgeInsets.all(16), //inner margin to the form
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min, //like wrap content
                          children: [
                            if (!_isLogin)
                              UserImagePicker(onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              }),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              //word a first letter ta capital ashbe na

                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'please enter a valid email address';
                                }
                                return null;
                              },

                              onSaved: (value) {
                                enteredEmail = value!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                                enableSuggestions: false,
                                //don't suggest any name

                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'please enter at list 4 character';
                                  }
                                  return null;
                                },

                                onSaved: (value) {
                                  _enteredUserName = value!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              //that means while typing password no one can see full pass
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'password length should be minimum 6';
                                }
                                return null;
                              },

                              onSaved: (value) {
                                enteredPassword = value!;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (_isAuthenticate)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticate)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                onPressed: _submit,
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            if (!_isAuthenticate)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'Already have an account'))
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
