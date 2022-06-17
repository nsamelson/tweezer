import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../drawer/drawer.dart';
import '../widgets/tweezes.dart';

class UserPage extends StatefulWidget {
  final User current_user;
  final String page_username;
  const UserPage(this.current_user, this.page_username, {Key? key})
      : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late User _currentUser;
  late String page_username;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    _currentUser = widget.current_user;
    page_username = widget.page_username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Query userQuery =
        db.collection('users').where("username", isEqualTo: page_username);
    final Query tweezesQuery =
        db.collection('tweezes').where("username", isEqualTo: page_username);

    return FutureBuilder(
        future: userQuery.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                textAlign: TextAlign.center);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            List _userData = [];
            // get user info from DB
            for (var queryDocumentSnapshot in snapshot.data!.docs) {
              Map<String, dynamic> data = queryDocumentSnapshot.data();
              var profileCover = data['profile cover'];
              var profilePicture = data['profile picture'];
              var username = data['username'];
              var bio = data['bio'];
              var nbrTweezes = data['tweezes'];
              var followers = data['followers'];
              var following = data['following'];
              // var userId = data['id'];
              var userId = queryDocumentSnapshot.id;
              _userData.add([
                profileCover,
                profilePicture,
                username,
                bio,
                nbrTweezes,
                followers,
                following,
                userId
              ]);
              // print(_userData[0][7]);
            }

            // relationship btween me and searched user
            final Query relationshipQuery = db
                .collection('relationships')
                .where('follower_id', isEqualTo: _currentUser.uid)
                .where('following_id', isEqualTo: _userData[0][7]);

            // show user info
            return Scaffold(
              drawer: const MyDrawer(),
              appBar: AppBar(
                title: const Text('Tweezer'),
              ),
              body: Center(
                child: Column(
                  //Show the cover pictures, the username and the bio
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: NetworkImage(_userData[0][0]),
                        fit: BoxFit.cover,
                      )),
                      child: SizedBox(
                        width: double.infinity,
                        height: 145,
                        child: Container(
                          alignment: const Alignment(-0.9, 3),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(_userData[0][1]),
                            radius: 45.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      const SizedBox(width: 275),
                      FutureBuilder(
                        future: relationshipQuery.get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong',
                                textAlign: TextAlign.center);
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            for (var queryDocumentSnapshot
                                in snapshot.data!.docs) {
                              Map<String, dynamic> relationshipData =
                                  queryDocumentSnapshot.data();

                              // if I'm following the user
                              if (relationshipData.isNotEmpty) {
                                return ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        db
                                            .collection('users')
                                            .doc(_userData[0][7])
                                            .update({
                                          'followers': FieldValue.increment(-1)
                                        });
                                        db
                                            .collection('users')
                                            .doc(_currentUser.uid)
                                            .update({
                                          'following': FieldValue.increment(-1)
                                        });

                                        queryDocumentSnapshot.reference
                                            .delete();
                                      });
                                    },
                                    child: const Text("Unfollow"),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ));
                              }
                            }
                          }
                          // else I don't follow the user
                          return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  db
                                      .collection('users')
                                      .doc(_userData[0][7])
                                      .update({
                                    'followers': FieldValue.increment(1)
                                  });
                                  db
                                      .collection('users')
                                      .doc(_currentUser.uid)
                                      .update({
                                    'following': FieldValue.increment(1)
                                  });

                                  db.collection('relationships').doc().set({
                                    "created_at": FieldValue.serverTimestamp(),
                                    "follower_id": _currentUser.uid,
                                    "following_id": _userData[0][7],
                                  });
                                });
                              },
                              child: const Text("Follow"),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ));
                        },
                      )
                    ]),
                    // Show user data
                    const SizedBox(height: 10),
                    Row(children: [
                      const SizedBox(width: 25),
                      Text(
                        _userData[0][2],
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
                          _userData[0][3],
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black54),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    //Row to show the following/follow data
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Tweezes ${_userData[0][4]}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            "Followers ${_userData[0][5]}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            "Following ${_userData[0][6]}",
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

                    // show the tweezes of the user I searched
                    Expanded(
                        child: FutureBuilder(
                            future: tweezesQuery
                                .orderBy('created_at', descending: true)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Something went wrong',
                                    textAlign: TextAlign.center);
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                List tweezes = [];
                                for (var queryDocumentSnapshot
                                    in snapshot.data!.docs) {
                                  Map<String, dynamic> _tweezesData =
                                      queryDocumentSnapshot.data();
                                  var content = _tweezesData["content"];
                                  var date = _tweezesData["created_at"];
                                  var username = _tweezesData["username"];
                                  var profilePicture =
                                      _tweezesData["profile_picture"];
                                  var likes = _tweezesData['likes'];
                                  var image = _tweezesData['image'];
                                  var userLiked = _tweezesData['user_liked'];
                                  var tweezId = queryDocumentSnapshot.id;
                                  tweezes.add([
                                    content,
                                    date,
                                    username,
                                    profilePicture,
                                    likes,
                                    image,
                                    tweezId,
                                    userLiked
                                  ]);
                                  // var username = data["user_id"];

                                }
                                return SingleChildScrollView(
                                  child: Column(
                                    children: tweezes
                                        .map((e) => Card(
                                              child: Tweezes(e[0], e[1], e[2],
                                                  e[3], e[4], e[5], e[6], e[7]),
                                            ))
                                        .toList(),
                                  ),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            }))
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
