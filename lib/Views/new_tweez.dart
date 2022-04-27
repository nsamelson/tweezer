import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tweezer/Views/dashboard.dart';
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

  @override
  Widget build(BuildContext context) {
    final User _currentUser = widget.user;
    CollectionReference tweezes = db.collection('tweezes');
    DocumentReference userDoc = db.collection('users').doc(_currentUser.uid);
    final Storage storage = Storage();
    late String picture;

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
                    child: ElevatedButton(
                      onPressed: () async {
                        final results = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['png', 'jpg'],
                        );

                        if (results == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No file selected')),
                          );
                          return null;
                        }

                        final path = results.files.single.path!;
                        final fileName = results.files.single.name;

                        storage
                            .uploadFile(path, fileName)
                            .then((value) => print('done'));
                      },
                      child: Text('upload picture'),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: ElevatedButton(
              child: const Text("Post Tweez"),
              onPressed: () {
                if (_tweezTextController.text.isNotEmpty) {
                  tweezes.add({
                    'content': _tweezTextController.text,
                    'created_at':
                        DateFormat('dd-MM-yyyy - kk:mm').format(DateTime.now()),
                    'likes': 0,
                    'user_id': userDoc,
                    'username': _userData["username"],
                    'profile_picture': _userData['profile picture'],
                  }).then((value) => print("Tweez posted"));

                  userDoc.update({'tweezes': FieldValue.increment(1)});

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(user: _currentUser),
                    ),
                    ModalRoute.withName('/'),
                  );
                } else {
                  print("Please write a tweez");
                }
              },
            ),
          );
        }

        return Text("Loading");
      },
    );
  }
}
