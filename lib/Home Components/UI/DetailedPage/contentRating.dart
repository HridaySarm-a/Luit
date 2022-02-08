import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ContentRating extends StatefulWidget
{
	ContentRating(this.item, this.updateRating);

	final item;
	final updateRating;

    @override
    _ContentRatingState createState() => _ContentRatingState(this.item, this.updateRating);
}

class _ContentRatingState extends State<ContentRating> with SingleTickerProviderStateMixin
{

	_ContentRatingState(this.item, this.updateRating);
	final item;
	final updateRating;

    AnimationController _controller;
	var rating = 0.0;

	bool rated = false;

    @override
    void initState()
    {
        super.initState();
		// globalRating();
		checkIfRated();
        _controller = AnimationController(vsync: this);
    }

    @override
    void dispose()
    {
        super.dispose();
        _controller.dispose();
    }

    Widget build(BuildContext context)
    {
        return Column
        (
            children:
            [
                IconButton
                (
                    icon: Icon(rated == false ? Icons.star_border_outlined : Icons.star_rounded),
                    color: Colors.white,
                    onPressed: ()
                    {
						rated == true ? Fluttertoast.showToast(msg: "Already Rated") : showRatingSheet(context);
                    },

                ),
                Text(rated == false ? "Rate" : "Rated",
                style: TextStyle
                (
                    color: Colors.white,
                    fontSize: 15
                ))
            ],
        );
    }

    void showRatingSheet(context)
    {

		showModalBottomSheet
		(
			context: context,
			builder: (builder)
			{
				return new Container
				(
					decoration: new BoxDecoration
					(
						color: Colors.blue,
						borderRadius: new BorderRadius.only
						(
							topLeft: const Radius.circular(10.0),
							topRight: const Radius.circular(10.0)
						)
					),
					height: 150.0,
					child: Container
					(
						height: 100,
						decoration: new BoxDecoration
						(
							color: Color(int.parse("0xff02071a")).withOpacity(0.9),
						),
						child: ratingVideosSheet()
					),
				);
			}
		);
  	}


    Widget ratingVideosSheet()
	{
		return Container
		(
			color: Color(int.parse("0xff02071a")),
			child: Column
			(
				children: <Widget>
				[
					SizedBox(height: 25,),
					Row
					(
						crossAxisAlignment: CrossAxisAlignment.start,
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>
						[
							SmoothStarRating
							(
								borderColor: Colors.blue,
								rating: rating,
								size: 40,
								color: Colors.greenAccent,
								filledIconData: Icons.star,
								halfFilledIconData: Icons.star_half,
								defaultIconData: Icons.star_border,
								starCount: 5,
								allowHalfRating: false,
								spacing: 3.0,
								onRated: (value) 
								{
									setState(() 
									{
										rating = value;
										print(rating.toString());
									});
								},
							),
						],
					),
					SizedBox(height: 15,),
					Container
					(
						height: 35.0,
						child: OutlineButton
						(
							// color: Color(int.parse("0xffcf2450")),
							child: Text
							(
								"Submit",
								style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 1.5),
							),
							onPressed: () async
							{
								print(rating.toString());
								if(rating < 1)
								{
									Navigator.pop(context);
									Fluttertoast.showToast
									(
										msg: "Please enter a valid rating.",
										fontSize: 15,
										backgroundColor: Colors.white,
										textColor: Colors.black
									);
								}
								else
								{
									submitRating();
									Navigator.pop(context);
								}
							}
						),
					),
				],
			),
		);
	}

	// api to check if the rating has been done already
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

		if(result["message"] == "No Rating")
		{
			setState(() 
			{
				this.updateRating(rating);
			});
		}
		else
		{
			setState(() 
			{
				// rated = true;
			});

			// Fluttertoast.showToast(msg: "Already Rated");
		}
	}

	submitRating() async
	{
		var contentId = item["id"];
		var contentType;
		var remarks = rating.toString();

		// // print(remarks.runtimeType);
		// // print(remarks);

		switch(item["type"])
		{
			case "movie": contentType = "1"; break;
			case "music": contentType = "2"; break;
			case "short_film": contentType = "3"; break;
			case "webseries": contentType = "4"; break;
		}

		var temp = await Server.rateContent(contentId, contentType, remarks);

		var result = json.decode(temp);

		// print(result);

		if(result["message"] == "Rating Addeed Successfully")
		{
				setState(()
				{
					rated = true;
				});
				// item["ratings"] = rating.toString();
				globalRating();
				// // print(item["ratings"]);
				// // print(item["ratings"].runtimeType);
		}
		else
		{
			setState(()
			{
				rated = false;
			});

			Fluttertoast.showToast(msg: "Already Rated");
		}
	}

	checkIfRated() async
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

		var response = await Server.checkIfVideoRated(contentId, contentType);

		var result  = json.decode(response);

		// print(result);

		if(result["response"] == "failed")
		{
			setState(() 
			{
				rated = false;
			});
		}
		else
		{
			setState(() 
			{
				rated = true;
			});
		}
	}
}