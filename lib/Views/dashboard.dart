import 'package:flutter/material.dart';

import '../drawer/drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Text('Show Posts', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
