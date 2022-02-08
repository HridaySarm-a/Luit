import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/Home%20Components/bottomNavigationBar.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/global.dart';

class SearchPage extends StatefulWidget
{
	@override
  	State<StatefulWidget> createState() 
	{
		return SearchPageState();
  	}
}

class SearchPageState extends State<SearchPage>
{

	TextEditingController searchController = TextEditingController();
	List newDataList =[];
	List tempList = [];
	List allVideosList = [];

	bool search = false;

	@override
	void initState()
	{
		super.initState();
		print(allVideos.length);
	}

	Widget build(BuildContext context)
	{
		return Scaffold
		(
			backgroundColor: Color(int.parse("0xff02071a")),
			appBar: AppBar
			(
				backgroundColor: Colors.black,
				leading: IconButton
				(
					icon: Icon(Icons.arrow_back),
					onPressed: ()
					{
						Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
					},
				),
				title: searchBar(),
			),
			body: !search ? blankDisplay() : searchFilters(),
			bottomNavigationBar: BottomNavBar(pageInd: 1,),
    	);
	}

	Widget searchBar()
	{
		return TextField
		(
			controller: searchController,
        	decoration: InputDecoration
			(
				fillColor: Colors.white.withOpacity(0.13),
				filled: true,
				suffixIcon: Icon(Icons.search, color: Colors.white54,),
				hintText: 'Search for movies, series, music...',
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
				contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10)
        	),
			onChanged: onItemChanged
      	);
	}

	Widget blankDisplay()
	{
		return Padding
		(
			padding: EdgeInsets.fromLTRB(15, 10, 10, 0),
			child: Column
			(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: 
				[
					Text
					(
						"Find what to watch next",
						style: TextStyle
						(
							fontWeight: FontWeight.w700,
							fontSize: 18,
							color: Colors.white54
						),
					),
					SizedBox(height: 20),
					Text
					(
						"Search for your favourite shows and enjoy the moment...",
						style: TextStyle
						(
							fontWeight: FontWeight.w400,
							color: Colors.white54
						),
					),
				],
			)
		);
	}

	Widget searchFilters()
	{
		return ListView.builder
		(
			padding: EdgeInsets.only(top:10, left: 5, right: 5, bottom: 10),
			itemCount: newDataList.length,
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
												newDataList[index]["poster"].toString(),
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
					onTap: ()
					{
						// print(newDataList[index]);
						Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetails(newDataList[index])));
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
					child: Text(newDataList[index]["title"].toString().length > 10 ? newDataList[index]["title"].toString().substring(0, 10) :  newDataList[index]["title"].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text(newDataList[index]["genre"].join(",") + " Videos", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, letterSpacing: 1.5)),
				),
				Padding
				(
					padding: EdgeInsets.only(top: 15, left: 15),
					child: Text
					(
						newDataList[index]["amount"] == "0" ? "Free" : "INR " + newDataList[index]["amount"],
						style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1,)
					),
				)
			]
		);
	}


	onItemChanged(String value)
	{
		newDataList.clear();

		search = true;

		for (int i = 0; i < allVideos.length; i++)
		{
			String searchText = movies[i]["title"] + " " + movies[i]["description"] + " " + movies[i]["meta_description"] + " " + movies[i]["meta_keyword"] + " " + movies[i]["directors"] + " " + movies[i]["singer"] + " " + movies[i]["music_director"];
			//String searchText = allVideos[i]["title"];

			if (searchText.toLowerCase().contains(searchController.text.toLowerCase()))
			{

				tempList.add(allVideos[i]);
			}
		}

		setState(()
		{
			newDataList = tempList;
		});
  	}
}

