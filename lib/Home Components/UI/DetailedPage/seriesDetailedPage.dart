import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentRating.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/seriesContentDetails.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';
import 'package:share/share.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';


class SeriesContentDetails extends StatefulWidget
{
	SeriesContentDetails(this.item);
	final  item;

    @override
    _SeriesContentDetailsState createState()
	{
		return _SeriesContentDetailsState(this.item);
	}
}

class _SeriesContentDetailsState extends State<SeriesContentDetails> with SingleTickerProviderStateMixin
{
	_SeriesContentDetailsState(this.item);
	final  item;

    AnimationController _controller;

    Icon _iconUp = Icon(Icons.keyboard_arrow_up);
    Icon _iconDown = Icon(Icons.keyboard_arrow_down);

    bool iconExpanded = false;
	bool added = false;
	bool paymentStatus = false;

	String temp;

    @override
    void initState()
    {
		temp = item["description"];
        super.initState();
		checkAddedToWishlist();
		checkPaymentStatus();
		globalRating();
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
        return Scaffold
        (
            backgroundColor: Color(int.parse("0xff02071a")),
            body: SingleChildScrollView
            (
				// physics: BouncingScrollPhysics(),
                child: Column
                (
                    children:
                    [
                        // BACKGROUND IMAGE, POSTER AND ITEM DETAILS
                        backGroundImage(context),
                        // DESCRIPTION
                        description(),
                        //4 ICON BUTTONS
                        iconButtons(),
                        SizedBox(height: 40),
                        // MORE LIKE THIS AND INFO
                        SeriesContentPageTabBar(item, this.paymentStatus)
                    ]
                ),
            )
        );
    }

    Widget backGroundImage(context)
    {
        return  Stack
		(
			children: <Widget>
			[
                // BACKGROUND IMAGE
				Container
				(
					height: 400.0,
					width: 500,
					child: ShaderMask
                    (
                        shaderCallback: (rect)
                        {
                            return LinearGradient
                            (
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.1, 0.6],
                                colors: [Colors.black, Colors.transparent],
                            )
                            .createShader(Rect.fromLTRB(100, 100, 200, 350));
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.network(item["poster"],fit: BoxFit.contain,)
                    ),
				),
                // BACK ARROW BUTTON
                Positioned
                (
                    top: 30.0,
                    left: 4.0,
                    child:  BackButton(color: Colors.white),
                ),
                Positioned
                (
                    top:170,
                    left:10,
                    child: Container
                    (
                        color: Colors.transparent,
                        child: Row
                        (
                            crossAxisAlignment: CrossAxisAlignment.start,
			                mainAxisAlignment: MainAxisAlignment.start,
			                children:
                            [
                                itemPoster(context),
                                Column
                                (
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:
                                    [
                                        // VIDEO TITLE
                                        Padding
                                        (
                                            padding: EdgeInsets.only(left:10, top: 10),
                                            child: Text
                                            (
                                                item["title"].toString() == "null" ? item["movie_title"].toString() : item["title"].toString(),
                                                style: TextStyle
                                                (
                                                    color: Colors.white,
                                                    fontSize: 20,
													fontWeight: FontWeight.w300
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.fade,
                                            ),
                                        ),
                                        // RATING
                                        SizedBox(height: 2),
                                        ratingInfo(context),
                                        Padding
                                        (
                                            padding: EdgeInsets.only(left: 10),
                                            child: ratingIcons()
                                        ),

                                    ],
                                )
                            ]
                        )
                    )
                )
			],
		);
    }

    Widget itemPoster(context)
    {
        var imageWidth = MediaQuery.of(context).size.width / 3;
        var imageHeight = MediaQuery.of(context).size.height / 4;

        return Container
        (
            width: imageWidth,
            height: imageHeight,
			child: FadeInImage(image: NetworkImage(item["poster"].toString()), placeholder: AssetImage("assets/images/2.jpeg"),fit:  BoxFit.contain,)
            // child:  Image.network(item["thumbnail"], fit: BoxFit.cover,)
        );
    }

    Widget ratingInfo(context)
    {
        return Container
        (
            padding: EdgeInsets.only(left:10),
            // color: Colors.blue[200],
            child: Row
            (
                children:
                [
                    // RATING AND HOW MUCH RATED
                    Column
                    (
                        children:
                        [
                            Text
                            (
                                "Rating",
                                style: TextStyle
                                (
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white
                                ),
                            ),
                            SizedBox(height: 5),
                            Text
							(
								item["ratings"] == "" ? "0" : item["ratings"].toString(),
								style: TextStyle(color: Colors.pink[300], fontSize:20),
							),
                            SizedBox(height: 5),
                        ],
                    ),
                    SizedBox(width:60),
                    Column
                    (
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                        [
                            Text
                            (
                                "Watch for",
                                style: TextStyle
                                (
                                    color: Colors.white
                                ),
                            ),
                            SizedBox(height: 10),
                            Text
                            (
                                item["amount"] != "0" ? "INR " + item["amount"].toString() : "Free",
                                style: TextStyle
                                (
                                    color: Colors.yellowAccent
                                ),
                            ),
                        ],
                    )
                ],
            ),
        );
    }

	ratingIcons()
	{
		// item["ratings"] = rating
		double rate = double.parse(item["ratings"]);
		// double rate = rating.toDouble();

		// print(item["ratings"].runtimeType);

		// print(rate.runtimeType);
		return SmoothStarRating
		(

			rating: rate,
			size: 20,
			color: Colors.greenAccent,
			filledIconData: Icons.star,
			halfFilledIconData: Icons.star_half,
			defaultIconData: Icons.star_border,
			starCount: 5,
			allowHalfRating: false,
			spacing: 3.0,
			// onRated: (value)
			// {
			// 	setState(()
			// 	{
			// 		// rate = value;
			// 	});
			// },
		);
	}

    Widget description()
    {
        return Column
        (
            children:
            [
                Padding
                (
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text
                    (
                        iconExpanded == true ? item["description"] : temp.length < 100 ? item["description"] : temp.substring(0, 100),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                ),
                IconButton
                (
                    icon: iconExpanded ? _iconUp : _iconDown,
                    color: Colors.white,
                    onPressed: ()
                    {
                        setState(()
                        {
                        	iconExpanded = !iconExpanded;
                        });
                    }
                )
            ],
        );
    }

    Widget iconButtons()
    {
        return Row
        (
            children:
            [
                Expanded
                (
                    child:  Column
                    (
                        children:
                        [
                            IconButton
                            (
                                icon: Icon(added == true ? Icons.done : Icons.add),
                                color: Colors.white,
                                onPressed: ()
                                {
									setState(()
									{
										!added ? addToWishList() : deleteFromWishList();
										added = !added;
									});
                                },

                            ),
                            Text(added == true ? "Added" : "My List",
                            style: TextStyle
                            (
                                color: Colors.white,
                                fontSize: 15
                            ))
                        ],
                    ),
                ),
				Expanded
                (
                    child: ContentRating(item, this.updateRating),
                ),
                Expanded
                (
                    child:  Column
                    (
                        children:
                        [
                            IconButton
                            (
                                icon: Icon(Icons.share),
                                color: Colors.white,
                                onPressed: ()
                                {
                                    Share.share("hello");
                                },

                            ),
                            Text("Share",
                            style: TextStyle
                            (
                                color: Colors.white,
                                fontSize: 15
                            ))
                        ],
                    ),
                ),
            ],
        );
    }

	
	updateRating(rating)
	{
		setState(()
		{
		  	item["ratings"] = rating.toString();
			ratingIcons();
		});
	}

	// overall rating of the item, every time user rates the content, this api is called to display the rating.
	globalRating() async
	{
		var contentId = item["id"];
		var contentType;

		switch(item["type"])
		{
			case "movie": contentType = "1"; break;
			case "music": contentType = "2"; break;
			case "short_film": contentType = "3"; break;
			case "webseries": contentType = "4"; break;
		}

		var temp = await Server.overallRating(contentId, contentType);

		var result = json.decode(temp);

		// print(result);

		if(result["response"] == "success")
		{
			setState(() 
			{
				item["ratings"] = result["data"].toString();
			});
		}
		else
		{
			setState(() 
			{
				var rating = 0;
			});
		}
	}


	// check if payment was done already.
	checkPaymentStatus() async
	{
		var contentType;
		var contentId = item["id"];

		if(item["amount"] != "0")
		{
			switch(item["type"])
			{
				case "movie": contentType = "1"; break;
				case "music": contentType = "2"; break;
				case "short_film": contentType = "3"; break;
				case "webseries": contentType = "4"; break;
			}

			// // print(contentType.toString() + "CONTENT TYPE");
			// // print(contentId.toString() + "CONTENT ID");

			var response = await Server.checkPaymentStatus(contentType, contentId);

			var result = json.decode(response);

			// // print(result);

			if(result["payment_status"] == 1)
			{
				setState(()
				{
					paymentStatus = true;
				});
			}
			else
			{
				setState(()
				{
					paymentStatus = false;
				});
			}
		}
		else
		{
			// // print("yes");
			setState(()
			{
				paymentStatus = true;
			});
		}
	}

	// api to add to wishlist.
	addToWishList() async
	{
		var contentType;
		var contentId = item["id"];

		switch(item["type"])
		{
			case "movie": contentType = "1"; break;
			case "music": contentType = "2"; break;
			case "short_film": contentType = "3"; break;
			case "webseries": contentType = "4"; break;
		}

		var response = await Server.addToWishlist(contentType, contentId);

		var result = json.decode(response);

		// // print(result);

		if(result["response"] == "success")
		{
			setState(()
			{
				added = true;
			});
		}
		else if(result["message"] == "Video Already in Wishlist")
		{
			setState(()
			{
				added = true;
			});
		}
		else
		{
			setState(()
			{
				added = false;
			});
		}
	}

	// api to remove from wishlist.
	deleteFromWishList() async
	{
		var listId = item["listId"];

		var response = await Server.deleteWishlist(listId);

		var temp = json.decode(response);

		// // print(temp);

		if(temp["message"] == "success")
		{
			setState(()
			{
				added = false;
				// // print(added);
			});
		}
		else
		{
			setState(()
			{
				added = false;
			});
		}
	}

	// api to check if item already added to wishlist.
	checkAddedToWishlist() async
	{
		var contentType;
		var contentId = item["id"];

		switch(item["type"])
		{
			case "movie": contentType = "1";
				break;
			case "music": contentType = "2";
				break;
			case "short_film": contentType = "3";
				break;
			case "webseries": contentType = "4";
				break;
		}

		var response = await Server.wishlistIsPresent(contentType, contentId);

		var result = json.decode(response);

		// print(result);


		if(result["response"] == "failed")
		{
			setState(()
			{
				added = false;
			});
		}
		else
		{
			setState(()
			{
				added = true;
			});
		}
	}

	// display wishlist data.
	displayWishlist() async
	{
		List tempList  = [];

		allDataList.clear();

		allDataList.addAll(movies);
		allDataList.addAll(music);
		allDataList.addAll(shortFilms);

		var temp = await Server.displayWishlist();

		var result = json.decode(temp);

		// // print(result["data"].length.toString() + "LENGTH");

		for (int i = 0; i < allDataList.length; i++)
		{
			for (int j = 0; j < result["data"].length; j++)
			{
				if(allDataList[i]['id'].contains(result["data"][j]["video_id"]) && allDataList[i]['type'].contains(result["data"][j]["video_details"][0]["type"]))
				{
					tempList.add(allDataList[i]);
				}
			}
		}


		setState(()
		{
			wishList = tempList;
		});

		for(int i = 0; i < result["data"].length; i++)
		{
			wishList[i]["listId"] = result["data"][i]["id"];
		}

		// // print("WISHLIST");
		// // print(wishList[1]);
	}
	
}