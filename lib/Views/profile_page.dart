import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/Views/edit_profile.dart';
import 'package:tweezer/drawer/drawer.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage(this.user, {Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = db.collection('users');
    return FutureBuilder(
        future: users.doc(_currentUser.uid).get(),
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
              drawer: const MyDrawer(),
              appBar: AppBar(
                title: const Text('Tweezer'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: NetworkImage(_userData['profile cover']),
                        fit: BoxFit.cover,
                      )),
                      child: SizedBox(
                        width: double.infinity,
                        height: 145,
                        child: Container(
                          alignment: const Alignment(-0.9, 3),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(_userData['profile picture']),
                            radius: 45.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      const SizedBox(width: 275),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfile(_currentUser),
                              ),
                            );
                          },
                          child: const Text("Edit profile"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ))
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const SizedBox(width: 25),
                      Text(
                        _userData['username'],
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.left,
                      ),
                    ]),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 25),
                        Text(
                          _userData['bio'],
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black54),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // const SizedBox(width: 25),
                          Text(
                            "Tweezes ${_userData['tweezes']}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                          // const SizedBox(width: 25),
                          Text(
                            "Followers ${_userData['followers']}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                          // const SizedBox(width: 25),
                          Text(
                            "Following ${_userData['following']}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ]),
                    const SizedBox(height: 5),
                    const Divider(
                      color: Colors.black,
                      thickness: 0.5,
                    ),
                  ],
                ),
              ),
            );
          }
          return const Text('loading');
        });
  }
}
