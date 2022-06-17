import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/fire_storage.dart';
import 'package:tweezer/home.dart';

class NewTweez extends StatefulWidget {
  final User user;
  const NewTweez(this.user, {Key? key}) : super(key: key);

  @override
  State<NewTweez> createState() => _NewTweezState();
}

class _NewTweezState extends State<NewTweez> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final _tweezTextController = TextEditingController();
  File? picture;
  String? image_url;

  @override
  Widget build(BuildContext context) {
    final User _currentUser = widget.user;

    // CollectionReference tweezes = db.collection('tweezes');
    DocumentReference userDoc = db.collection('users').doc(_currentUser.uid);
    final Storage storage = Storage();

    return FutureBuilder(
      future: userDoc.get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong',
              textAlign: TextAlign.center);
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text('Document does not exist');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> _userData =
              snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text("New Tweez"),
              leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }),
            ),
            body: Container(
              padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: TextFormField(
                      controller: _tweezTextController,
                      decoration: InputDecoration(
                          hintText: "Write a Tweez",
                          errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ))),
                    ),
                  ),
                  Center(
                    // preview of selected image
                      child: picture != null
                          ? Image.file(picture!, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                              return const Text('');
                            })
                          : Container(
                              child: ElevatedButton(
                                onPressed: () async {

                                  // pick file in phone storage
                                  final results =
                                      await FilePicker.platform.pickFiles(
                                    allowMultiple: false,
                                    type: FileType.custom,
                                    allowedExtensions: ['png', 'jpg'],
                                  );

                                  if (results == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('No file selected')),
                                    );
                                    return;
                                  }

                                  // set folder path of the selected image
                                  final path = results.files.single.path!;
                                  final fileName = results.files.single.name;

                                  setState(() {
                                    picture = File(path);
                                  });

                                  // upload in firebase storage and get the url back
                                  storage
                                      .uploadFile(path, fileName)
                                      .then((value) {
                                    setState(() {
                                      image_url = value.toString();
                                    });
                                  });
                                },
                                child: const Text('upload picture'),
                              ),
                            )),
                ],
              ),
            ),
            floatingActionButton: ElevatedButton(
              child: const Text("Post Tweez"),
              onPressed: () {

                // if no image but text
                if (_tweezTextController.text.isNotEmpty && image_url == null) {
                  addTweezDB(
                          _tweezTextController.text,
                          "",
                          FieldValue.serverTimestamp(),
                          0,
                          _currentUser.uid,
                          _userData["username"],
                          _userData['profile picture'])
                      .then((value) => ScaffoldMessenger.of(context)
                          .showSnackBar(
                              const SnackBar(content: Text('Tweez posted'))));

                  // update number of tweezes
                  userDoc.update({'tweezes': FieldValue.increment(1)});

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(user: _currentUser),
                    ),
                    ModalRoute.withName('/'),
                  );
                
                } // if image and text
                 else if (_tweezTextController.text.isNotEmpty &&
                    image_url != null) {
                  addTweezDB(
                          _tweezTextController.text,
                          image_url!,
                          FieldValue.serverTimestamp(),
                          0,
                          _currentUser.uid,
                          _userData["username"],
                          _userData['profile picture'])
                      .then((value) => ScaffoldMessenger.of(context)
                          .showSnackBar(
                              const SnackBar(content: Text('Tweez posted'))));

                  userDoc.update({'tweezes': FieldValue.increment(1)});

                  // return home
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(user: _currentUser),
                    ),
                    ModalRoute.withName('/'),
                  );
                } // if no text but picture
                else if (_tweezTextController.text.isEmpty &&
                    image_url != null) {
                  addTweezDB(
                          _tweezTextController.text,
                          image_url!,
                          FieldValue.serverTimestamp(),
                          0,
                          _currentUser.uid,
                          _userData["username"],
                          _userData['profile picture'])
                      .then((value) => ScaffoldMessenger.of(context)
                          .showSnackBar(
                              const SnackBar(content: Text('Tweez posted'))));

                  userDoc.update({'tweezes': FieldValue.increment(1)});

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(user: _currentUser),
                    ),
                    ModalRoute.withName('/'),
                  );
                } // if no text and no image
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please write a tweez')),
                  );
                }
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> addTweezDB(String content, String image, FieldValue createdAt,
      int likes, String userId, String username, String profilePicture) async {
    CollectionReference tweezes = db.collection('tweezes');
    tweezes.add({
      'content': content,
      'image': image,
      'created_at': createdAt,
      'likes': likes,
      'user_id': userId,
      'username': username,
      'profile_picture': profilePicture,
      'user_liked': []
    });
  }
}
