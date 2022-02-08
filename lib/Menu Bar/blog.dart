import 'package:flutter/material.dart';

class Blog extends StatelessWidget
{
	@override
	Widget build(BuildContext context) 
	{
		return Scaffold
		(
			backgroundColor: Color(int.parse("0xff02071a")),
			appBar: appBar(),
			body: Container
			(
				child: Padding
				(
					padding: EdgeInsets.fromLTRB(30, 34, 30, 10),
					// child: Text
					// (
					// 	""
					// 	style: TextStyle
					// 	(
					// 		fontSize: 15,
					// 	),
					// 	textAlign: TextAlign.justify,
					// ),
				)
			)
		);
	}

	Widget appBar()
	{
    	return AppBar
		(
      		title: Text("Blog", style: TextStyle(fontSize: 16.0),),
      		centerTitle: true,
      		backgroundColor:Colors.black,
    	);
  	}
}