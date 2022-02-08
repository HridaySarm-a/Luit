import 'package:flutter/services.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_player.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_progress_colors.dart';
import 'package:flutter/material.dart';
import 'package:luit/utilities/coverter.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class TrailerVideoPlayer extends StatefulWidget 
{
	TrailerVideoPlayer(this.item);

	final item;

	@override
	State<StatefulWidget> createState() 
	{
		return TrailerVideoPlayerState(this.item);
  	}
}

class TrailerVideoPlayerState extends State<TrailerVideoPlayer> with WidgetsBindingObserver 
{
	TrailerVideoPlayerState(this.item);
	final item;

	VideoPlayerController videoPlayerController;
	ChewieController _chewieController;
	DateTime currentBackPressTime;
	var playerTitle;
	Duration duration = Duration(seconds: 0);

	String link;
  	final SubtitleController subtitleController = SubtitleController
	(
		subtitleUrl: "https://pastebin.com/raw/ZWWAL7fK",
		showSubtitles: true,
		subtitleDecoder: SubtitleDecoder.utf8,
		subtitleType: SubtitleType.webvtt,
  	);



	void stopScreenLock() async
	{
		Wakelock.enable();
	}

	//  Handle back press
	Future<bool> onWillPopS() async
	{
		if(_chewieController.isPlaying)
		{
			_chewieController.pause();

		}
		else
		{
			// print("HEA");
		}

		SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
		Navigator.pop(context);
		return Future.value(true);
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


		videoPlayerController = VideoPlayerController.network(item["trailer_url"].toString());

		_chewieController = ChewieController
		(
			videoPlayerController: videoPlayerController,
			aspectRatio: 3/2,
			autoPlay: true,
			looping: true,
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
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }


	@override
	Widget build(BuildContext context)
	{
		return WillPopScope
		(
			child: Scaffold
			(
				body: SafeArea
				(
					top: true,
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