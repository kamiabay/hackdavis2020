import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'uploadPhoto.dart';

class AccountRoute extends CupertinoPageRoute<Null>{
  String UID;
  String photoURL;
  AccountRoute(this.UID,this.photoURL) : super (builder: (BuildContext context){
    return new Account(UID,photoURL);
  });
}

class Account extends StatefulWidget {
  String UID;
  String photoURL;
  Account(this.UID,this.photoURL);
  @override
  _AccountState createState() => _AccountState(UID,photoURL);
}

class _AccountState extends State<Account> {
  String UID;
  String photoURL;
  _AccountState(this.UID,this.photoURL);

  var firestore = Firestore.instance;


  bool _loading = false;
  bool photoExist = false;

  void initState() {
    super.initState();

  }




  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          accountWidget(),
        ],
      ),
    );
  }
  Widget accountWidget() {
    if (_loading == true){
      return Container(
        color: Colors.white,
        child: Center(
          child: SpinKitRotatingCircle(
            color: Colors.purple[300],
            size: 50.0,
          ),
        ),
      );
    }
    else return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profile",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.9),
      ),

      body: Container(
//        width: 200,
//        height: 500,
       // color: Colors.red,
       // child: avatarWidget(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:  (){
          Navigator.push(context, UploadRoute(UID));
        },
        tooltip: 'Upload your photo', label: Icon(Icons.camera_enhance),
      ),

    );
  }
  Widget personPhoto() {
    if (photoExist) {
      return CircleAvatar(
        backgroundImage: NetworkImage(photoURL),
      );
    } else return CircleAvatar(
      child: Icon(Icons.person,color: Colors.deepPurple,size: 75,),
      backgroundColor: Colors.purple[300].withOpacity(0.3),
    );
  }
  Widget avatarWidget() {
    return Container(
      height: MediaQuery.of(context).size.height *.2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
              ),
            ),
            Container(
              height: 125,
              width: 125,
              child: personPhoto(),
            ),
          ],
        ),
      ),
    );
  }




}

