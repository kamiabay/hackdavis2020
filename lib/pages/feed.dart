import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danger/widgets/myWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class FeedRoute extends CupertinoPageRoute<Null> {
  final String UID;
  FeedRoute(this.UID) : super(builder: (BuildContext context) {
    return new Feed(UID);
  });
}

class Feed extends StatefulWidget {
  final String UID;
  Feed(this.UID);
  @override
  _FeedState createState() => _FeedState(UID);
}

class _FeedState extends State<Feed> {
  final String UID;
  _FeedState(this.UID);
  List<IssueData> myData = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double lat,long;
  double radius = 50;
  bool loading = true;
  Stream<List<DocumentSnapshot>> stream;
  var firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  CollectionReference issueLocations;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    issueLocations = firestore.collection("issueLocations");
    getMyLocationData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromRGBO(242, 242, 243, 1),
      appBar:AppBar(
        title: Text(
          "Feed",
          style: new TextStyle(
            color: Colors.blue[900],
            fontSize: 25.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: body(),
    );
  }

  Widget body() {
    return loading? Spiner(): StreamBuilder<Object>(
      stream: stream,
      builder: (context, snapshot) {
        return Container(
            child: ListView.builder(
            itemCount: myData.length,
            itemBuilder: (context, index) {
              String comment = myData[index].comment;
              String key = myData[index].key.toString();
              String rank = myData[index].rank.toString();
              String incedentURL = myData[index].incedentURL.toString();
              String avatarURL = myData[index].avatarURL.toString();
              return  Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    //color: Colors.red,
                    borderRadius: BorderRadius.circular(30.0),
                    elevation: 1.5,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left:5,right: 5.0,top: 20,bottom: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width*.85,
                            height: MediaQuery.of(context).size.height*.39,
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
                         // color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left:25.0),
                                child: Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: avatarURL != null ? NetworkImage(avatarURL) : AssetImage('images/pavatar.png'),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:20.0,top: 20,bottom: 20),
                                child: Container(
                                 // color: Colors.yellow,
                                  width: MediaQuery.of(context).size.width *0.55,
                                  child: Text(comment,
                                    style: TextStyle(
                                      fontSize: 15,
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
                                        padding: const EdgeInsets.only(right:0.0),
                                        child: Text(rank,style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5.0),
                                      child: InkWell(
                                          child: Center(
                                            child: Icon(Icons.expand_less,
                                              color: Color.fromRGBO(40, 163, 55,1),
                                              size: 55,
                                            ),
                                          ),
                                          onTap: () async {
                                           await issueLocations.document(key).setData({
                                              "rank": FieldValue.increment(1),
                                            },merge: true);
                                           _scaffoldKey.currentState.showSnackBar(new SnackBar(
                                             content: new Text(
                                               "Up voted",
                                               textAlign: TextAlign.center,
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 16.0,
                                               ),
                                             ),
                                             backgroundColor: Colors.blue,
                                             duration: Duration(seconds: 3),
                                           ));
                                           print("up voted");
                                           myData.sort((a, b) => b.rank.compareTo(a.rank));
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
                    ),
                  ),
                ),
              );
             }
            ),
        );
      }
    );
  }
  void getMyLocationData() async {
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
      myData = [];
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
        myData.sort((a, b) => b.rank.compareTo(a.rank));

      });
    });
    setState(() {
      loading = false;
      body();
    });
  }

}

class IssueData {
  double lat,long;
  String comment,uid,geohash,avatarURL,incedentURL,key;
  int rank;
  IssueData(this.lat,this.long,this.comment,this.rank,this.uid,this.geohash,this.avatarURL,this.incedentURL,this.key);
}
