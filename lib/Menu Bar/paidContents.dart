import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';

class MySubscription extends StatefulWidget 
{
	@override
	MySubscriptionState createState() => MySubscriptionState();
}

class MySubscriptionState extends State<MySubscription>with SingleTickerProviderStateMixin 
{
	var monthlySubscription;

	bool monthlyData = false;

	@override
	void initState()
	{
		super.initState();
		paymentHistory.clear();
		fetchPaymentHistory();

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
			// body: noPaymentHistory()
			body: paymentHistory.length == 0 ? monthlyData == true ? monthlySubscriptionDetails(context) : noPaymentHistory() : paidContents(),
			backgroundColor: Color(int.parse("0xff02071a")),
		);
	}

	Widget appBar()
	{
    	return AppBar
		(
      		title: Text("My Subscriptions",style: TextStyle(fontSize: 16.0),),
      		centerTitle: true,
      		backgroundColor: Colors.black,
    	);
  	}

	Widget noPaymentHistory()
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
      		child: Icon(Icons.history, size: 150.0, color: Color.fromRGBO(70, 70, 70, 1.0),),
    	);
  	}

	Widget message()
	{
		return  Padding(padding: EdgeInsets.only(left: 50.0, right: 50.0),
		child: Text("You don't have any subscribed contents.",
			style: TextStyle(height: 1.5,color: Colors.white70),
		),
		);
	}

	Widget paidContents()
	{
		return ListView.builder
		(
			padding: EdgeInsets.only(top:10, left: 5, right: 5, bottom: 10),
			itemCount: paymentHistory.length,
			itemBuilder: (BuildContext context, int index)
			{
				return GestureDetector
				(
					child: Card
					(
						margin: EdgeInsets.only(bottom: 15, left: 5, right: 5),
						elevation: 6,
						color: Colors.white12,
						child:Container
						(
							// color: Colors.redAccent,
							padding: EdgeInsets.only(left: 0),
							height: 100,
							child:  Row
							(
								crossAxisAlignment: CrossAxisAlignment.start,
								children:
								[
									Container
									(
										width: 75,
										height: 100,
										child: ClipRRect
										(
											borderRadius: BorderRadius.circular(5.0),
											child: Image.network
											(
												paymentHistory[index]["poster"].toString(),
												fit: BoxFit.cover,
												errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
												{
													return Image.asset("assets/images/logo.png");
												}
											)
											// child: FadeInImage
											// (
											// 	image: NetworkImage(paymentHistory[index]["poster"]),
											// 	placeholder: AssetImage("assets/images/logo.png"),
											// 	fit: BoxFit.cover,
											// ),
										),
									),
									SizedBox(width: 10,),
									details(index)
								],
							)
						),
					),
					onTap: ()
					{
						Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetails(paymentHistory[index])));
					},
				);
			}
		);
	}

	Widget details(index)
	{
		DateTime date;
		date = DateTime.parse(paymentHistory[index]["datetime"]);
		var formattedDate = "${date.day}-${date.month}-${date.year}" ;

		return Column
		(
			crossAxisAlignment: CrossAxisAlignment.start,
			children:
			[
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text(paymentHistory[index]["title"].toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text("Date: " + formattedDate, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5)),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 10, left: 15),
					child: Text
					(
						paymentHistory[index]["ref_no"], 
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, letterSpacing: 1,)
					),
				),
			],
		);
	}

	Widget monthlySubscriptionDetails(context)
	{
		return Container
		(
			height: 150,
			padding: EdgeInsets.only(left: 10, right: 10, top: 25),
			child: ListTile
			(
				// tileColor: Colors.white.withOpacity(0.1), 
				title: Text("Amount Paid:  Rs " + monthlySubscription["amount"].toString()),
				subtitle: Column
				(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: 
					[
						SizedBox(height: 10,),
						Text("Start Date : " + monthlySubscription["start_date"]),
						SizedBox(height: 10,),
						Text("End Date : " + monthlySubscription["end_date"]),
						SizedBox(height: 10,),
						Text("Valid Days : " + monthlySubscription["valid_days"]),
						SizedBox(height: 10,),
						Text("Payment ID :  " + monthlySubscription["ref_no"]),
					],
				)
			)
		);
	}
	
	fetchPaymentHistory() async
	{

		await Server.fetchPaymentHistory();

		if(paymentHistory.length == 0)
		{
			var result = await Server.displayMonthlySubscription();

			var temp = json.decode(result);

			if(temp["response"] == "failed")
			{
				monthlySubscription = 0;
			}
			else
			{
				monthlyData = true;

				monthlySubscription = temp["data"][0];

				setState(() {
				  
				});
			}
		}
		setState(()
		{
		});
	}
}
