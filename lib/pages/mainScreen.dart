import 'package:danger/pages/onBoarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  GoogleMapController mapController;
  List<Marker> _markers = [];
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.42796133580664, -120.085749655962),
    zoom: 5,
  );
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Problems",
            style: new TextStyle(
              color: Colors.blue[900],
              fontSize: 25.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: new IconThemeData(color: Colors.red),
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
                    //Navigator.push(context,StudentAccountRoute(ownUID, uni,phoneToken) );
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
        body: body(),
        floatingActionButton: FloatingActionButton(
          onPressed:  _getLocation,
          tooltip: 'Get Location',
          child: Icon(Icons.flag),
        ),
      ),
    );
  }
  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    CameraUpdate camUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 15,
    ));
    mapController.moveCamera(camUpdate);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_markers.length.toString()),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
        draggable: true,
      ));
    });
  }

 Widget body() {
    return Stack(
     children: <Widget>[
       Container(
         child: GoogleMap(
            markers: _markers.toSet(),
             initialCameraPosition: _kGooglePlex,
             onMapCreated: _onMapCreated,
             myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
             mapType: MapType.normal,
            // trackCameraPosition: true
         ),
       ),

       Container(

       ),
     ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }


}