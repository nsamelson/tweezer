import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/Views/new_tweez.dart';
import 'package:tweezer/widgets/tweezes.dart';
import '../drawer/drawer.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard(this.user, {Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  int _itemCount = 0;

  Future<int> getCount() async {
    final QuerySnapshot qSnap = await db.collection('tweezes').get();
    final int nbr = qSnap.size;
    return nbr;
  }

  @override
  void initState() {
    getCount().then((value) {
      setState(() {
        _itemCount = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User _currentUser = widget.user;
    CollectionReference ref = db.collection('tweezes');
    var username;

    return FutureBuilder(
      future: ref.orderBy('created_at', descending: true).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong',
              textAlign: TextAlign.center);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List tweezes = [];
          for (var queryDocumentSnapshot in snapshot.data!.docs) {
            Map<String, dynamic> data = queryDocumentSnapshot.data();
            var content = data["content"];
            var date = data["created_at"];
            var username = data["username"];
            var profilePicture = data["profile_picture"];
            var likes = data['likes'];
            tweezes.add([content, date, username, profilePicture, likes]);
          }

          return Scaffold(
            drawer: const MyDrawer(),
            appBar: AppBar(title: const Text('Dashboard')),
            body: SingleChildScrollView(
              child: Column(
                children: tweezes
                    .map((e) => Card(
                          child: Tweezes(e[0], e[1], e[2], e[3], e[4]),
                        ))
                    .toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewTweez(_currentUser),
                  ),
                );
              },
              child: Icon(Icons.edit),
            ),
          );
        }
        return Text("loading");
      },
    );
  }
}
