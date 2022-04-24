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
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView.builder(
        itemCount: _itemCount,
        itemBuilder: (BuildContext context, int index) {
          return Tweezes();
        },
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
}
