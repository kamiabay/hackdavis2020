import 'package:danger/Sign_In_Up.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/services.dart' as service;

class OnboardingRoute extends CupertinoPageRoute<Null>{

  OnboardingRoute() : super (builder: (BuildContext context){
    return new Onboarding();
  });
}

class Onboarding extends StatefulWidget {
  Onboarding();
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  _OnboardingState();
  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('images/$assetName.png', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }
  @override
  Widget build(BuildContext context) {
    service.SystemChrome.setSystemUIOverlayStyle(service.SystemUiOverlayStyle.dark);
    const bodyStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500,
      color: Color(0xff1f1345),
    );
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 6.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top:21),
    );
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Your city is important",
          body: "Be a part of a bigger community that makes change easier",
          image: _buildImage('walking'),
          footer: Container(
            width: MediaQuery.of(context).size.width*0.85,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
//                  child: Text("• Easy ",
//                    style: TextStyle(
//                      fontSize: 13.5,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
//                  child: Text("• Effective",
//                    style: TextStyle(
//                      fontSize: 13.5,
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Change your city",
          body: "Change with us is much easier",
          footer: Container(
            // width: 370,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
//                  child: Text("• Faster",
//                    style: TextStyle(
//                      fontSize: 13.5,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
//                  child: Text("• Better",
//                    style: TextStyle(
//                      fontSize: 13.5,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(left:8.0,top:8),
//                  child: Text("• Stronger",
//                    style: TextStyle(
//                      fontSize: 13.5,
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
          image: _buildImage('landing'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => Navigator.push(context, LandingRoute()),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
