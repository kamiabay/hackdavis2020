
import 'package:danger/pages/mainScreen.dart';
import 'package:danger/pages/onBoarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/screenPicker.dart';

void main() {
  return runApp(Myapp());
}
class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  String loggedIn = 'none';
  String userUid="" ;
  String university ="";
  @override
  void initState() {
    super.initState();
    this._function();
  }
  Future<Null> _function() async {
    /**
        This Function will be called every single time
        when application is opened and it will check
        if the value inside Shared Preference exist or not
     **/
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('userid') != null) {
        loggedIn  = prefs.get('loggedIn'); //either prof or student
        userUid = prefs.get('userid');
        university = prefs.get('uni');
      }
      else { loggedIn = 'none';}

    });


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
    if (loggedIn == 'none'){
      return Onboarding();
    }else {
      return MainPages(userUid);
    }

  }


}

