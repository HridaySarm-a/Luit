import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';

class ViewAll extends StatefulWidget
{
	final List items;
	ViewAll(this.items);
    @override
    _ViewAllState createState() => _ViewAllState(this.items);
}

class _ViewAllState extends State<ViewAll> with SingleTickerProviderStateMixin
{
	final List items;
	_ViewAllState(this.items);
    AnimationController _controller;
	var title;
	var temp;

	bool isActors = false;
	bool isLanguage = false;

    @override
    void initState()
    {
		temp = items;
        super.initState();
		setTitle();
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
            appBar: appBar(),
            backgroundColor: Color(int.parse("0xff02071a")),
			body: gridView(items, context),
        );
    }

    Widget appBar()
	{
    	return AppBar
		(
      		title: Text(title.toString(), style: TextStyle(fontSize: 16.0),),
      		centerTitle: true,
      		backgroundColor: Colors.black,
    	);
  	}

	Widget gridView(List temp, context)
	{
		// print(temp[0]);
		return Container
		(
			padding: EdgeInsets.all(20),
			child: GridView.count
			(
				crossAxisCount: 3,
				mainAxisSpacing: 8,
				crossAxisSpacing: 9,
				childAspectRatio: 0.8,
				children: List.generate(temp.length, (index)
				{
					return InkWell
					(
						child:
						//  items[index]["type"] == "movie"	 || items[index]["status"] == "1" ?
						Container
						(
							color: Colors.white.withOpacity(0.1),
							child: ClipRRect
							(
								borderRadius: BorderRadius.circular(8.0),
								child: InkWell
								(
									child:  Stack
									(
										children:
										[
											// FadeInImage.assetNetwork
											Image.network
											(
												// placeholder: "assets/images/logo.png",
												isLanguage ? temp[index]["thumbnail_link"] : temp[index]["thumbnail"].toString() == "null" ? temp[index]["actor_image"].toString() : temp[index]["thumbnail"].toString(),
												fit: BoxFit.cover,
												errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
												{
													return Image.asset("assets/images/logo.png", height: 200,);
												},
												height: 200,
												width: 200.0,
												// imageScale: 1.0,

											),
											items[index]["amount"] != "0" ?
											Container
											(
												padding: EdgeInsets.only(top: 2, left: 2),
												height: 25,
												width: 25,
												child: Image.asset(isActors == true || isLanguage == true ? "" : "assets/images/premium.png")
											)
											: SizedBox.shrink()
										],
									),
									onTap: ()
									{
										if(title == "Actors")
										{
											// print(temp[0]["data"]);
											Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAll(temp[index]["data"])));
										}
										else if(title == "Movie By Languages")
										{
											// print(temp[0]["data"]);
											Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAll(temp[index]["data"])));
										}
										else
										{
											// print(temp[index]);
											// print("Not found");
											Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetails(temp[index])));
										}
									},
								),
							)
						)
					);
				}),
			)
		);
	}

	setTitle()
	{
		// print(items);
		if(items[0]["type"] == "movie")
		{
			title = "Movies";
		}
		else if(items[0]["type"] == "series")
		{
			title = "Series";
		}
		else if(items[0]["type"] == "short_film")
		{
			title = "Short Films";
		}
		else if(items[0]["type"] == "music")
		{
			title = "Music";
		}
		else if(items[0]["actor_id"] != null)
		{
			title = "Actors";
			setState(() 
			{
				isActors = true;
			});
		}
		else if(items[0]["lang_id"] != null)
		{
			title = "Movie By Languages";
			setState(()
			{
				isLanguage = true;
			});
		}
		else
		{
			title = "Movies";
		}
		// print("TITLE " + title);
	}
}