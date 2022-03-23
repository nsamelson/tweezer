// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/Views/profile_page.dart';
import '../home.dart';
import 'drawer_header.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final User _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const MyHeaderDrawer(),
            MyDrawerList(),
          ],
        ),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(1, "Home"),
          menuItem(2, "Profile"),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title) {
    return Material(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(user: _currentUser)));
            } else if (id == 2) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfilePage(_currentUser)));
            }
          });
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (context) => ProfilePage(_currentUser)));
        },
      ),
    );
  }
}
