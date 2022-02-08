import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/global.dart';

class ContentPageTabBar extends StatefulWidget 
{
	ContentPageTabBar(this.item);
	final Map item;
    @override
    _ContentPageTabBarState createState() => _ContentPageTabBarState(this.item);
}

class _ContentPageTabBarState extends State<ContentPageTabBar> with SingleTickerProviderStateMixin 
{
	_ContentPageTabBarState(this.item);
	final Map item;

    AnimationController _controller;
    TabController _tabController;

	List  moreLikeThisList = [];
	List  matchGener = [];


    @override
    void initState() 
    {
		similarItems();
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
        return  DefaultTabController
        (
            length: 2, 
            child: Container
            (
                child: Column
                (
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
                                Padding
								(
									padding: EdgeInsets.only(bottom: 20),
									child: Text("MORE LIKE THIS", style: TextStyle(fontWeight: FontWeight.w400))
								),
                                Padding
								(
									padding: EdgeInsets.only(bottom: 20),
									child: Text("MORE DETAILS", style: TextStyle(fontWeight: FontWeight.w400))
								)
                            ],
                        ),
                        SizedBox(height: 10),
                        Padding
                        (
                            padding: const EdgeInsets.symmetric(vertical: 2.3),
                            child: Container
                            (
								height: 270,
                                width: MediaQuery.of(context).size.width - 2 * 1.2,
                                child: TabBarView
                                (
                                    controller: _tabController,
                                    children: <Widget>
                                    [
                                        moreLikeThis(),
                                        moreInfo()
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            )
        );
    }

    // MORE LIKE THIS
    Widget moreLikeThis()
    {
        return Container
        (
			height: 75,
            child:  ListView.builder
            (
				itemCount: moreLikeThisList.length,
				scrollDirection: Axis.horizontal,
				padding: const EdgeInsets.only(left: 16.0, top: 4.0),
				itemBuilder: (BuildContext context, int position)
				{
					return Padding
					(
						padding: const EdgeInsets.only(right: 12.0),
						child: InkWell
						(
							onTap: () {},
							child: Column
							(
								crossAxisAlignment: CrossAxisAlignment.center,
								children:
								[
									Container
									(
										child: Container
										(
											child: ClipRRect
											(
												borderRadius: BorderRadius.circular(10.0),
                                                child: InkWell
                                                (
													child: Stack
													(
														children:
														[  
															SizedBox
															(
																width: 100,
																height: 160,
																child:  Image.network
																(
																	moreLikeThisList[position]["thumbnail"].toString(),
																	fit: BoxFit.cover,
																	errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
																	{
																		return Image.asset("assets/images/logo.png");
																	}
																),
															),
															moreLikeThisList[position]["amount"] != "0" ?
															Container
															(
																padding: EdgeInsets.only(top: 2, left: 2),
																height: 25,
																width: 25,
																child: Image.asset("assets/images/premium.png")
															)
															: SizedBox.shrink()
														]
													),
                                                    onTap: ()
                                                    {
						                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContentDetails(moreLikeThisList[position])));
                                                    },
                                                ),
											),
										),
									),
								],
							),
						),
					);
				}
			)
        );
    }

    // MORE DETAILS
    Widget moreInfo()
    {
        return SingleChildScrollView
        (
			child: Padding
			(
				padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
				child: new Column
				(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>
					[
						Container(height: 8.0,),
						name(),
						Divider(color: Colors.white,),
						genre(),
						Divider(color: Colors.white,),
						details(),
						Divider(color: Colors.white,),
						directors(),
						Divider(color: Colors.white,),
						item["type"] == "music" && item["choreographer"].length != 0 ? choregrapher(): SizedBox.shrink(),
						item["type"] == "music" && item["choreographer"].length != 0 ? Divider(color: Colors.white,): SizedBox.shrink(),
						item["type"] == "music" && item["musicDirectors"].length != 0 ? musicDirectors(): SizedBox.shrink(),
						item["type"] == "music" && item["musicDirectors"].length != 0 ? Divider(color: Colors.white,): SizedBox.shrink(),
						item["type"] == "music" && item["singers"].length != 0 ? singer(): SizedBox.shrink(),
						item["type"] == "music" && item["singers"].length != 0 ? Divider(color: Colors.white,): SizedBox.shrink(),
						audioLanguage(),
						Divider(color: Colors.white,),
						rating(),
						Divider(color: Colors.white,),
						maturityRating(),
						Divider(color: Colors.white,),

					],
				),
			),
        );
    }

    Widget name()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 0.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Name',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["title"].toString(),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
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
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					// Expanded
					// (
					// 	flex: 2,
					// 	child: 
						Text
						(
							'Genres',
							style: TextStyle(color: Colors.white, fontSize: 13.0),
						),
					SizedBox(height: 10,),
					// ),
					// Expanded
					// (
					// 	flex: 5,
					// 	child: GestureDetector
					// 	(
					// 		onTap: () {},
							// child:
							 Text
							(
								item["genre"].join(","),
								// "",
								style: TextStyle(color: Colors.grey, fontSize: 13.0),
							),
				// 		),
				// 	),
				],
			)
		);
	}

	// singer
	Widget singer()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 0.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Singers',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["singers"].join(","),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
					),
				],
			)
		);
	}

	// choregrapher
	Widget choregrapher()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 0.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Choreographers',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["choreographer"].join(","),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
					),
				],
			)
		);
	}

	// music directors
	Widget musicDirectors()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 0.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Music Directors',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["musicDirectors"].join(","),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
					),
				],
			)
		);
	}


	Widget directors()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Directors',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["directors"].join(","),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
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
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Actors',
						style: TextStyle(color: Colors.white, fontSize: 13.0),
					),
					SizedBox(height: 10,),
					Text
					(
						item["actors"].join(","),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
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
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Audio Language',
						style: TextStyle(color: Colors.white, fontSize: 13.0),
					),
					SizedBox(height: 10,),
					Text
					(
						item["audio_languages"].join(","),
						style: TextStyle
						(
							color: Colors.grey, fontSize: 13.0
						),
					),
				],
			)
		);
	}

	Widget rating()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Rating',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["ratings"].toString(),
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
					),
				],
			)
		);
	}

	Widget maturityRating()
	{
		return Padding
		(
			padding: const EdgeInsets.symmetric(vertical: 2.0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>
				[
					Text
					(
						'Maturity Rating',
						style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)
					),
					SizedBox(height: 10,),
					Text
					(
						item["maturity_rating"].toString() + "+",
						style: TextStyle(color: Colors.grey, fontSize: 13.0),
					),
				],
			)
		);
	}

	// genre match
	similarItems()
	{
		print("similar  tiesmss");
		List videos = [];

		switch(item["type"])
		{
			case "movie": videos = movies; break;
			case "series": videos = movies; break;
			case "music": videos = music; break;
			case "short_film": videos = shortFilms; break;
		}

		for(int i = 0; i < videos.length; i++)
		{
			if (videos[i]["id"] == item["id"])
			{
				continue;
			}

			for (int j = 0; j < item["genre"].length; j++)
			{
				var genre = item["genre"][j];

				if(videos[i]["genre"].contains(genre))
				{
					moreLikeThisList.add(videos[i]);
					break;
				}
			}
		}

		print("similar  tiesmss");
		print(moreLikeThisList.length);
	}
}