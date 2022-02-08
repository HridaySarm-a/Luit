import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_player.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_progress_colors.dart';
import 'package:video_player/video_player.dart';

class DownloadedVideoPlayer extends StatefulWidget
{
	DownloadedVideoPlayer({this.taskId, this.name, this.fileName, this.downloadStatus, this.localPath});

	final String taskId;
	final String name;
	final String fileName;
	final int downloadStatus;
	final String localPath;


	@override
	State<StatefulWidget> createState()
	{
		return _DownloadedVideoPlayerState(this.localPath);
	}
}

class _DownloadedVideoPlayerState extends State<DownloadedVideoPlayer> with WidgetsBindingObserver
{

	_DownloadedVideoPlayerState(this._localPath);

	final _localPath;
 	// ignore: unused_field
	TargetPlatform _platform;
	VideoPlayerController _videoPlayerController1;
	ChewieController _chewieController;
	var url;
	var vFileName;

	String localPath;

	@override
	void initState()
	{
		super.initState();
		setState(()
		{
			SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

			// playerTitle = widget.name;
			vFileName = widget.fileName;

		});

		WidgetsBinding.instance.addObserver(this);
		_videoPlayerController1 = VideoPlayerController.file(File("$_localPath/$vFileName"));

		// print(_localPath);
		// print("_videoPlayerController1");
		_chewieController = ChewieController
		(
			videoPlayerController: _videoPlayerController1,
			aspectRatio: 3/2,
			autoPlay: true,
			looping: true,
			// deviceOrientationsAfterFullScreen: ,
			materialProgressColors: ChewieProgressColors
			(
				playedColor: Colors.red,
				handleColor: Colors.red,
				// backgroundColor: Colors.white.withOpacity(0.6),
				backgroundColor: Colors.white,
				bufferedColor: Colors.white,
			),
			placeholder: Container
			(
				color: Colors.black,
			),
			// autoInitialize: true,
		);


  		// ignore: unused_local_variable
		var r = _videoPlayerController1.value.aspectRatio;
		String os = Platform.operatingSystem;

		if(os == 'android')
		{
			setState(()
			{
				_platform = TargetPlatform.android;
			});
		}
		else
		{
			setState(()
			{
				_platform = TargetPlatform.iOS;
			});
		}
	}

	@override
	void dispose()
	{
		super.dispose();
		SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
		_videoPlayerController1.dispose();
		_chewieController.dispose();

	}

	@override
	Widget build(BuildContext context)
	{
		return Scaffold
		(
			backgroundColor: Colors.black,
			body: Column
			(
				children: <Widget>
				[
					Expanded
					(
						child: Center
						(
							// child: VideoPlayer(_videoPlayerController1),
							child: Chewie
							(
								vFileName,
								controller: _chewieController,

							),
						),
					),
				],
			),
		);
	}
}