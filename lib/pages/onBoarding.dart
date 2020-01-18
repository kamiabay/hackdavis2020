import 'package:danger/landing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';


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
          title: "Enage with your professor",
          body: "Share your ideas with your lecturer, your voice needs to be heard ",
          image: _buildImage('landing'),
          footer: Container(
            width: MediaQuery.of(context).size.width*0.85,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
                  child: Text("• Ask questions live during the lecture (anonymously) ",
                    style: TextStyle(
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
                  child: Text("• Up-vote the best questions so your lecturer can \n \n   address them",
                    style: TextStyle(
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Messaging (coming soon)",
          body: "Connect with your classmates accross campus to study more effectively",
          footer: Container(
            // width: 370,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
                  child: Text("• No need to share your social media or phone number",
                    style: TextStyle(
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:8,bottom: 8),
                  child: Text("• Increase your productivity by studying in a group",
                    style: TextStyle(
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0,top:8),
                  child: Text("• A professional environment for student communication",
                    style: TextStyle(
                      fontSize: 13.5,
                    ),
                  ),
                ),
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
