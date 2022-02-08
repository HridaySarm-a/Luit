import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_player.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_progress_colors.dart';
import 'package:flutter/material.dart';
import 'package:luit/global.dart';
import 'package:luit/utilities/coverter.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class MyCustomPlayer extends StatefulWidget
{
	MyCustomPlayer(this.item);

	final item;

	@override
	State<StatefulWidget> createState()
	{
		return _MyCustomPlayerState(this.item);
  	}
}

class _MyCustomPlayerState extends State<MyCustomPlayer> with WidgetsBindingObserver
{
	_MyCustomPlayerState(this.item);
	final item;

	TargetPlatform _platform;
	VideoPlayerController videoPlayerController;
	ChewieController _chewieController;
	DateTime currentBackPressTime;
	var playerTitle;
	Duration duration = Duration(seconds: 0);

	String link;
  	final
	SubtitleController subtitleController = SubtitleController();
	// SubtitleController subtitleController = SubtitleController
	// (
	// 	subtitleUrl: "https://pastebin.com/raw/ZWWAL7fK",
	// 	showSubtitles: false,
	// 	subtitleDecoder: SubtitleDecoder.utf8,
	// 	subtitleType: SubtitleType.webvtt,
  	// );



	void stopScreenLock() async
	{
		Wakelock.enable();
	}

	void enableScreenLock() async
	{
		Wakelock.disable();
	}

	//  Handle back press
	Future<bool> onWillPopS() async
	{
		item["resumeAt"] = _chewieController.videoPlayerController.value.position.toString();

		if(_chewieController.isPlaying)
		{
			_chewieController.pause();

			var playedVideo =
			{
				"type": item["type"],
				"id": item["id"],
				"resumeAt": _chewieController.videoPlayerController.value.position.toString()
			};

			var currentLastPlayed = [];

			if (prefs.containsKey("userLastPlayedVideos"))
			{
				currentLastPlayed = json.decode(prefs.getString("userLastPlayedVideos"));
			}

			currentLastPlayed = updateVideoWatchHistory(currentLastPlayed, playedVideo);
			await prefs.setString("userLastPlayedVideos", json.encode(currentLastPlayed));
		}
		else
		{
			var playedVideo =
			{
				"type": item["type"],
				"id": item["id"],
				"resumeAt": _chewieController.videoPlayerController.value.position.toString()
			};

			var currentLastPlayed = [];

			if (prefs.containsKey("userLastPlayedVideos"))
			{
				currentLastPlayed = json.decode(prefs.getString("userLastPlayedVideos"));
			}

			currentLastPlayed = updateVideoWatchHistory(currentLastPlayed, playedVideo);
			await prefs.setString("userLastPlayedVideos", json.encode(currentLastPlayed));
		}
		print(item);

		SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
		Navigator.pop(context);
		return Future.value(true);

	}

	updateVideoWatchHistory(videos, video)
	{
		bool found = false;

		for (int i = 0; i < videos.length; i++)
		{
			if (videos[i]["id"] == video["id"] && videos[i]["type"] == video["type"])
			{
				videos[i]["resumeAt"] = video["resumeAt"];
				found = true;
			}
		}

		if (!found)
		{
			videos.add(video);
		}

		return videos;
	}

	@override
	void initState()
	{
		super.initState();

		this.stopScreenLock();

		setState(()
		{
			playerTitle = item["title"];
			SystemChrome.setEnabledSystemUIOverlays([]);
			SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

		});

		WidgetsBinding.instance.addObserver(this);

		if(item["resumeAt"] != null)
		{
			duration = parseDuration(item["resumeAt"]);
		}

		try
		{
			videoPlayerController = VideoPlayerController.network(item["video_url"].toString());
		}
		catch(e)
		{
			SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
			Navigator.pop(context);
			Fluttertoast.showToast(msg:"Server Error " + e.toString());
		}

		_chewieController = ChewieController
		(
			videoPlayerController: videoPlayerController,
			aspectRatio: 16/9,
			allowFullScreen: true,
			autoPlay: true,
			showControls: true,
			looping: true,
			startAt: Duration(seconds: duration.inSeconds),
			materialProgressColors: ChewieProgressColors
			(
				playedColor: Colors.red,
				handleColor: Colors.red,
				backgroundColor: Colors.white,
				bufferedColor: Colors.white,
			),
			placeholder: Container
			(
				color: Colors.black,
			),
		);
	}


	@override
	void dispose()
	{
		videoPlayerController.dispose();
		_chewieController.dispose();
		this.enableScreenLock();
		super.dispose();
	}


	@override
	Widget build(BuildContext context)
	{
		var playerTitle = item["title"];
		return WillPopScope
		(
			child: Scaffold
			(
				backgroundColor: Colors.black,
				body: SafeArea
				(
					top: false,
					child: Column
					(
						children: <Widget>
						[
							Expanded
							(
								child: Center
								(
									child: SubTitleWrapper
									(
										videoPlayerController: _chewieController.videoPlayerController,
										subtitleController: subtitleController,
										subtitleStyle: SubtitleStyle
										(
											textColor: Colors.white,
											hasBorder: true,
										),
										videoChild: Chewie
										(
											playerTitle,
											controller: _chewieController,
										),
									),
								),
							),
						],
					),
				),
			),
			onWillPop: onWillPopS
		);
	}
}