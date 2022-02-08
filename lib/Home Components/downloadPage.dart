import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/bottomNavigationBar.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/downloadVideoPlayer.dart';
import 'package:luit/global.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';
import 'dart:async';

class DownloadPage extends StatefulWidget
{

    @override
    _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with SingleTickerProviderStateMixin
{
    AnimationController _controller;
	TargetPlatform platform;

	var localVideos;
	String _localPath;

	List downloadedVideos = [];
	

    @override
    void initState()
    {
		print("giiii");
        super.initState();
		getLocalVideos();
		findStoroageLocation();
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
            appBar: appBar(context),
            body: downloadedVideos.length == 0 ?
			 blankContainer()
			 : downloadedContents(),
			bottomNavigationBar: BottomNavBar(pageInd: 3,),
        );
    }

    // APPBAR
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
                "Downloaded Videos"
            ),
        );
    }

    Widget blankContainer()
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
      		child: Icon(Icons.download_rounded, size: 150.0, color: Color.fromRGBO(70, 70, 70, 1.0),),
    	);
  	}

	Widget message()
	{
		return  Padding
		(
			padding: EdgeInsets.only(left: 50.0, right: 50.0),
			child: Text
			(
				"You don't have any downloads.",
				style: TextStyle(height: 1.5,color: Colors.white70),
			),
		);
	}

	Widget downloadedContents()
	{
		return ListView.builder
		(
			padding: EdgeInsets.only(top:10, left: 5, right: 8, bottom: 10),
			itemCount: downloadedVideos.length,
			itemBuilder: (BuildContext context, int index)
			{
				return GestureDetector
				(
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
												downloadedVideos[index]["image"].toString(),
												fit: BoxFit.cover,
												errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
												{
													return Image.asset("assets/images/logo.png");
												}
											)
										)
									),
									SizedBox(width: 10),
									details(index),
									Expanded(child: playAndDeleteButton(context, index))
								],
							)
						),
					),
					onTap: ()
					{
						var fileNamenew = downloadedVideos[index]["url"].split("/").last;

						var router = new MaterialPageRoute
						(
							builder: (BuildContext context) => DownloadedVideoPlayer
							(
								taskId: "",
								name: fileNamenew,
								fileName: fileNamenew,
								downloadStatus: 0,
								localPath :_localPath,
							)
						);

						Navigator.of(context).push(router);
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
					padding: EdgeInsets.only(top: 10, left: 15),
					child: Text(downloadedVideos[index]["title"].toString(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1.5),),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 10, left: 15),
					child: Text("Type: " + downloadedVideos[index]["type"], style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1.5),),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 10, left: 15),
					child: Text
					(
						"Duration: " + downloadedVideos[index]["duration"] + " mins",
						style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1.5),
					),
				)
			]
		);
	}

	Widget playAndDeleteButton(context, int index)
	{
		return Column
		(
			crossAxisAlignment: CrossAxisAlignment.end,
			children: 
			[
				IconButton
				(
					icon: Icon(Icons.play_arrow, color: Colors.blue, size: 30,),
					onPressed: () async
					{
						var fileNamenew = downloadedVideos[index]["url"].split("/").last;

						var router = new MaterialPageRoute
						(
							builder: (BuildContext context) => DownloadedVideoPlayer
							(
								taskId: "",
								name: fileNamenew,
								fileName: fileNamenew,
								downloadStatus: 0,
								localPath :_localPath,
							)
						);

						Navigator.of(context).push(router);
					},
				),
				IconButton
				(
					icon: Icon(Icons.delete, color: Colors.deepOrangeAccent, size: 30,),
					onPressed: () async
					{
						deleteConfirmation(context, index);
						// downloadedVideos.removeAt(index);

						// await prefs.setString("downloadedVideos", json.encode(downloadedVideos));

						// setState(() {});
					},
				),
			],
		);
	}


	void deleteConfirmation(context, index)
	{
		showDialog(
			context: context,
			builder: (BuildContext context)
			{
				return AlertDialog
				(
					backgroundColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
					title: new Text
					(
						"Delete Download?",
						style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
					),
					content: new Text
					(
						"Delete the content from downloads",
						style: TextStyle
						(
						color: Colors.black.withOpacity(0.7),
						fontWeight: FontWeight.w600,
						fontSize: 16.0
						),
					),
					actions: <Widget>
					[
						new FlatButton
						(
							child: new Text
							(
								"Delete ",
								style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
							),
							onPressed: () async
							{
								downloadedVideos.removeAt(index);

								await prefs.setString("downloadedVideos", json.encode(downloadedVideos));

								setState(() {});
								Navigator.pop(context);
							},
						),
						new FlatButton
						(
							child: new Text
							(
								"Cancel",
								style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
							),
							onPressed: ()
							{
								Navigator.of(context).pop();
							},
						),
					],
				);
			},
		);
	}


	Future<String> _findLocalPath() async
	{
		final directory = await getApplicationSupportDirectory();
		return directory.path;
	}

	findStoroageLocation() async
	{
		_localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
	}

	getLocalVideos()
	{
		print("local videos");
		if (prefs.containsKey("downloadedVideos"))
		{
			localVideos = json.decode(prefs.getString("downloadedVideos"));

			print(localVideos.length);
			if(localVideos.length != null)
			{
				for(int i = 0; i < localVideos.length; i++)
				{
					downloadedVideos.add(localVideos[i]);
				}

			}
			print(downloadedVideos);
		}
	}
}