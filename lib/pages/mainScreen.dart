import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  Completer<GoogleMapController> _controller = Completer();
  final Map<String, Marker> _markers = {};
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.42796133580664, -120.085749655962),
    zoom: 5,
  );
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          "txt",
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
      ),
      body: Container(
        height: 1000,
        width: 1000,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers.values.toSet(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Get Location',
        child: Icon(Icons.flag),
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
    _controller.future.then(
            (GoogleMapController controller) => controller.moveCamera(camUpdate)
    );
    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
        draggable: true,
      );
      _markers["Current Location"] = marker;
    });
  }
}