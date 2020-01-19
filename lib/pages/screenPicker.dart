import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Bottom_NavBar.dart';
import 'mainScreen.dart';


class ScreenPickerRoute extends CupertinoPageRoute<Null>{
  final String UID;
  ScreenPickerRoute(this.UID) : super (builder: (BuildContext context){
    return new MainPages(UID);
  });
}

class MainPages extends StatefulWidget {
  final String UID;
  MainPages(this.UID);
  @override
  _MainPagesState createState() => _MainPagesState(UID);
}

class _MainPagesState extends State<MainPages> {
  final String UID;
  _MainPagesState(this.UID);
  final scaffoldKey2 = GlobalKey<ScaffoldState>();
  int pageindex ;
  PageController pageController;
  @override
  void initState() {
    super.initState();
    pageindex = 0;
    pageController = PageController(
      initialPage: 0,
    );
  }
  onPageChanged(int pageindex) {
    setState(() {
      this.pageindex = pageindex;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey2,
        bottomNavigationBar: BottomWidget(),
        body: PageView(
          children: <Widget>[
            MainScreen(UID),

          ],
          controller: pageController,
          onPageChanged: onPageChanged(pageindex),
          physics: NeverScrollableScrollPhysics(),
        )
      //getPage(_PageSelected),
    );
  }

  Widget BottomWidget() {
    return BubbleBottomBar(
      iconSize: 29,
      opacity: 0.2,
      currentIndex: pageindex,
      onTap: (int index) {
        setState(() {
          pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 289),
            curve: Curves.easeInOut,
          );
          pageindex = index;
        });
      },
      borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      elevation: 900,
      hasInk: true, //new, gives a cute ink effect
      inkColor: Colors.black12, //optional, uses theme color if not specified
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(backgroundColor: Colors.red, icon: Icon(Icons.dashboard, color: Colors.black,), activeIcon: Icon(Icons.dashboard, color: Colors.red,), title: Text("Home")),
        BubbleBottomBarItem(backgroundColor: Colors.purple, icon: Icon(Icons.rss_feed, color: Colors.black,), activeIcon: Icon(Icons.rss_feed, color: Colors.black,), title: Text("Feed"))
      ],
    );
  }
}





