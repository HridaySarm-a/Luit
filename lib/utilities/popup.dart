import 'package:flutter/material.dart';

void popup(BuildContext context)
{
	AlertDialog alert = AlertDialog
	(
		backgroundColor: Colors.transparent,
		content: Column
		(
        	mainAxisAlignment: MainAxisAlignment.center,
        	mainAxisSize: MainAxisSize.min,
        	children: <Widget>
			[
          		SizedBox
				(
					width: 60,
					height: 60,
					child: CircularProgressIndicator
					(
						backgroundColor: Color(int.parse("0xff02071a")),
						valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
					),
          		),
        	],
      	),
	);

	showDialog
	(
		context: context,
		barrierDismissible: false,
		builder: (BuildContext context)
		{
			return alert;
		}
	);
}
