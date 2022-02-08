import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/LoadingComponents/loadingScreen.dart';
import 'package:luit/LoadingComponents/login.dart';
import 'package:luit/global.dart';
import 'package:splashscreen/splashscreen.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<Splash> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool _initialized = false;

  String messageTitle = "Empty";
  String notificationAlert = "alert";
  String messageDescription = "";

  @override
  void initState() {
    super.initState();
    firebaseMessaging();
    init();
    initPlatformState();

    isLoggedIn = false;

    if (prefs.containsKey("isLoggedIn")) {
      isLoggedIn = prefs.getBool("isLoggedIn");
      luitUser = jsonDecode(prefs.getString("luitUser"));
      userId = luitUser["id"];
    }
  }

  Widget build(BuildContext context) {
    handleDynamicLinks(context);
    return Container(
        color: Color(int.parse("0xff02071a")),
        padding: EdgeInsets.only(top: 150),
        child: SplashScreen(
            seconds: 2,
            navigateAfterSeconds: isLoggedIn == true ? Home() : Login(),
            image: Image.asset(
              "assets/images/luit-logo.png",
              scale: 1.0,
            ),
            backgroundColor: Color(int.parse("0xff02071a")),
            styleTextUnderTheLoader: TextStyle(),
            photoSize: 100.0,
            loaderColor: Colors.red));
  }

  getBoolValuesSF(BuildContext context) async {
    isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    }
  }

  // handles the notifications send from firebase
  firebaseMessaging() async {
    await _firebaseMessaging.subscribeToTopic('weather');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      setState(() {
        messageTitle = message.data["title"];
        messageDescription = message.data["description"];
        notificationAlert = "New Notification Alert";
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      /* Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true)); */
      setState(() {
        RemoteNotification notification = message.notification;
        messageTitle = notification.title;
        messageDescription = notification.body;
        notificationAlert = "Application opened from Notification";
      });
    });
    /* _firebaseMessaging.configure(

        // The onMessage function triggers when the notification is received while we are running the app.
        onMessage: (message) async {
      print("ON MESSAGE");

      setState(() {
        messageTitle = message["notification"]["title"];
        messageDescription = message["notification"]["description"];
        notificationAlert = "New Notification Alert";
      });
    },
        // The onResume function triggers when we receive the notification alert in the device notification bar and opens the app through the push notification itself. In this case, the app can be running in the background or not running at all.
        onResume: (message) async {
      print("ON RESUME");

      setState(() {
        messageTitle = message["data"]["title"];
        messageDescription = message["notification"]["description"];
        notificationAlert = "Application opened from Notification";
      });
    }, onLaunch: (Map<String, dynamic>
                message) async // Called when app is terminated
            {
      print("onLaunch: $message");

      var data = message["data"];

      print(data);

      // Navigator.pushNamed(context, "details");
    }); */
  }

  Future handleDynamicLinks(context) async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(data, context);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      _handleDeepLink(dynamicLink, context);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  // handles deep link
  void _handleDeepLink(PendingDynamicLinkData data, BuildContext context) {
    BuildContext context;

    final Uri deepLink = data?.link;

    if (deepLink != null) {
      if (deepLink.queryParameters["videoId"] != "") {
        dynamicLinkVideoId = int.parse(deepLink.queryParameters["videoId"]);
        dynamicLinkVideoType = deepLink.queryParameters["type"].toString();

        for (int i = 0; i < allVideos.length; i++) {
          if (allVideos[i]["id"].toString() == dynamicLinkVideoId.toString() &&
              allVideos[i]["type"].toString() ==
                  dynamicLinkVideoType.toString()) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContentDetails(allVideos[i])));
          }
        }
        deepLink.queryParameters["videoId"] = "";
      }
    }
  }

  // fetch token id
  Future<void> init() async {
    try {
      if (!_initialized) {
        /* // For iOS request permission first.
        _firebaseMessaging.requestNotificationPermissions();
        _firebaseMessaging.configure(); */

        // For iOS request permission first.
        _firebaseMessaging.requestPermission();
        //_firebaseMessaging.configure();
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

        // For testing purposes print the Firebase Messaging token
        tokenId = await _firebaseMessaging.getToken();
        print("FirebaseMessaging token: $tokenId" + " ---------");

        _initialized = true;
      }
    } catch (e) {
      print(e);
      print("ERROR IN FIREBASE TOKEN");
    }
  }

  // fetch details about device info and firebase token.
  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        // deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    deviceId = build.androidId;

    return null;
  }
}
