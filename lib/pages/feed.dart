import 'package:danger/widgets/myWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar("Feed", context),
    );
  }
}
