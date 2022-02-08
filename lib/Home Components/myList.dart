import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/Home%20Components/bottomNavigationBar.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';

class MyList extends StatefulWidget
{
	@override
	MyListState createState() => MyListState();
}

  int rating = 0;

class MyListState extends State<MyList>with SingleTickerProviderStateMixin
{
	Key key;
	//int rating = 0;

	globalRating() async {
		var contentId = item["id"];
		var contentType;

		switch (item["type"]) {
			case "movie":
				contentType = "1";
				break;
			case "music":
				contentType = "2";
				break;
			case "short_film":
				contentType = "3";
				break;
			case "webseries":
				contentType = "4";
				break;
		}

		var temp = await Server.overallRating(contentId, contentType);

		var result = json.decode(temp);

		if (result["response"] == "success") {
			setState(() {
				item["ratings"] = result["data"].toString();
				rating = result["data"];
			});
		} else {
			setState(() {
				rating = 0;
			});
		}
	}

	@override
	void initState()
	{
		// wishList.clear();
		super.initState();
		displayWishlist();
		//globalRating();
		// print(wishList.length);
	}

	Map item;

	@override
	void dispose()
	{
		super.dispose();
	}

	@override
	Widget build(BuildContext context)
	{
		return  scaffold(context);
	}

    Widget scaffold(context)
    {
        return Scaffold
		(
			appBar: appBar(context),
			// body: blankNotificationContainer(),
			body:wishList.length == 0 ? blankNotificationContainer() : wishListItems(),
			bottomNavigationBar: BottomNavBar(pageInd: 2,),
			backgroundColor: Color(int.parse("0xff02071a"))
		);
    }

	Widget appBar(context)
    {
        return AppBar
        (
            backgroundColor: Colors.black,
            leading: IconButton
            (
                icon: Icon
                (
                    Icons.arrow_back,
                    color: Colors.white,
                ),
                onPressed: ()
                {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                },

            ),
            centerTitle: true,
            title: Text
            (
                "My List"
            ),
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
      		child: Icon(Icons.add_to_queue, size: 150.0, color: Color.fromRGBO(70, 70, 70, 1.0),),
    	);
  	}

	Widget message()
    {
		return Padding
        (
            padding: EdgeInsets.only(left: 50.0, right: 50.0),
            child: Text
            (
                "You don't have any favourites.",
                style: TextStyle(height: 1.5,color: Colors.white70),
            ),
		);
	}

	Widget wishListItems()
	{
		return ListView.builder
		(
			padding: EdgeInsets.only(top:10, left: 5, right: 5, bottom: 10),
			itemCount: wishList.length,
			itemBuilder: (BuildContext context, int index)
			{
				return GestureDetector
				(
					child: Dismissible
					(
						key: Key(wishList[index].toString()),
						onDismissed: (direction)
						{
							setState(()
							{
								deleteFromWishList(index);
								wishList.removeAt(index);
							});
						},
						background: slideRightBackground(),
						secondaryBackground: slideLeftBackground(),
						child: Card
						(
							margin: EdgeInsets.only(bottom: 20, left: 5, right: 5),
							elevation: 6,
							color: Colors.white12,
							child:Container
							(
								padding: EdgeInsets.only(left: 0),
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
													wishList[index]["poster"].toString(),
													fit: BoxFit.cover,
													errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
													{
														return Image.asset("assets/images/logo.png");
													}
												)
											)
										),
										SizedBox(width: 10),
										details(index)
									],
								)
							),
						),
					),
					onTap: ()
					{
						// print(wishList[index]);
						Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetails(wishList[index])));
					},
				);
			}
		);
	}

	Widget details(index)
	{
		return Column
		(
			crossAxisAlignment: CrossAxisAlignment.start,
			children:
			[
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text(wishList[index]["title"].toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text("Ratings: " + wishList[index]["ratings"], style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, letterSpacing: 1.5)),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text
					(
						wishList[index]["amount"] == "0" ? "Free" : "INR " + wishList[index]["amount"],
						style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1,)
					),
				)
			]
		);
	}

	Widget slideRightBackground()
	{
  		return Container
		(
    		color: Colors.grey[850],
    		child: Align
			(
      			child: Row
				(
        			mainAxisAlignment: MainAxisAlignment.start,
        			children: <Widget>
					[
          				SizedBox(width: 20),
						Text
						(
							"Swipe left or right to remove the item",
							style: TextStyle
							(
								color: Colors.white,
								fontWeight: FontWeight.w700,
							),
							textAlign: TextAlign.left,
						),
        			],
      			),
      			alignment: Alignment.centerLeft,
    		),
  		);
	}

	Widget slideLeftBackground()
	{
  		return Container
		(
    		color: Colors.grey[850],
    		child: Align
			(
      			child: Row
				(
        			mainAxisAlignment: MainAxisAlignment.end,
        			children: <Widget>
					[
          				SizedBox(width: 20),
						Text
						(
							"Swipe left or right to remove the item",
							style: TextStyle
							(
								color: Colors.white,
								fontWeight: FontWeight.w700,
							),
							textAlign: TextAlign.left,
						),
        			],
      			),
      			alignment: Alignment.centerRight,
    		),
  		);
	}

	// display wishlist contents
	displayWishlist() async
	{
		await Server.displayWishlist();

		setState(()
		{
		});
	}

	// api to remove from wishlist
	deleteFromWishList(index) async
	{
		var listId = wishList[index]["listId"];

		var response = await Server.deleteWishlist(listId);

		var temp = json.decode(response);

		// print(temp);

		if(temp["response"] == "success")
		{
			setState(()
			{
				// displayWishlist();
				// // print(added);
			});
		}
		else
		{
			Fluttertoast.showToast(msg: "Please try again");
		}
	}
}

ratingIcons() {
	List<Row> icons = [];

	// var icon = double.parse(item["ratings"]);

	var icon = rating;

	var temp = icon.round();

	for (int index = 0; index < temp; index++) {
		icons.add(Row(
			children: [
				Icon(
					Icons.star,
					color: Colors.greenAccent,
				),
			],
		));
	}

	return Row(children: icons);
}

