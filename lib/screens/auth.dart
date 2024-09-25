import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogedIn = true;
  var _enterdEmail = '';
  var _enterdPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;
  var _enteredUserName = '';
  void _submit() async {
    final isvalid = _form.currentState!.validate();
    if (!isvalid || !_isLogedIn && _selectedImage == null) {
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogedIn) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _enterdEmail, password: _enterdPassword);
      } else {
        final userCredentail = await _firebase.createUserWithEmailAndPassword(
            email: _enterdEmail, password: _enterdPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredentail.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imgUrl = await storageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentail.user!.uid)
            .set({
          'user_name': 'tobee.....',
          'email': _enterdEmail,
          'image_url': imgUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        /////////
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication faild')));
      _isAuthenticating = false;
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
                    top: 30, bottom: 20, right: 20, left: 20),
                width: 200,
                child: Image.asset('assets/image/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogedIn)
                            UserImagePicker(
                              onPickedimage: (pickedimage) {
                                _selectedImage = pickedimage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                label: Text("email adresse")),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains(('@'))) {
                                return 'please enter the valid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enterdEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(label: Text('username')),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'please enter atleast 4 character';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUserName = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(label: Text("Password")),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'please enter atleast 6 character';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enterdPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 22,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogedIn ? "Login " : "signup")),
                          const SizedBox(
                            height: 7,
                          ),
                          if (!_isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogedIn = !_isLogedIn;
                                  });
                                },
                                child: Text(_isLogedIn
                                    ? "create an account"
                                    : "I already have an account"))
                        ],
                      )),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
