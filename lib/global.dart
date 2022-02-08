import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/LoadingComponents/loginOTP.dart';
import 'package:luit/dynamicLink.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext ctx;
Home homeContext;

var username;
var dob;
var age;
var joinedDate;
var mobile = "";
var userId;
var profilePic;
var email;
var facebookId;
var googleId;
var referenceNumber;

// Firebase variables
FirebaseAuth firebaseAuth;
// Firebase variables

// OTP Related variables
String selectedCountryCode = "+91";
bool isOtpEntered = false;
// OTP Related variables

var videoPaused;
var continueWatching;
var pauseAt;

bool wifiEnabled = true;
bool oneTimePayment = false;
bool subscriptionMode = false;
bool isLoggedIn = false;
SharedPreferences prefs;
// bool videoPlaying = false;

// notification variables
var tokenId;
var deviceId;
// notification variables

List allDataList = [];
List allVideos = [];
List movies = [];
List music = [];
List shortFilms = [];
List series = [];
List newReleasedMovies = [];
List newReleasedMusic = [];
List newReleasedShortFilms = [];
List moviesByLanguagesList = [];
List musicByLanguagesList = [];
List shortFilmByLanguageList = [];
List moviesByActors = [];
List musicByActors = [];
List actors = [];
List subscriptionPlans = [];
List wishList = [];
List paymentHistory = [];
List subscribedContents = [];
// List continueWatching = [];

var imagePlaceholder = AssetImage("assets/images/2.jpeg");
var fetchMoviesResponse;

/* Dynamic link */
DynamicLinkService dynamicLinkService;
int dynamicLinkVideoId = 0;
String dynamicLinkVideoType = "";
/* Dynamic link */

Map luitUser = {
  "name": "",
  "dob": "",
  "image": "",
  "email": "",
  "mobile": "",
  "joinedOn": "",
  "id": "",
  "login_phone_no": "",
  "image64": ""
};

var userVideos = [];
var userWishListVideoIds = [];

Map localVideos = {
  "title": "",
  "id": "",
  "type": "",
  "url": "",
  "path": "",
  "seasonId": "",
  "episodeId": ""
};

List downloadedVideos = [];

getFontSize(context) {
  double width = MediaQuery.of(context).size.width;

  return width;
}

addBoolToSF() async {
  await prefs.setBool("isLoggedIn", true);
}

setSharedPreference(String key, value, {isBool = false}) async {
  if (isBool) {
    // print("Caught @ 1");
    await prefs.setBool(key, value);
  } else {
    // print("Caught @ 2");
    await prefs.setString(key, value);
    // print("saved to shared preference");
  }
}

Future<void> firebaseSendOtp(BuildContext context, String phoneNumber,
    {bool resend = false}) async {
  var phone = selectedCountryCode + phoneNumber;

  mobile = phoneNumber;

  firebaseAuth = FirebaseAuth.instance;

  firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential authCredential) async {
        isOtpEntered = true;
        // print('Received phone auth credential: $authCredential');
      },
      verificationFailed: (FirebaseAuthException authException) {
        print(authException.message);
        Fluttertoast.showToast(msg: authException.message);
      },
      codeSent: (String verificationId, [int forceResendingToken]) async {
        // Disabling loader once the OTP has been sent.
        Navigator.pop(context);

        var firebaseOTPVerificationId = verificationId.toString();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoginOTP(firebaseOTPVerificationId)));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = verificationId;
        // Fluttertoast.showToast(msg: "Time out, please try again");
      });
}

Future<UserCredential> firebaseVerifyOTP(
    String otpVerificationId, String otpEntered) async {
  // Verifying the credentials.
  AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: otpVerificationId, smsCode: otpEntered);

  // Fetching user details.
  UserCredential result = await firebaseAuth.signInWithCredential(credential);

  return result;
}
