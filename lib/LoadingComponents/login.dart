import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:luit/LoadingComponents/loadingScreen.dart';
import 'package:http/http.dart' as http;
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/LoadingComponents/signIn.dart';
import 'package:luit/global.dart';
import 'package:luit/utilities/popup.dart';

DateTime currentBackPressTime;

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController countyField = TextEditingController();
  final TextEditingController phoneField = TextEditingController();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool hasInternet = false;
  bool checkedValue = true;

  var facebookLogin = FacebookLogin();
  AccessToken _accessToken;
  UserModel _currentUser;

  var logger = Logger();
  var code = "+91";

  bool isListening = false;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          hasInternet = true;
          wifiEnabled = true;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          hasInternet = true;
        });
        break;

      case ConnectivityResult.none:
        setState(() {
          hasInternet = false;
        });
        break;

      default:
        setState(() {
          hasInternet = false;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(int.parse("0xff02071f")),
        body: hasInternet == true ? willPopScope(context) : noInternet());
  }

  Widget noInternet() {
    return Container(
      padding: EdgeInsets.only(top: 250),
      child: Column(children: [
        Icon(
          Icons.network_locked,
          size: 25,
        ),
        Center(
          child: Text("Please check your Internet Connection"),
        )
      ]),
    );
  }

  Future<void> fbLogin() async {
    final plugin = FacebookLogin(debug: true);
    String _sdkVersion;
    FacebookAccessToken _token;
    FacebookUserProfile _profile;
    String _email;
    String _imageUrl;
    await plugin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    await _updateLoginInfo(plugin);
  }

  Future<void> _updateLoginInfo(FacebookLogin plugin) async {
    final token = await plugin.accessToken;
    FacebookUserProfile profile;
    String email;
    String imageUrl;

    if (token != null) {
      profile = await plugin.getUserProfile();
      if (token.permissions.contains(FacebookPermission.email.name)) {
        email = await plugin.getUserEmail();
      }
      imageUrl = await plugin.getProfileImageUrl(width: 100, height: 100);
    }
    UserModel userModel = UserModel(
        pictureModel: PictureModel(url: imageUrl, width: 100, height: 100),
        email: email,
        id: token.token);
    _currentUser = userModel;
    // var temp = json.decode();
    print(userModel);

    // Main user object.
    // luitUser["name"] = temp["name"];
    // luitUser["email"] = temp["email"];
    // luitUser["image"] = temp["picture"]["data"]["url"];
    // // Main user object.
    // print(graphResponse.body);
    facebookLoginWithBackend(_currentUser, context);
    // setState(() {
    //
    //   // _token = token;
    //   // _profile = profile;
    //   // _email = email;
    //   // _imageUrl = imageUrl;
    // });
  }

  Widget willPopScope(context) {
    double fontSize = getFontSize(context);

    return Material(
        color: Color(int.parse("0xff02071a")),
        child: Form(
          key: formKey,
          onWillPop: () {
            onWillPop();
            return;
          },
          child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: 25, right: 25),
              child: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  SizedBox(height: 80.0),
                  Image.asset(
                    "assets/images/luit-logo.png",
                    scale: 1.0,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Sign in with",
                    style:
                        TextStyle(color: Colors.white, fontSize: fontSize / 25),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(children: [
                    Expanded(
                      child: FlatButton(
                        color: Color(0xff395693),
                        textColor: Colors.white,
                        padding: EdgeInsets.only(left: 1),
                        onPressed: () {
                          // popup(context);
                          initiateFacebookLogin(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              color: Color(int.parse("0xff395693")),
                              padding: EdgeInsets.all(0),
                              height: 40,
                              child: Image.asset(
                                "assets/images/facebookLogo.png",
                                scale: 1.9,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Facebook",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSize / 25,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Expanded(
                        child: FlatButton(
                            color: Colors.white,
                            textColor: Colors.white,
                            padding: EdgeInsets.only(left: 1),
                            onPressed: () {
                              signOutGoogle();
                              popup(context);
                              signInWithGoogle().whenComplete(() {
                                print("done");
                                googleLoginWithBackend(context);
                              });
                            },
                            child: Row(children: [
                              Container(
                                padding: EdgeInsets.all(0),
                                height: 40,
                                child: Image.asset(
                                  "assets/images/googleLogo.png",
                                  scale: 1.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Google",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSize / 25,
                                    color: Colors.black54),
                              )
                            ])))
                  ]),
                  SizedBox(height: 25),
                  Text("or",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize / 25,
                      )),
                  SizedBox(height: 25),
                  Row(children: [
                    Container(
                        width: 105,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: CountryCodePicker(
                          flagWidth: 19,
                          // showDropDownButton: true,
                          // showCountryOnly: true,
                          favorite: ["IN"],
                          alignLeft: false,
                          onChanged: _onCountryChange,
                          initialSelection: "IN",
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 15),
                          dialogBackgroundColor: Color(int.parse("0xff02071a")),
                        )),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                        child: TextFormField(
                      inputFormatters: [
                        new LengthLimitingTextInputFormatter(11),
                        // for mobile
                      ],
                      keyboardType: TextInputType.number,
                      controller: phoneField,
                      decoration: InputDecoration(
                          labelText: "Mobile Number",
                          hintText: 'Enter Your Mobile Number',
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder()),
                      style: TextStyle(color: Colors.white),
                      validator: (val) {
                        if (val.length == 0) {
                          return 'Mobile cannot be empty';
                        }

                        return null;
                      },
                      onSaved: (val) => phoneField.text = val,
                    ))
                  ]),
                  SizedBox(height: 50),
                  SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                          height: 50.0,
                          disabledColor: Colors.grey,
                          color: Color(int.parse("0xffcf2450")),
                          child: Text(
                            "Login with OTP",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: fontSize / 23,
                                letterSpacing: 1.5),
                          ),
                          onPressed: checkedValue
                              ? () async {
                                  final form = formKey.currentState;
                                  form.save();

                                  if (form.validate() == true) {
                                    popup(context);
                                    firebaseSendOtp(context, phoneField.text);
                                  }
                                }
                              : () => _isTermsAndConditionsAccepted()
                                  ? null
                                  : null)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.pink,
                        value: checkedValue,
                        onChanged: (bool value) {
                          setState(() {
                            checkedValue = value;
                          });
                        },
                      ),
                      termsAndConditions(context)
                    ],
                  ),
                ],
              ))),
        ));
  }

  getCode(String sms) {
    if (sms != null) {
      final intRegex = RegExp(r'\d+', multiLine: true);
      final code = intRegex.allMatches(sms).first.group(0);
      return code;
    }
    return "NO SMS";
  }

  // Called to check if the user has accepted the terms and conditions on the login page.
  _isTermsAndConditionsAccepted() {
    if (checkedValue == false) {
      Fluttertoast.showToast(
          msg: "Please accept the terms and conditions to proceed",
          fontSize: 12,
          backgroundColor: Colors.white,
          textColor: Colors.black);
    }

    return checkedValue;
  }

  // change in the country code
  void _onCountryChange(CountryCode countryCode) {
    selectedCountryCode = countryCode.toString();
    // print(selectedCountryCode.toString());
  }

  //  terms and conditions
  Widget termsAndConditions(context) {
    double fontSize = getFontSize(context);
    return InkWell(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: "I understand and accept the ",
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize / 30,
            ),
          ),
          TextSpan(
              text: "Terms & Conditions",
              style: TextStyle(
                color: Color(int.parse("0xffcf2350")),
                fontSize: 12,
              ))
        ]),
      ),
      onTap: () {
        // var router = MaterialPageRoute(builder: (BuildContext context) => Register());
        // Navigator.of(context).push(router);
      },
    );
  }

  // check if checkbox is checked or not
  checkBoxChecked(checkedValue) {
    if (checkedValue == true) {
      checkedValue = false;
    } else {
      checkedValue = true;
    }
  }

  // get user credentials from Facebook
  initiateFacebookLogin(context) async {
    // facebookLogin.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
    // facebookLogin.logOut();
    // var facebookLoginResult = await facebookLogin.logIn(["email", "public_profile", "user_friends"]);
    // logger.d(facebookLoginResult.accessToken);
    // logger.e(facebookLoginResult.errorMessage);
    //
    // switch (facebookLoginResult.status) {
    //   case FacebookLoginStatus.error:
    //     Fluttertoast.showToast(msg: "Error in login");
    //     break;
    //
    //   case FacebookLoginStatus.cancelledByUser:
    //     Fluttertoast.showToast(msg: "Login error, cancelled by user");
    //     break;
    //
    //   case FacebookLoginStatus.loggedIn:
    //     var graphResponse = await http.get(
    //         Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}'));
    //
    //     var temp = json.decode(graphResponse.body);
    //
    //     // Main user object.
    //     luitUser["name"] = temp["name"];
    //     luitUser["email"] = temp["email"];
    //     luitUser["image"] = temp["picture"]["data"]["url"];
    //     // Main user object.
    //     print(graphResponse.body);

    final LoginResult result = await FacebookAuth.i.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;

      final data = await FacebookAuth.i.getUserData();
      UserModel model = UserModel.fromJson(data);
      _currentUser = model;
      // var temp = json.decode();
      print(data);

      // Main user object.
      // luitUser["name"] = temp["name"];
      // luitUser["email"] = temp["email"];
      // luitUser["image"] = temp["picture"]["data"]["url"];
      // // Main user object.
      // print(graphResponse.body);
      facebookLoginWithBackend(_currentUser, context);
    }

    //break;
  }
}

// get user credentials from google
initiateGoogleLogin(context) async {
  await Firebase.initializeApp();

  var googleResponse = await googleSignIn.signIn();

  username = googleResponse.displayName;
  googleId = googleResponse.id;
  email = googleResponse.email;
  profilePic = googleResponse.photoUrl;

  try {
    signInWithGoogle().whenComplete(() {
      googleLoginWithBackend(context);
    });
  } catch (e) {
    Fluttertoast.showToast(msg: "Error in fetching user credentials");
  }
}

// function to store user logged in status into shared preference
addBoolToSF() async {
  await prefs.setBool("isLoggedIn", true);
}

// pack press event in login page
Future<bool> onWillPop() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(milliseconds: 10000)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(msg: "Press again to exit.");
    // return Future.value(false);
  }

  return SystemNavigator.pop();
  // return null;
}

// TODO: Refactor this function.
facebookLoginWithBackend(_currentUser, context) async {
  UserModel user = _currentUser;
  username = user.name;
  email = user.email;
  profilePic = user.pictureModel.url;
  facebookId = user.id;
  Fluttertoast.showToast(
      msg: "Sending Data To Backend", toastLength: Toast.LENGTH_LONG);
  var data = await Server.facebookLogin(
    user.id,
    user.name,
    user.email,
    user.pictureModel.url,
  );

  var result = json.decode(data);

  if (result["response"] == "success") {
    userId = result["userdata"][0]["id"];
    username = result["userdata"][0]["name"];
    profilePic = result["userdata"][0]["image"];
    joinedDate = result["userdata"][0]["created_at"];
    mobile = result["userdata"][0]["mobile"];
    email = result["userdata"][0]["email"];

    luitUser["id"] = userId;
    luitUser["name"] = username;
    luitUser["image"] = profilePic;
    luitUser["email"] = email;
    luitUser["mobile"] = null;
    luitUser["joinedOn"] = null;
    luitUser["dob"] = null;

    // print(luitUser);

    setSharedPreference("isLoggedIn", true, isBool: true);
    setSharedPreference("luitUser", json.encode(luitUser));

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoadingScreen()));
  } else {
    Fluttertoast.showToast(msg: "Error in login, please try again");
  }
}

// TODO: Refactor this function.
googleLoginWithBackend(context) async {
  var temp = await Server.googleLogin();

  var result = json.decode(temp);

  print(result);

  if (result["response"] == "success") {
    userId = result["userdata"][0]["id"];
    username = result["userdata"][0]["name"];
    profilePic = result["userdata"][0]["image"];
    joinedDate = result["userdata"][0]["created_at"];
    mobile = result["userdata"][0]["mobile"];
    email = result["userdata"][0]["email"];

    luitUser["id"] = userId;
    luitUser["name"] = username;
    luitUser["image"] = profilePic;
    luitUser["email"] = email;
    luitUser["mobile"] = null;
    luitUser["joinedOn"] = null;
    luitUser["dob"] = null;

    setSharedPreference("isLoggedIn", true, isBool: true);
    setSharedPreference("luitUser", jsonEncode(luitUser));

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoadingScreen()));
  } else {
    Fluttertoast.showToast(msg: "Error in login, please try again");
  }
}

class UserModel {
  final String email;
  final String id;
  final String name;
  final PictureModel pictureModel;

  const UserModel({this.pictureModel, this.email, this.id, this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      email: json["email"],
      id: json["id"] as String,
      name: json["name"],
      pictureModel: PictureModel.fromJson(json["picture"]["data"]));
}

class PictureModel {
  final String url;
  final int height;
  final int width;

  const PictureModel({this.url, this.width, this.height});

  factory PictureModel.fromJson(Map<String, dynamic> json) => PictureModel(
      url: json["url"], width: json["width"], height: json["height"]);
}

//}
