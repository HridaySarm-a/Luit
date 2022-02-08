import 'dart:io';

import 'package:flutter/material.dart';
import 'package:luit/global.dart';
import 'package:luit/utilities/popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;


class SharePage extends StatelessWidget
{
	SharePage(this.item);
	final item;

	Widget build(BuildContext context)
	{
		return Column
		(
			children:
			[
				IconButton
				(
					icon: Icon(Icons.share),
					color: Colors.white,
					onPressed: ()
					{
						popup(context);
						dynamicLinkService.createDynamicLink((item["id"].toString()), item["type"], item["title"], item["description"], item["poster"]).then
						((newDynamicLink)
						async {
							// print(newDynamicLink + " Dynamic Link");

							final uri = Uri.parse(item["poster"]);
							final res = await http.get(uri);
							final bytes = res.bodyBytes;

							final temp = await getTemporaryDirectory();
							final path = '${temp.path}/image.jpg';
							File(path).writeAsBytesSync(bytes);

							await Share.shareFiles(
								[path],
								text: "Watch " +
										item["title"] +
										"\n" +
										newDynamicLink,

							);
							Navigator.pop(context);
						});
					},

				),
				Text("Share",
				style: TextStyle
				(
					color: Colors.white,
					fontSize: 15
				))
			],
		);
	}
}



