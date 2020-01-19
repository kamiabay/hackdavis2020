import 'package:danger/pages/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:danger/design/mydesign.dart' as design;
import 'package:danger/style/theme.dart' as Theme;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danger/utils/bubble_indication_painter.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' as service;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/screenPicker.dart';

class LandingRoute extends CupertinoPageRoute<Null> {
  LandingRoute()
      : super(builder: (BuildContext context) {
          return new Landing();
        });
}

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> with SingleTickerProviderStateMixin {
  String _picked_univercity;
  _LandingState();
  final FormKeyIN = GlobalKey<FormState>();
  final FormKeyUP = GlobalKey<FormState>();

  String _emailSignIn, _passwordSignIn; // sign in

  String _emailSignUp,
      _passwordSignUp,
      _studnetIdSignUp,
      _fullnameSignUp,
      _firebase_uniqe_id; // log in
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController =
      TextEditingController();

  PageController _pageController;
  Color left = Colors.black;
  Color right = Colors.white;
  var paddings =
      EdgeInsets.only(top: 17.5, bottom: 17.5, left: 25.0, right: 25.0);
  Firestore firestore = Firestore.instance;
  DocumentReference FD_students, FD_students_public;
  bool loginCanTap = true;
  bool sigupCanTap = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    service.SystemChrome.setSystemUIOverlayStyle(
        service.SystemUiOverlayStyle.dark);

    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              Theme.Colors.loginGradientStart,
              Theme.Colors.loginGradientEnd
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: new Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: Text(
            "",

            ///hhhhh
            /// hi
            style: new TextStyle(
              color: design.appBarTextColor,
              fontSize: design.appBarTextSize,
              fontWeight: design.appBarTextFontWeight,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Semantics(
            label: "back button",
            child: new IconButton(
              icon: new Icon(
                Icons.arrow_back_ios,
                color: design.backButtonColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= 775.0
                  ? MediaQuery.of(context).size.height
                  : 775.0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Semantics(
                    label: "Login image",
                    child: Image(
                        height: 284.0,
                        width: 349.0,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill,
                        image: new AssetImage('images/girl.png')),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.0),
                    child: _buildMenuBar(context),
                  ),
                  Expanded(
                    flex: 2,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        if (i == 0) {
                          setState(() {
                            right = Colors.white;
                            left = Colors.black;
                          });
                        } else if (i == 1) {
                          setState(() {
                            right = Colors.black;
                            left = Colors.white;
                          });
                        }
                      },
                      children: <Widget>[
                        new ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: _buildSignIn(context),
                        ),
                        new ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: _buildSignUp(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
//            fontFamily: "WorkSansSemiBold"
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Existing",
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0,
                    // fontFamily: "WorkSansSemiBold"
                  ),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "New",
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0,
                    //  fontFamily: "WorkSansSemiBold"
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(35.0),
          child: Form(
            key: FormKeyIN,
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Material(
                      elevation: 2.0,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Semantics(
                              label: "Email Address",
                              child: Padding(
                                padding: paddings,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  focusNode: myFocusNodeEmailLogin,
                                  controller: loginEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  style: TextStyle(
                                      //fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0,
                                      color: Colors.black),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.email,
                                      color: Colors.black,
                                      size: 22.0,
                                    ),
                                    hintText: "Email Address",
                                    hintStyle: TextStyle(
                                        //fontFamily: "WorkSansSemiBold",
                                        fontSize: 17.0),
                                  ),
                                  validator: (val) {
                                    if (!val.contains('.edu') &&
                                        !val.contains('@')) {
                                      return "invalid Email";
                                    } else
                                      return null;
                                  },
                                  onSaved: (val) => _emailSignIn = val,
                                ),
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.grey[400],
                            ),
                            Semantics(
                              label: "Password",
                              child: Padding(
                                padding: paddings,
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  focusNode: myFocusNodePasswordLogin,
                                  controller: loginPasswordController,
                                  obscureText: _obscureTextLogin,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  validator: (val) {
                                    if (val.length < 8) {
                                      return "Password has to be 8 characters long";
                                    } else
                                      return null;
                                  },
                                  onSaved: (val) => _passwordSignIn = val,
                                  style: TextStyle(
                                      // fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0,
                                      color: Colors.black),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.email,
                                      size: 22.0,
                                      color: Colors.black,
                                    ),
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                        //fontFamily: "WorkSansSemiBold",
                                        fontSize: 17.0),
                                    suffixIcon: GestureDetector(
                                      onTap: _toggleLogin,
                                      child: Semantics(
                                        label: "password visibility",
                                        child: Icon(
                                          Icons.email,
                                          size: 15.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 7.0,
                        offset: new Offset(1.0, 4.0),
                      ),
                    ],
                    gradient: new LinearGradient(
                        colors: [
                          Colors.purple[300],
                          Colors.blue[700],
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: loginCanTap
                      ? MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Theme.Colors.loginGradientEnd,
                          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 42.0),
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                  fontFamily: "WorkSansBold"),
                            ),
                          ),
                          onPressed: LogInCheckSave,
                        )
                      : MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Theme.Colors.loginGradientEnd,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 42.0),
                              child: CircularProgressIndicator()),
                          onPressed: null,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: FlatButton(
                      onPressed: () {
                        //  Navigator.push(context, Email_recover());
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 16.0,
                            fontFamily: "WorkSansMedium"),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(35.0),
          child: Form(
            key: FormKeyUP,
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Material(
                      elevation: 2.0,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        child: Column(
                          children: <Widget>[

                            Semantics(
                              label: "Full name",
                              child: Padding(
                                padding: paddings,
                                child: TextFormField(
                                  focusNode: myFocusNodeName,
                                  controller: signupNameController,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                      //fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0,
                                      color: Colors.black),
                                  validator: (val) {
                                    if (val.length < 1) {
                                      return "too small";
                                    } else
                                      return null;
                                  },
                                  onSaved: (val) => _fullnameSignUp = val,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      color: Colors.black,
                                    ),
                                    hintText: "Full Name",
                                    hintStyle: TextStyle(
                                        // fontFamily: "WorkSansSemiBold",
                                        fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.grey[400],
                            ),
                            Semantics(
                              label: "university email address",
                              child: Padding(
                                padding: paddings,
                                child: TextFormField(
                                  focusNode: myFocusNodeEmail,
                                  controller: signupEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  style: TextStyle(
                                      //fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0,
                                      color: Colors.black),
                                  validator: (val) {
                                    if (!val.contains('@')) {
                                      return "invalid Email";
                                    } else
                                      return null;
                                  },
                                  onSaved: (val) => _emailSignUp = val,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(
                                      FontAwesomeIcons.envelope,
                                      color: Colors.black,
                                    ),
                                    hintText: "Email Address",
                                    hintStyle: TextStyle(
                                        //fontFamily: "WorkSansSemiBold",
                                        fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.grey[400],
                            ),
                            Semantics(
                              label: "password",
                              child: Padding(
                                padding: paddings,
                                child: TextFormField(
                                  focusNode: myFocusNodePassword,
                                  controller: signupPasswordController,
                                  obscureText: _obscureTextSignup,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  style: TextStyle(
                                      // fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0,
                                      color: Colors.black),
                                  validator: (val) {
                                    if (val.length < 8) {
                                      return "Has to be 8 characters";
                                    } else
                                      return null;
                                  },
                                  onSaved: (val) => _passwordSignUp = val,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(
                                      FontAwesomeIcons.lock,
                                      color: Colors.black,
                                    ),
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                        // fontFamily: "WorkSansSemiBold",
                                        fontSize: 16.0),
                                    suffixIcon: GestureDetector(
                                      onTap: _toggleSignup,
                                      child: Semantics(
                                        label: "password visibility",
                                        child: Icon(
                                          FontAwesomeIcons.eye,
                                          size: 15.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 7.0,
                        offset: new Offset(1.0, 4.0),
                      ),
                    ],
                    gradient: new LinearGradient(
                        colors: [
                          Colors.purple[300],
                          Colors.blue[700],
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: sigupCanTap
                      ? MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Theme.Colors.loginGradientEnd,
                          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 42.0),
                            child: Text(
                              "SIGN UP",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                  fontFamily: "WorkSansBold"),
                            ),
                          ),
                          onPressed: SignUpCheck_save,
                        )
                      : MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Theme.Colors.loginGradientEnd,
                          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 42.0),
                              child: CircularProgressIndicator()),
                          onPressed: null,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void LogInCheckSave() {
    final form = FormKeyIN.currentState;
    if (form.validate()) {
      setState(() {
        loginCanTap = false;
        print(loginCanTap);
        _buildSignIn(context);
      });
      form.save();
      _ensureLoggedIn();
    }
  }

  Future<Null> _ensureLoggedIn() async {
    _emailSignIn = _emailSignIn.toLowerCase().trim();
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();

    AuthResult Auth = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _emailSignIn,
      password: _passwordSignIn,
    )
        .catchError((e) {
      setState(() {
        loginCanTap = true;
      });
      showMessage("Email and password don't match", 2);
    });


    if (Auth.user.uid != null) {
      String loggedIn = 'true';
      prefs.setString('userid', Auth.user.uid);
      prefs.setString('loggedIn', loggedIn);
      loginCanTap = true;
      Navigator.push(context, ScreenPickerRoute(Auth.user.uid));
    } else {
      setState(() {
        loginCanTap = true;
      });
      showMessage("User does not exit", 2);
    }
    setState(() {
      loginCanTap = true;
    });
  }

  void SignUpCheck_save() async {
    final form = FormKeyUP.currentState;
    if (form.validate()) {
      setState(() {
        sigupCanTap = false;
        _buildSignUp(context);
      });
      form.save();
      createAcount();
    }
  }

  void createAcount() async {
    _emailSignUp = _emailSignUp.toLowerCase().trim();
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    AuthResult Auth = await _auth
        .createUserWithEmailAndPassword(
      email: "${_emailSignUp}",
      password: "${_passwordSignUp}",
    ).catchError((error) {
      showMessage("Email already exists", 2);
      setState(() {
        sigupCanTap = true;
      });
    });

    String id = Auth.user.uid.toString();
    print(id);
    await firestore
        .collection("User")
        .document(Auth.user.uid.toString()).setData({
     "fullName": _fullnameSignUp,
      "email": _emailSignUp,
      "UID": id,
    });

    if (Auth.user.uid != null) {
      String loggedIn = 'true';
      prefs.setString('userid', Auth.user.uid);
      prefs.setString('loggedIn', loggedIn);
      loginCanTap = true;
      Navigator.push(context, ScreenPickerRoute(id));
    }
    //addToDatabase(Auth.user.uid.toString());
  }

  void addToDatabase(String uid) async {
    showMessage('Creating your account please wait', 4);
    await firestore.collection("User").document(uid).setData({
      "full-name": _fullnameSignUp,
      "email": _emailSignUp,
      "UID": uid,
      'fcmToken': '',
    });

    String searchKey = _fullnameSignUp[0].toUpperCase() + _fullnameSignUp[1].toUpperCase();
    await firestore
        .collection("User_public")
        .document(uid).setData({
      "full-name": _fullnameSignUp,
      "email": _emailSignUp,
      "UID": uid,
      "searchKey": searchKey,
      'showActivity': false,
      'searchAble': true,
    });

  }

//  Future<Uint8List> getImageFromAssets(String path) async {
//    ByteData byteData = await rootBundle.load('$path');
//    return byteData.buffer
//        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
//  }
//  Future<String> uploadImage(String uid) async {
//    final FirebaseStorage storage =
//        FirebaseStorage(storageBucket: 'gs://appavatar/');
//    String filePath = '$_picked_univercity/publicPhoto/$uid';
//    StorageReference ref = storage.ref().child(filePath);
//    StorageUploadTask uploadTask =
//        ref.putData(await getImageFromAssets('images/pavatar.png'));
//    var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
//    String url = downurl.toString();
//    print("url :" + url);
//    return url;
//  }
  void showMessage(String s, int i) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: new Text(
          s,
          style: TextStyle(
            fontSize: 19.0,
          ),
        ),
        duration: new Duration(seconds: i),
      ),
    );
  }
}
