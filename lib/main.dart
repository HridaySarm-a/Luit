// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:luit/LoadingComponents/splashScreen.dart';
import 'package:luit/dynamicLink.dart';
import 'package:luit/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const debug = false;

void main() async
{
	WidgetsFlutterBinding.ensureInitialized();
   	await Firebase.initializeApp();
	await FlutterDownloader.initialize(debug: true);
	SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
	prefs = await SharedPreferences.getInstance();
	dynamicLinkService = DynamicLinkService();
	runApp(App());
}

class App extends StatefulWidget
{
	@override
  	State<StatefulWidget> createState() 
	{
		return AppState();
	}
}

class AppState extends State<App>
{
	@override
	Widget build(BuildContext context)
	{
		return MaterialApp
		(
			debugShowCheckedModeBanner: false,
			title: 'Luit',
			home: Splash(),
			theme: ThemeData
			(
				brightness: Brightness.dark,
          		primaryColor: Colors.blue[800],
          	//	accentColor: Color.fromRGBO(125,183,91, 1.0),
			),
		);
	}
}


