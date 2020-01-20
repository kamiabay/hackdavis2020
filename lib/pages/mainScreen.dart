import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danger/pages/onBoarding.dart';
import 'package:danger/widgets/myWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'Acoount.dart';

class MainScreenRoute extends CupertinoPageRoute<Null> {
  String UID;
  MainScreenRoute(this.UID) : super(builder: (BuildContext context) {
    return new MainScreen(UID);
  });
}

class MainScreen extends StatefulWidget {
  String UID;
  MainScreen(this.UID);
  @override
  _MainScreenState createState() => _MainScreenState(UID);
}
class _MainScreenState extends State<MainScreen> {
  String UID;
  final FirebaseAuth Auth = FirebaseAuth.instance;
  _MainScreenState(this.UID);
  TextEditingController commentController =  TextEditingController();
  GoogleMapController mapController;
  File _image;
  StorageUploadTask _uploadTask;
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://hackdavis2020-263302.appspot.com/');
  String comment;
  List<Marker> _markers = [];
  List<IssueData> myData = [];
  final formKey = GlobalKey<FormState>();
  String email, fullName,photoUrl;
  double lat,long;
  double radius = 50;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var firestore = Firestore.instance;
  bool loading = true;
  Stream<List<DocumentSnapshot>> stream;
  Geoflutterfire geo = Geoflutterfire();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.42796133580664, -120.085749655962),
    zoom: 3,
  );
  CollectionReference issueLocations;
  DocumentReference DBuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    issueLocations = firestore.collection("issueLocations");
    DBuser = firestore.collection("User").document(UID);
    getMyLocation();
  }
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: <Widget>[
            Container(
              width: 100.0,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right:0.0),
                    child: Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: photoUrl != null ? NetworkImage(photoUrl) : AssetImage('images/pavatar.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          title: Text(
            "Problems",
            style: new TextStyle(
              color: Colors.white,
              fontSize: 25.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 0.0,
          iconTheme: new IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child:  Container(
            color: Color.fromRGBO(245, 247, 251,1),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader (
                  child: Column(
                    children: <Widget>[
                      Container(
                        // color: Colors.red,
                        height: 125,
                        width: 125,
                        child: Container(),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                  ),
                ),
                ListTile(
                  title: Text('Account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21.0,
                    ),
                  ),
                  onTap: ()  {
                    Navigator.push(context,AccountRoute(UID,photoUrl) );
                  },
                ),
                ListTile(
                  title: Text('Sign Out',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21.0,
                    ),
                  ),
                  onTap: () async {
                    SharedPreferences prefs;
                    prefs = await SharedPreferences.getInstance();
                    String userid = null;
                    prefs.setString('userid', userid);
                    Auth.signOut();
                    Navigator.push(context, OnboardingRoute());
                  },
                ),

              ],),
          ),
        ),
        body: loading? Spiner(): body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          elevation: 2,
          onPressed:  _getLocation,
          tooltip: 'Get Location',
          child: Icon(Icons.camera_enhance),
        ),
      ),
    );
  }
  void _getLocation() async {
     _image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: 800,maxWidth: 400);
    var currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    CameraUpdate camUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 8,
    ));
    lat = currentLocation.latitude;
    long = currentLocation.longitude;
    addCommentDialog(_image);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_markers.length.toString()),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
      ));
    });
  }
  Widget body() {
    return Container(
      child: StreamBuilder<Object>(
        stream: stream,
        builder: (context, snapshot) {
          return GoogleMap(
             markers: _markers.toSet(),
              initialCameraPosition: _kGooglePlex,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
              mapType: MapType.normal,
          );
        }
      ),
    );
  }
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
  void addCommentDialog(File _image) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
            contentPadding: EdgeInsets.all(13.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: MediaQuery.of(context).size.width *.85,
                  height: MediaQuery.of(context).size.height *.37,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: FileImage(_image),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 90,
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: commentController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Comment",
                        hintStyle: TextStyle(
                          //fontFamily: "WorkSansSemiBold",
                            fontSize: 17.0),
                      ),
                      validator: (val) {
                        if (val.length<2){
                          return "too small";
                        } else return null;
                      },
                      onSaved: (val) => comment = val,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (){
                      send(_image);
                      },
                    child: Container(
                      height: 50,
                      width: 90,
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.53),
                            blurRadius: 8.5,
                            offset: new Offset(0.0, 2.5),
                          ),
                        ],
                        gradient: new LinearGradient(
                            colors: [
                              Colors.blue[800],
                              Colors.blue[600],
                            ],
                            begin: const FractionalOffset(0.2, 0.2),
                            end: const FractionalOffset(1.0, 1.0),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp),
                      ),
                      child: Center(
                        child: Text(
                          "Send",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    ),
                  ),
                ),
              ),
            ],
          );
        });
    }
  void showDetail(IssueData myData) {
    String comment = myData.comment;
    String key = myData.key.toString();
    String rank = myData.rank.toString();
    String incedentURL = myData.incedentURL.toString();
    String avatarURL = myData.avatarURL.toString();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            contentPadding: EdgeInsets.only(top: 1.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left:15,right: 15.0,top: 15,bottom: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(incedentURL),
                    ),
                  ),
                ),
              ),
              Container(
                 //color: Colors.red,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:10.0,right: 5),
                      child: Container(
                        width: 33.0,
                        height: 33.0,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: avatarURL != null ? NetworkImage(avatarURL) : AssetImage('images/pavatar.png'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:5.0,top: 20,bottom: 20),
                      child: Container(
                        // color: Colors.yellow,
                        width: MediaQuery.of(context).size.width *0.45,
                        child: Text(comment,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromRGBO(25,41,75,1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    //Expanded(child: Material()),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left:5.0),
                              child: Text(rank,style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: InkWell(
                                child: Center(
                                  child: Icon(Icons.expand_less,
                                    color: Color.fromRGBO(40, 163, 55,1),
                                    size: 45,
                                  ),
                                ),
                                onTap: () async {
                                  await issueLocations.document(key).setData({
                                    "rank": FieldValue.increment(1),
                                  },merge: true);

                                  setState(() {
                                    body();
                                  });
                                }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
  void send(File image) async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
    }
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        "Adding..",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
    Navigator.of(context).pop();
    GeoFirePoint myLocation = geo.point(latitude: lat, longitude: long);
   String incedentURL = await _startUpload(image);
   //var values = await detectLabels(image);
   await issueLocations.add({
      "comment": comment,
      "position": myLocation.data,
      "rank":0,
      "UID": UID,
      "avatarURL": photoUrl,
      "serverTime": FieldValue.serverTimestamp(),
      "incedentURL": incedentURL,
    });
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        "Done",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
    comment = "";

  }
  void getMyLocation() async {
    var currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    CameraUpdate camUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 15,
    ));
    GeoFirePoint center = geo.point(latitude: currentLocation.latitude, longitude: currentLocation.longitude);
    String field = 'position';
    stream = geo.collection(collectionRef: issueLocations)
        .within(center: center, radius: radius, field: field);
    GeoFireCollectionRef geoRef = geo.collection(collectionRef: issueLocations);
    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach(( DocumentSnapshot document){
        GeoPoint pos = document.data['position']['geopoint'];
        double distance = document.data['distance'];
        String key = document.documentID.toString();
        String hash = document.data["position"]["geohash"].toString();
        String uid = document.data["UID"].toString();
        String comment = document.data["comment"].toString();
        String avatarURL = document.data["avatarURL"].toString();
        String incedentURL = document.data["incedentURL"].toString();
        int rank = document.data["rank"];
        myData.add(IssueData(pos.latitude,pos.longitude,comment,rank,uid,hash,avatarURL,incedentURL,key));
       Marker marker = Marker(
         markerId: MarkerId(_markers.length.toString()),
         position: LatLng(pos.latitude, pos.longitude),
         onTap: () => _onTap(pos),
       );
       _markers.add(marker);
      });
    });
    await DBuser.get(source: Source.serverAndCache).then((doc){
      print(doc.data);
      fullName = doc.data['fullName'];
      photoUrl = doc.data['photo-url'];
    });
    setState(() {
      loading = false;
      body();
    });
  }
  _onTap(GeoPoint point) {
    myData.forEach((val){
      if(val.lat == point.latitude && val.long == point.longitude){
        showDetail(val);
      }
    });
  }
  Future<String> _startUpload(File image) async {
    String filePath = 'incedentPhoto/${DateTime.now().toIso8601String()}';
    //File newimage = await testCompressAndGetFile(widget.image,widget.image.path);
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(image);
    });
    var downurl = await (await _uploadTask.onComplete).ref.getDownloadURL();
    String url = downurl.toString();
    return url;
  }

  Future<void> detectLabels(File image) async {
//    FirebaseVision.instance.labelDetector().detectInImage();
//    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(image.path);
//    final ImageLabeler labelDetector = FirebaseVision.instance.imageLabeler();
//    final labels  = await labelDetector.processImage(visionImage);
//    labels.forEach((f){
//      print(f.text);
//    });
//    _addItem(labelTexts);
  }
}
class IssueData {
  double lat,long;
  String comment,uid,geohash,avatarURL,incedentURL,key;
  int rank;
  IssueData(this.lat,this.long,this.comment,this.rank,this.uid,this.geohash,this.avatarURL,this.incedentURL,this.key);
}



