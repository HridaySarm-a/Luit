import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:luit/Home%20Components/UI/subscriptionPage.dart';
import 'package:luit/Home%20Components/bottomNavigationBar.dart';
import 'package:luit/LoadingComponents/login.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/LoadingComponents/signIn.dart';
import 'package:luit/Menu%20Bar/appSettings.dart';
import 'package:luit/Menu%20Bar/contentPolicy.dart';
import 'package:luit/Menu%20Bar/manageProflie.dart';
import 'package:luit/Menu%20Bar/notifications.dart';
import 'package:luit/Menu%20Bar/paymentHistory.dart';
import 'package:luit/Menu%20Bar/refundPolicy.dart';
import 'package:luit/Menu%20Bar/terms&Conditions.dart';
import 'package:luit/global.dart';

class MenuBar extends StatefulWidget
{
	@override
	State<StatefulWidget> createState()
	{
		return MenuBarPageState();
	}
}

class MenuBarPageState extends State<MenuBar>
{

	final facebookLogin = FacebookLogin();
	bool isSinglePayment = false;
	List empty = [];

	@override
	void initState()
	{
		super.initState();

		print(empty.length.toString());

		setState(()
		{
			luitUser = jsonDecode(prefs.getString("luitUser"));

			if(luitUser["id"] != null)
			{
				userId = luitUser["id"];
				getUserProfile();
			}
		});

	}

	Widget build(BuildContext context)
	{
		return Scaffold
        (
            backgroundColor: Color(int.parse("0xff02071a")),
            body: Container
			(
				padding: EdgeInsets.only(left: 10, right: 10),
				child: scaffold(context),
			),
			bottomNavigationBar: BottomNavBar(pageInd: 4,),
		);
	}

	Widget scaffold(context)
	{
		return CustomScrollView
		(
    		slivers: <Widget>
			[
      			SliverAppBar
				(
        			backgroundColor: Color(int.parse("0xff02071a")),
        			expandedHeight: 200.0,
					flexibleSpace: Column
						(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>
							[
								Flexible(flex: 1, child: Container(),),
								Flexible
								(
									flex: 3,
									child:
									Container
									(
										padding: EdgeInsets.only(bottom: 5),
										height: 100,
										width: 100,
										color: Colors.transparent,
										child: ClipRRect
										(
											borderRadius: BorderRadius.all(Radius.circular(2)),
											child: Image.network
											(
												luitUser["image"].toString() == null  ? "https://arshvitech.ca/wp-content/uploads/2017/04/default-user-image.png": luitUser["image"].toString(),
												fit: BoxFit.cover,
												errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
												{
													return Image.asset("assets/images/logo.png", fit: BoxFit.contain,);
												}
											)
										),
									)
								),
								Flexible
								(
									flex: 1,
									child: InkWell
									(
										child: Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children:
											[
												Icon(Icons.edit, size: 15, color: Colors.white,),
												SizedBox(width: 10),
												Text
												(
													"Manage Profile",
													style: TextStyle
													(
														fontWeight: FontWeight.bold,
														color: Colors.white
													),
												)
											],
										),
										onTap: ()
										{
											Navigator.push(context, MaterialPageRoute(builder: (context) => ManageProfile()));
										},
									)
								),
							],
						),
					),
      			// ),
      			SliverFixedExtentList
				(
        			itemExtent: 30.0,
        			delegate: SliverChildListDelegate
					([
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white  ),),
                            onTap: () =>
                            {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => NotificationPage()))
                            },
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('App Settings', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white  ),),
                            onTap: () =>
                            {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => AppSettingsPage()))
                            },
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Subscription Packages', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: () =>
                            {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => SubscriptionPage(empty, isSinglePayment)))
                            },
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Payment History', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: () =>
                            {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => PaymentHistory()))
                            },
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Help', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: () => {},
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Rate Us', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: () => {},
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Share App', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: () => {},
                        ),
                        // Divider(color: Colors.white),
                        // ListTile
                        // (
                        //     visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        //     leading: Text('Refund Policy', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                        //     onTap: ()
                        //     {
                        //         Navigator.push(context,MaterialPageRoute(builder: (context) => RefundPolicy()));
                        //     },
                        // ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Content Policy', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: ()
                            {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => ContentPolicy()));
                            },
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: ()
                            {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => TermsAndConditions()));
                            },
                        ),
                        Divider(color: Colors.white),
                        ListTile
                        (
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Text('Log Out', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.2, fontSize: 13, color: Colors.white),),
                            onTap: ()
                            {
                                _signOutDialog(context);
                            },
                        ),
						SizedBox(height: 25,)
                    ],
					),
      			),
    		],
		);
	}

	Widget profileImage()
	{
		return Column
		(
			children: <Widget>
			[
				Container
				(
					height: 80.0,
					width: 80.0,
					child:  Image.network
					(
						luitUser["image"].toString() == null  ? "https://arshvitech.ca/wp-content/uploads/2017/04/default-user-image.png" : luitUser["image"].toString(),
						fit: BoxFit.cover,
						errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
						{
							return Image.asset("assets/images/logo.png", fit: BoxFit.contain,);
						}
					),
					decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
				),
			],
		);
	}

    _signOutDialog(context)
	{
        // print("uhuihu");
		return showDialog
        (
			context: context,
			builder: (BuildContext context)
			{
				return AlertDialog
				(
					backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
					shape: RoundedRectangleBorder
					(
						borderRadius: BorderRadius.all(Radius.circular(25.0))),
						contentPadding: EdgeInsets.only(top: 10.0),
						content: Container
						(
							width: 300.0,
							child: Column
							(
								mainAxisAlignment: MainAxisAlignment.start,
								crossAxisAlignment: CrossAxisAlignment.stretch,
								mainAxisSize: MainAxisSize.min,
								children: <Widget>
								[
									Row
									(
										mainAxisAlignment: MainAxisAlignment.center,
										mainAxisSize: MainAxisSize.max,
										children: <Widget>
										[
											Text
											(
												"Sign Out?",
												style: TextStyle(fontWeight: FontWeight.w600),
											),
											Row
											(
												mainAxisSize: MainAxisSize.min,
												children: <Widget>[],
											),
										],
									),
									SizedBox(height: 5.0),
									Divider
									(
										color: Colors.grey,
										height: 4.0,
									),
									Padding
									(
										padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
										child: Text
										(
											"Are you sure that you want to logout?",
											style:TextStyle(color: Color.fromRGBO(155, 155, 155, 1.0)),
										),
									),
									InkWell
									(
										onTap: ()
										{
											Navigator.pop(context);
										},
										child: Container
										(
											color: Colors.white70,
											padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
											child: Text
											(
												"Cancel",
												style: TextStyle(color: Color.fromRGBO(34, 34, 34, 1.0)),
												textAlign: TextAlign.center,
											),
										),
									),
									InkWell
									(
										onTap: ()async
										{
											// print("Sign out");

  											await prefs.setBool("isLoggedIn", false);
											isLoggedIn = false;
											signOutGoogle();
											luitUser.clear();
											setSharedPreference("luitUser", jsonEncode(luitUser));
											print(luitUser);
											print("luitUser");
											facebookLogin.logOut();
    										// await _auth.signOut();
											var router = new MaterialPageRoute(builder: (BuildContext context) => Login());
											Navigator.of(context).pushReplacement(router);
										},
										child: Container
										(
											padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
											decoration: BoxDecoration
											(
												borderRadius: BorderRadius.only(
													bottomLeft: Radius.circular(25.0),
													bottomRight: Radius.circular(25.0)
												),
												gradient: LinearGradient
												(
													begin: Alignment.topCenter,
													end: Alignment.bottomRight,
													stops: [0.1, 0.5, 0.7, 0.9],
													colors:
													[
														Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
														Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
														Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
														Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
													],
												),
											),
											child: Text
											(
												"Confirm",
												style: TextStyle(color: Colors.white),
												textAlign: TextAlign.center,
											),
										),
									),
								],
							),
						),
				);
			}
        );
    }

	getUserProfile()async
	{
		await Server.userProfile(userId);
	}
}