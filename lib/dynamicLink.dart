import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/global.dart';

class DynamicLinkService
{
	Home homeInstance;
	Future handleDynamicLinks() async
	{
		// 1. Get the initial dynamic link if the app is opened with a dynamic link
		final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();

		// 2. handle link that has been retrieved
		_handleDeepLink(data);

		// 3. Register a link callback to fire if the app is opened up from the background
		// using a dynamic link.
		FirebaseDynamicLinks.instance.onLink
		(
			onSuccess: (PendingDynamicLinkData dynamicLink) async
			{
				// 3a. handle link that has been retrieved
				_handleDeepLink(dynamicLink);
			},
			onError: (OnLinkErrorException e) async
			{
				print('Link Failed: ${e.message}');
			}
		);
	}

	void _handleDeepLink(PendingDynamicLinkData data)
	{
		BuildContext context;

		final Uri deepLink = data?.link;

		if (deepLink != null)
		{
			if (deepLink.queryParameters["videoId"] != "")
			{
				dynamicLinkVideoId = int.parse(deepLink.queryParameters["videoId"]);
				dynamicLinkVideoType = deepLink.queryParameters["type"].toString();

				for(int i = 0; i < allVideos.length; i++)
				{
					if(allVideos[i]["id"].toString() == dynamicLinkVideoId.toString() && allVideos[i]["type"].toString() == dynamicLinkVideoType.toString())
					{
						print("yes");
						Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetails(allVideos[i])));
					}
				}
				deepLink.queryParameters["videoId"] = "";
			}
		}
	}

	Future<String> createDynamicLink(String videoId, String videoType, String title, String description, String imageUrl) async
	{
		final DynamicLinkParameters parameters = DynamicLinkParameters
		(
			uriPrefix: 'https://luitvideo.page.link',
			link: Uri.parse('http://release.luit.co.in/video?videoId=' + videoId.toString() + '&type=' + videoType),
			androidParameters: AndroidParameters(packageName: 'com.luit'),
			socialMetaTagParameters: SocialMetaTagParameters
			(
				title: "Watch " +  title + " on Luit",
				description: description,
				imageUrl: Uri.parse(imageUrl)
			)
		);

		final Uri dynamicUrl = await parameters.buildUrl();

		final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();

		final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl
		(
			Uri.parse(dynamicUrl.toString()),
			DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
		);

		final Uri shortUrl = shortDynamicLink.shortUrl;

		return shortenedLink.shortUrl.toString();
	}
}