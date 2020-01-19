import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MainScreenRoute extends CupertinoPageRoute<Null> {
  String UID;
  MainScreenRoute(this.UID) : super(builder: (BuildContext context) {
    return new MainScreen();
  });
}

class MainScreen extends StatefulWidget {
  String UID;
  MainScreen();
  @override
  _MainScreenState createState() => _MainScreenState(UID);
}

class _MainScreenState extends State<MainScreen> {
  String UID;
  _MainScreenState(this.UID);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
    );
  }
}
