import 'package:flutter/material.dart';

Widget myAppBar(String txt,BuildContext context) {
  return  AppBar(
    title: Text(
      txt,
      style: new TextStyle(
        color: Colors.blue[900],
        fontSize: 25.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    leading: new IconButton(
      icon: new Icon(Icons.arrow_back_ios,  color: Colors.white,),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
}