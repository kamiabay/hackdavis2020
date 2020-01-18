import 'package:danger/landing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  return runApp(Myapp());
  //test change
}
class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        home: mainScreen(),
        theme:  ThemeData(
          buttonColor: Colors.red,
        ),
      );
  }
  mainScreen() {
    return Landing();
  }
}

