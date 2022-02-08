import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class NotificationPage extends StatefulWidget 
{
	@override
	NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage>with SingleTickerProviderStateMixin 
{

	String messageTitle = "Empty";
	String notificationAlert = "alert";

	final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
	bool _initialized = false;


	@override
  	void initState() 
	{
    	super.initState();
		init();
  	}


	Future<void> init() async 
	{
		if (!_initialized) 
		{
			/* // For iOS request permission first.
			_firebaseMessaging.requestNotificationPermissions();
			_firebaseMessaging.configure(); */
      // For iOS request permission first.
      _firebaseMessaging.requestPermission();
      //_firebaseMessaging.configure();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

			// For testing purposes print the Firebase Messaging token
			String token = await _firebaseMessaging.getToken();
			print("FirebaseMessaging token: $token" + " ---------");

			_initialized = true;
		}
	}

	@override
	void dispose() 
	{
		super.dispose();
	}

	@override
	Widget build(BuildContext context) 
	{
		return  Scaffold
		(
			appBar: appBar(),
			body: blankNotificationContainer() 
		);
	}

	Widget appBar()
	{
    	return AppBar
		(
      		title: Text("Notifications",style: TextStyle(fontSize: 16.0),),
      		centerTitle: true,
      		backgroundColor: Colors.black,
    	);
  	}

	Widget blankNotificationContainer()
	{
		return Container
		(
			color: Color(int.parse("0xff02071a")),
			alignment: Alignment.center,
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.center,
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>
				[
					notificationIconContainer(),
					SizedBox(height: 25.0),
					message(),
				],
			),
		);
	}

  	Widget notificationIconContainer()
	{
    	return Container
		(
      		child: Icon(Icons.notifications_none, size: 150.0, color: Color.fromRGBO(70, 70, 70, 1.0),),
    	);
  	}

	Widget message(){
		return  Padding(padding: EdgeInsets.only(left: 50.0, right: 50.0),
		child: Text("You don't have any notification.",
			style: TextStyle(height: 1.5,color: Colors.white70),
		),
		);
	}
}
