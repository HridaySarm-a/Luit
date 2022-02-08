import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/menuBar.dart';
import 'package:luit/Menu%20Bar/editProfile.dart';
import 'package:luit/global.dart';

class ManageProfile extends StatefulWidget
{
	@override
	_ManageProfileState createState() => _ManageProfileState();
}

class _ManageProfileState extends State<ManageProfile> with SingleTickerProviderStateMixin
{
	AnimationController _controller;

	@override
	void initState()
	{
		super.initState();

		setState(()
		{
			luitUser = jsonDecode(prefs.getString("luitUser"));
		});

		_controller = AnimationController(vsync: this);
	}

	@override
	void dispose()
	{
		super.dispose();
		_controller.dispose();
	}

	@override
	Widget build(BuildContext context)
	{
		return WillPopScope
		( 
			child:Scaffold
			(
				backgroundColor: Color(int.parse("0xff02071a")),
				appBar: AppBar
				(
					backgroundColor: Colors.black,
					leading: IconButton
					(
						icon:  Icon
						(
							Icons.arrow_back,
							color: Colors.white,
						),
						onPressed: ()
						{
							Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuBar()));
						},
					),
					centerTitle: true,
					title: Text
					(
						"Manage Profile",
						textAlign: TextAlign.center,
						style: TextStyle
						(

						),
					),
					actions:
					[
						Padding
						(
							padding: EdgeInsets.only(right:10),
							child: 	dropDown(context)
						)
					],
				),
				body: Container
				(
					child: Padding
					(
						padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
						child: Column
						(
							children:
							[
								Row
								(
									children:
									[
										userProfileImage(),
										Container
										(
											padding: EdgeInsets.only(left: 25),
											child: Column
											(
												crossAxisAlignment: CrossAxisAlignment.start,
												children:
												[
													Text(luitUser["name"] == null ? " ": " Name: " +  luitUser["name"],  style: TextStyle(color: Colors.white, letterSpacing: 0.6)),
													SizedBox(height: 2,),
													Text("Account Status: Active", style: TextStyle(color: Colors.white, letterSpacing: 0.6))
												]
											)
										)
									],
								),
								Divider(color: Colors.white70),
								dobAndMobileNumber(),
								Divider(color: Colors.white70),
								nameAndJoinedDate()
							],
						),
					)
				),
			),
			onWillPop: ()
			{
				onWillPopScope(context);
				return null;
			},
		);
	}

	onWillPopScope(context)
	{
		Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuBar()));
	}

	Widget userProfileImage()
	{
		return Container
		(
			height: 170.0,
			width: 130.0,
			child: ClipRRect
			(
				child:  Image.network
				(
					luitUser["image"].toString() == null  ? "https://arshvitech.ca/wp-content/uploads/2017/04/default-user-image.png" : luitUser["image"].toString(),
					fit: BoxFit.cover,
					errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
					{
						return Image.asset("assets/images/logo.png", fit: BoxFit.contain,);
					}
				),
			),
		);
	}

	Widget dobAndMobileNumber()
	{
		return  Container
		(
			height: 50,
			child: Row
			(
				children:
				[
					// DATE OF BIRTH
					Container
					(
						width: 150,
						child: Column
						(
							mainAxisAlignment: MainAxisAlignment.center,
							children:
							[
								Text("Date of birth", style: TextStyle(color: Colors.white, letterSpacing: 0.6),),
								Text
								(
									luitUser["dob"] == null ? " ": luitUser["dob"],
									style: TextStyle(color: Colors.white, fontSize: 14.0, letterSpacing: 0.6),
									textAlign: TextAlign.right
								)
							],
						),
					),
					VerticalDivider(color: Colors.white70,),
					// JOINED DATE
					Container
					(
						width: 150,
						child: Column
						(
							mainAxisAlignment: MainAxisAlignment.center,
							children:
							[
								Text("Mobile number", style: TextStyle(color: Colors.white, letterSpacing: 0.6),),
								Text(luitUser["mobile"] == null ? " " : luitUser["mobile"], style: TextStyle(color: Colors.white, letterSpacing: 0.6),),
							],
						),
					),
				],
			),
		);
	}

	Widget nameAndJoinedDate()
	{
	    DateTime todayDate = DateTime.parse(luitUser["joinedOn"]);
  		DateFormat formatter = DateFormat('dd-MM-yyyy');

		var createdDate = formatter.format(todayDate);

		return  Container
		(
			height: 50,
			child: Row
			(
				children:
				[
					// Name and Email
					Container
					(
						width: 150,
						child: Column
						(
							mainAxisAlignment: MainAxisAlignment.center,
							children:
							[
								Text("Email", style: TextStyle(color: Colors.white, letterSpacing: 0.6),),
								Text
								(
									luitUser["email"] == null ? " " : luitUser["email"],
									style: TextStyle(color: Colors.white, fontSize: 10.0, letterSpacing: 0.6),
									textAlign: TextAlign.right
								)
							],
						),
					),
					// JOINED DATE
					Container
					(
						width: 150,
						child: Column
						(
							mainAxisAlignment: MainAxisAlignment.center,
							children:
							[
								Text("Joined On: ", style: TextStyle(color: Colors.white, letterSpacing: 0.6),),
								Text(createdDate, style: TextStyle(color: Colors.white, letterSpacing: 0.6)),
							],
						),
					),
				],
			),
		);
	}

	Widget dropDown(context)
	{
		return PopupMenuButton<int>
		(
			color: Colors.black38.withOpacity(0.8),
			itemBuilder: (context) =>
			[
				PopupMenuItem
				(
					value: 1,
					child: Text("Edit Profile", style: TextStyle(color: Colors.white),),
				),
			],
			onCanceled: ()
			{
				// print("You have cancelled the menu.");
			},
			onSelected: (value)
			{
				if (value == 1)
				{
					var route = MaterialPageRoute(builder: (context) => EditProfilePage());
					Navigator.push(context, route).then((value) async
					{
						print("VANDACHH APPI");
						setState(() {});
					});
				}
			},
			icon: Icon(Icons.more_vert),
		);
	}

}
