import 'package:flutter/material.dart';

class SeriesContentPageTabBar extends StatefulWidget
{
	SeriesContentPageTabBar(this.item, this.paymentStatus);
	final Map item;
	final bool paymentStatus;

    @override
    _SeriesContentPageTabBarState createState() => _SeriesContentPageTabBarState(this.item, this.paymentStatus);
}

class _SeriesContentPageTabBarState extends State<SeriesContentPageTabBar> with SingleTickerProviderStateMixin
{
	_SeriesContentPageTabBarState(this.item, this.paymentStatus);
	final Map item;
	final bool paymentStatus;

    AnimationController _controller;
    TabController _tabController;
	Map episodes = {};
	List seasonEpisodes = [];

	String selectedSeasonButton;


    @override
    void initState()
    {
		// print(paymentStatus);
		addEpisodes();
		seasonWidget();
        super.initState();
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
        return   Container
		(
			child: Column
			(
				children:
				[
					seasonWidget(),
					SizedBox(height: 20),
					DefaultTabController
					(
						length: 2,
						child: Container
						(
							child: Column
							(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>
								[
									TabBar
									(
										controller: _tabController,
										unselectedLabelColor: Colors.white70,
										indicatorSize: TabBarIndicatorSize.tab,
										labelColor: Colors.white,
										indicator: BoxDecoration
										(
											color: Colors.transparent,
											border: Border(bottom: BorderSide(color: Colors.blue[200], width: 2)),
										),
										tabs:
										[
											Container(child: Text("EPISODES", style: TextStyle(fontWeight: FontWeight.w400)),padding: EdgeInsets.only(bottom: 20)),
											Container(child: Text("MORE DETAILS", style: TextStyle(fontWeight: FontWeight.w400)),padding: EdgeInsets.only(bottom: 20)),
										],
									),
									SizedBox(height: 10),
									Padding
									(
										padding: const EdgeInsets.symmetric(vertical: 2.3),
										child: Container
										(
											padding: EdgeInsets.only(left: 2, right: 2),
											height: 270,
											width: MediaQuery.of(context).size.width - 2 * 1.2,
											child: TabBarView
											(
												controller: _tabController,
												children: <Widget>
												[
													// episodeDisplay(),
													wishListItems(),
													moreInfo()
												]
											)
										)
									)
								]
							)
						)
					)
				]
			)
		);
    }

	seasonWidget()
	{
		List<Container> buttons = [];

		for (int i = 0; i < item["array_season"].length; i++)
		{
			buttons.add(Container
			(
				margin: EdgeInsets.all(5),
				child: FlatButton
				(
					padding: EdgeInsets.all(10),
					child: Text("Season " + (i + 1).toString()),
					color: item["array_season"][i]["season_no"] == selectedSeasonButton ? Colors.green : Colors.grey,
					onPressed: ()
					{
						setState(()
						{
							selectedSeasonButton = item["array_season"][i]["season_no"];
							seasonEpisodes = episodes[item["array_season"][i]["season_no"]];
						});
					},
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))
				)
			));
		}

		return Container
		(
			height: 50,
			child: ListView
			(
				scrollDirection: Axis.horizontal,
				children: buttons
			)
		);
	}

	Widget wishListItems()
	{
		return ListView.builder
		(
			padding: EdgeInsets.only(top:10, left: 5, right: 5, bottom: 10),
			itemCount: seasonEpisodes.length,
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
												child: FadeInImage
												(
													image: NetworkImage(seasonEpisodes[index]["thumbnail"]),
													placeholder: AssetImage("assets/images/logo.png"),
													fit: BoxFit.cover,
												)
											)
										),
										SizedBox(width: 10),
										seasonDetails(index)
									],
								)
							),
						),
					onTap: ()
					{
						seasonEpisodes[index]["video_url"] = seasonEpisodes[index]["upload_video"];
						seasonEpisodes[index]["title"] = seasonEpisodes[index]["episode_title"];
						// print(seasonEpisodes[index]);
						// Navigator.push(context, MaterialPageRoute(builder: (context) => CustomVideoPlayer(seasonEpisodes[index])));
					},
				);
			}
		);
	}

	Widget seasonDetails(index)
	{
		return Column
		(
			crossAxisAlignment: CrossAxisAlignment.start,
			children:
			[
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text(seasonEpisodes[index]["episode_title"].toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text("Directors: " + seasonEpisodes[index]["directors"][0].toString(), style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, letterSpacing: 1.5)),
				),
				// Padding
				// (
				// 	padding: EdgeInsets.only(top: 15, left: 15),
				// 	child: Text
				// 	(
				// 		seasonEpisodes[index]["amount"] == "0" ? "Free" : "INR " + seasonEpisodes[index]["amount"],
				// 		style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1,)
				// 	),
				// )
			]
		);
	}

    Widget episodeDisplay()
    {
        return Container
        (
            child:  ListView.builder
            (
				itemCount: seasonEpisodes.length,
				scrollDirection: Axis.vertical,
				padding: const EdgeInsets.only(left: 1.0, top: 1.0, bottom: 2.0),
				itemBuilder: (BuildContext context, int position)
				{
					return InkWell
					(
						onTap: () {},
						child: Container
						(
							color: Colors.red,
							padding: EdgeInsets.only(bottom: 0, left: 0),
							child: Card
							(
								child: ListTile
								(
									dense: true,
									contentPadding: EdgeInsets.all(0),
									tileColor: Colors.black26,
									leading:Stack
									(
										children:
										[
											SizedBox
											(
												height: 120,
												width: 100,
												child: Image.network(seasonEpisodes[position]["thumbnail"].toString() ,fit: BoxFit.fitHeight),
											)
										],
									),
									title: Text(seasonEpisodes[position]["episode_title"].toString()),
									subtitle: Text(seasonEpisodes[position]["description"].toString() + " Videos"),
									trailing: Icon
									(
										Icons.file_download,
										// color: Colors.lightBlueAccent,
									),
								)
							)
						)
					);
				}
			)
        );
    }

	// TITLE FOR LIST OF EPISODES
	Widget title()
	{
		return Column
		(
			crossAxisAlignment: CrossAxisAlignment.start,
			children:
			[
				Text(item["title"], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),),
				Text("hii"),
				Text("hii"),
				// Text("hii"),
			],
		);
	}

    // MORE DETAILS
    Widget moreInfo()
    {
        return Container
        (
            color: Color(int.parse("0xff02071a")),
			child: Padding
			(
				padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
				child: new Column
				(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>
					[
						Text
						(
							"About",
							style: TextStyle(color: Colors.white, fontSize: 16.0),
						),
						Container(height: 8.0,),
						name(),
						genre(),
						details(),
						audioLanguage()
					],
				),
			),
        );
    }

    Widget name()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Row
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Expanded
					(
						flex: 2,
						child: Text
						(
							'Name:',
							style: TextStyle(color: Colors.grey, fontSize: 13.0),
						),
					),
					Expanded
					(
						flex: 5,
						child: GestureDetector
						(
							onTap: () {},
							child: Text
							(
								item["title"].toString(),
								style: TextStyle(color: Colors.white, fontSize: 13.0),
							),
						),
					),
				],
			)
		);
	}

    Widget genre()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Row
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Expanded
					(
						flex: 2,
						child: Text
						(
							'Genres:',
							style: TextStyle(color: Colors.grey, fontSize: 13.0),
						),
					),
					Expanded
					(
						flex: 5,
						child: GestureDetector
						(
							onTap: () {},
							child: Text
							(
								"genres",
								style: TextStyle(color: Colors.white, fontSize: 13.0),
							),
						),
					),
				],
			)
		);
	}

    Widget details()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Row
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Expanded
					(
						flex: 2,
						child: Text
						(
							'Actors:',
							style: TextStyle(color: Colors.grey, fontSize: 13.0),
						),
					),
					Expanded
					(
						flex: 5,
						child: GestureDetector
						(
							onTap: () {},
							child: Text
							(
								item["actors"].toString(),
								style: TextStyle(color: Colors.white, fontSize: 13.0),
							),
						),
					),
				],
			)
		);
	}

    Widget audioLanguage()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Row
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Expanded
					(
						flex: 2,
						child: Text
						(
							'Audio Language:',
							style: TextStyle(color: Colors.grey, fontSize: 13.0),
						),
					),
					Expanded
					(
						flex: 5,
						child: GestureDetector
						(
							onTap: () {},
							child: Text
							(
								item["audio_languages"].toString(),
								style: TextStyle
								(
									color: Colors.white, fontSize: 13.0),
							),
						),
					),
				],
			)
		);
	}

	addEpisodes()
	{
		episodes.clear();

		for(int index = 0; index < item["array_season"].length; index++)
		{
			setState(() 
			{
				episodes[item["array_season"][index]["season_no"]] = item["array_season"][index]["episode_array"];
				selectedSeasonButton = item["array_season"][index]["season_no"];
				seasonEpisodes = episodes[item["array_season"][index]["season_no"]];
			});
		}
		
	}
}
