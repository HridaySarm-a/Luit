import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_player.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewie_progress_colors.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/material_progress_bar.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/utils.dart';
import 'package:luit/global.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;


class MaterialControls extends StatefulWidget
{
	const MaterialControls(this.item);
	final item;
	// final downloadStatus;
	@override
	State<StatefulWidget> createState()
	{
		return _MaterialControlsState(this.item);
	}
}

class _MaterialControlsState extends State<MaterialControls>
{

	_MaterialControlsState(this.item);
	final item;

	ChewieController _chewieController;
	VideoPlayerValue _latestValue;
	double _latestVolume;
	bool _hideStuff = true;
	Timer _hideTimer;
	Timer _initTimer;
	Timer _showAfterExpandCollapseTimer;
 // ignore: unused_field
	bool _dragging = false;
	bool _displayTapped = false;
	var playerTitle;

	bool showSubtitles = false;

	final barHeight = 48.0;
	final marginSize = 5.0;

	VideoPlayerController controller;
	ChewieController chewieController;

	SubtitleController subtitleController = SubtitleController();
	

	@override
	void initState()
	{
		super.initState();
		subtitleController = SubtitleController
		(
			subtitleUrl: "https://pastebin.com/raw/ZWWAL7fK",
			showSubtitles: showSubtitles == true ? true : false,
			subtitleDecoder: SubtitleDecoder.utf8,
			subtitleType: SubtitleType.webvtt,
		);
		// playerTitle = "TEST";
	}

	@override
	Widget build(BuildContext context)
	{
		if (_latestValue.hasError)
		{
			return chewieController.errorBuilder != null
			? chewieController.errorBuilder(
				context,
				chewieController.videoPlayerController.value.errorDescription,
			)
			: Center
			(
				child: Icon
				(
					Icons.error,
					color: Colors.white,
					size: 42,
				),
			);
		}
		else
		{
			// print("be calm");
		}

		return MouseRegion
		(
			onHover: (_)
			{
				_cancelAndRestartTimer();
			},
			child: GestureDetector
			(
				onTap: () => _cancelAndRestartTimer(),
				child: AbsorbPointer
				(
					absorbing: _hideStuff,
					child: Container
					(
						color:  _hideStuff ? Colors.transparent : Colors.black.withAlpha(30),
						child: Column
						(
							children: <Widget>
							[
								_buildTopBar(context),
								_latestValue != null && !_latestValue.isPlaying && _latestValue.duration == null || _latestValue.isBuffering
								? const Expanded
								(
									child: const Center
									(
										child: const CircularProgressIndicator(),
									),
								)
								: _buildHitArea(),
								_buildBottomBar(context),
							],
						),
					)
				),
			),
		);
	}

	@override
	void dispose()
	{
		_dispose();
		super.dispose();
	}

	void _dispose()
	{
		controller.removeListener(_updateState);
		_hideTimer?.cancel();
		_initTimer?.cancel();
		_showAfterExpandCollapseTimer?.cancel();
	}

	@override
	void didChangeDependencies()
	{
		final _oldController = chewieController;
		chewieController = ChewieController.of(context);
		controller = chewieController.videoPlayerController;

		if (_oldController != chewieController)
		{
			_dispose();
			_initialize();
		}

		super.didChangeDependencies();
	}

	AnimatedOpacity _buildBottomBar(BuildContext context,)
	{
		return AnimatedOpacity
		(
			opacity: _hideStuff ? 0.0 : 1.0,
			duration: Duration(milliseconds: 300),
			child: Stack
			(
				children: <Widget>
				[
					Container
					(
						height: barHeight,
						decoration: BoxDecoration
						(
							gradient:  LinearGradient
							(
								begin: Alignment.topCenter,
								end: Alignment.bottomCenter,
								// Add one stop for each color. Stops should increase from 0 to 1
								stops: [0.0, 0.3, 0.6, 1.0],
								colors:
								[
									// Colors are easy thanks to Flutter's Colors class.
									Colors.black
									.withOpacity(0.0),
									Colors.black
									.withOpacity(0.15),
									Colors.black
									.withOpacity(0.35),
									Colors.black
									.withOpacity(0.6)
								],
							),
						),
						child: Row
						(
							children: <Widget>
							[
								_buildPlayPause(controller),
								chewieController.isLive ? Expanded(child: const Text('LIVE')) : _buildPosition(),
								chewieController.isLive ? const SizedBox() : _buildProgressBar(),
								chewieController.isLive ? Expanded(child: const Text('LIVE')) : _buildDuration(),
								chewieController.allowMuting ? _buildMuteButton(controller) : Container(),
								chewieController.allowFullScreen ? _buildExpandButton() : Container(),
							],
						),
					),
				],
			)
		);
	}

	AnimatedOpacity _buildTopBar(BuildContext context)
	{
		return AnimatedOpacity
		(
			opacity: _hideStuff ? 0.0 : 1.0,
			duration: Duration(milliseconds: 300),
			child: Stack
			(
				children: <Widget>
				[
					Container
					(
						// padding: EdgeInsets.only(left: 100, right: 10),
						height: barHeight,
						decoration: BoxDecoration
						(
							gradient:  LinearGradient
							(
								begin: Alignment.topCenter,
								end: Alignment.bottomCenter,
								// Add one stop for each color. Stops should increase from 0 to 1
								stops: [0.0, 0.3, 0.6, 1.0],
								colors:
								[
									// Colors are easy thanks to Flutter's Colors class.
									Colors.black
									.withOpacity(0.6),
									Colors.black
									.withOpacity(0.35),
									Colors.black
									.withOpacity(0.15),
									Colors.black
									.withOpacity(0.0),
								],
							),
						),
						child: Row
						(
							children: <Widget>
							[
								// _buildCloseBack(),
								_logo(),
								_buildTitle()
							],
						),
					),

				],
			)
		);
	}

	Widget _logo()
	{
		return Padding
		(
			padding: EdgeInsets.only(left: 15, right: 15),
			child: Image.asset("assets/images/logo.png", height: 30, width: 30,)
		);
	}

	GestureDetector _buildExpandButton()
	{
		return GestureDetector
		(
			onTap: _onExpandCollapse,
			child: AnimatedOpacity
			(
				opacity: _hideStuff ? 0.0 : 1.0,
				duration: Duration(milliseconds: 300),
				child: Container
				(
					height: barHeight,
					margin: EdgeInsets.only(right: 12.0),
					padding: EdgeInsets.only(left: 8.0,right: 8.0),
					child: Center
					(
						child: Icon
						(
							chewieController.isFullScreen ? Icons.screen_rotation_outlined : Icons.screen_rotation_outlined,
							color: Colors.white,
						),
					),
				),
			),
		);
	}

	Expanded _buildHitArea()
	{
		return Expanded
		(
			child: GestureDetector
			(
				onTap: ()
				{
					if (_latestValue != null && _latestValue.isPlaying)
					{
						if (_displayTapped)
						{
							setState(()
							{
								_hideStuff = true;
							});
						}
						else
							_cancelAndRestartTimer();
					}
					else
					{
						setState(()
						{
							_hideStuff = true;
						});
					}
				},
				child: Container
				(
					color: Colors.transparent,
					child: Center
					(
						child: AnimatedOpacity
						(
							opacity: _hideStuff ? 0.0 : 1.0,
							duration: Duration(milliseconds: 300),
							child: GestureDetector
							(
								child: Row
								(
									crossAxisAlignment: CrossAxisAlignment.center,
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>
									[
										Container
										(
											decoration: BoxDecoration
											(
												borderRadius: BorderRadius.circular(48.0),
											),
											child: Padding
											(
												padding: EdgeInsets.all(12.0),
												child: _buildSkipBack(Colors.white, barHeight),
											),
										),
										SizedBox(width: 15.0,),
										Container
										(
											decoration: BoxDecoration
											(
												borderRadius: BorderRadius.circular(48.0),
											),
											child: Padding
											(
												padding: EdgeInsets.all(12.0),
												child: _buildPlay(controller),
											),
										),
										SizedBox(width: 15.0),
										Container
										(
											decoration: BoxDecoration
											(
												borderRadius: BorderRadius.circular(48.0),
											),
											child: Padding
											(
												padding: EdgeInsets.all(12.0),
												child: _buildSkipForward(Colors.white, barHeight),
											),
										),
									],
								),
							),
						),
					),
				),
			),
		);
	}
	GestureDetector _buildSkipBack(Color iconColor, double barHeight)
	{
		return GestureDetector
		(
			onTap:()
			{
				_skipBack();
			},
			child: Container
			(
				color: Colors.transparent,
				child: Stack
				(
					alignment: Alignment.center,
					children: <Widget>
					[
						Container
						(
							margin: EdgeInsets.only( top: 5.0),
							child: Icon(Icons.replay_10_outlined, size: 60.0, color: iconColor,),
						),
						// Transform
						// (
						// 	alignment: Alignment.center,
						// 	transform: Matrix4.skewY(0.0)
						// 	..rotateX(math.pi)
						// 	..rotateZ(math.pi),
						// 	child: Icon
						// 	(
						// 		OpenIconicIcons.reload,
						// 		color: iconColor,
						// 		size: 25.0,
						// 	),
						// ),
					],
				)
			),
		);
	}

	void _skipBack()
	{
		// print("SKIP BACK");
		_cancelAndRestartTimer();
		final beginning = Duration(seconds: 0).inMilliseconds;
		final skip = (_latestValue.position - Duration(seconds: 10)).inMilliseconds;
		controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
	}

	GestureDetector _buildSkipForward(Color iconColor, double barHeight)
	{
		return GestureDetector
		(
			onTap: _skipForward,
			child: Container
			(
				color: Colors.transparent,
				child: Stack
				(
					alignment: Alignment.center,
					children: <Widget>
					[
						Container
						(
							margin: EdgeInsets.only( top: 5.0),
							child: Icon(Icons.forward_10_outlined, size: 60.0, color: iconColor,),
						),
						// Icon
						// (
						// 	OpenIconicIcons.reload,
						// 	color: iconColor,
						// 	size: 25.0,
						// ),
					]
				)
			),
		);
	}

	GestureDetector _buildPlay(VideoPlayerController controller)
	{
		return GestureDetector
		(
			onTap: _playPause,
			child: Container
			(
				height: barHeight,
				color: Colors.transparent,
				margin: EdgeInsets.only(left: 3.0, right: 4.0),
				padding: EdgeInsets.only(left: 12.0, right: 12.0),
				child: Icon
				(
					controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
					color: Colors.white,
					size: 60.0,
				),
			),
		);
	}

	void _skipForward()
	{
		_cancelAndRestartTimer();
		final end = _latestValue.duration.inMilliseconds;
		final skip = (_latestValue.position + Duration(seconds: 10)).inMilliseconds;
		controller.seekTo(Duration(milliseconds: math.min(skip, end)));
	}

	GestureDetector _buildMuteButton(VideoPlayerController controller,)
	{
		return GestureDetector
		(
			onTap: ()
			{
				_cancelAndRestartTimer();

				if (_latestValue.volume == 0)
				{
					controller.setVolume(_latestVolume ?? 0.5);
				}
				else
				{
					_latestVolume = controller.value.volume;
					controller.setVolume(0.0);
				}
			},
			child: AnimatedOpacity
			(
				opacity: _hideStuff ? 0.0 : 1.0,
				duration: Duration(milliseconds: 300),
				child: ClipRect
				(
					child: Container
					(
						child: Container
						(
							height: barHeight,
							padding: EdgeInsets.only(left: 8.0, right: 8.0),
							child: Icon
							(
								(_latestValue != null && _latestValue.volume > 0)
								? Icons.volume_up
								: Icons.volume_off,
								color: Colors.white,
							),
						),
					),
				),
			),
		);
	}

	GestureDetector _buildPlayPause(VideoPlayerController controller)
	{
		return GestureDetector
		(
			onTap: _playPause,
			child: Container
			(
				height: barHeight,
				color: Colors.transparent,
				margin: EdgeInsets.only(left: 3.0, right: 4.0),
				padding: EdgeInsets.only(left: 12.0, right: 12.0),
				child: Icon
				(
					controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
					color: Colors.white,
				),
			),
		);
	}

	GestureDetector _buildCloseBack()
	{
		return GestureDetector
		(
			onTap: () async
			{
				_closePlayer();
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
				setState(() 
				{
					SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
				});
			},
			child: Container
			(
				height: barHeight,
				color: Colors.transparent,
				margin: EdgeInsets.only(left: 3.0, right: 4.0),
				padding: EdgeInsets.only(left: 12.0, right: 12.0),
				child: Icon
				(
					Icons.arrow_back_ios,
					color: Colors.white,
					size: 18,
				),
			),
		);
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

	void _closePlayer()
	{
		bool isFinished = _latestValue.position >= _latestValue.duration;

		setState(()
		{
			if (controller.value.isPlaying)
			{
				_hideStuff = false;
				_hideTimer?.cancel();
				controller.pause();
			}
			else
			{
				_cancelAndRestartTimer();
				if (!controller.value.isInitialized)
				{
					controller.initialize().then((_)
					{
						controller.play();
					});
				}
				else
				{
					if (isFinished)
					{
						controller.seekTo(Duration(seconds: 0));
					}
				controller.play();
				}
			}
		});

		Navigator.pop(context);
	}

	Widget _buildPosition()
	{
		final position = _latestValue != null && _latestValue.position != null ? _latestValue.position : Duration.zero;
  		// ignore: unused_local_variable
		final duration = _latestValue != null && _latestValue.duration != null ? _latestValue.duration : Duration.zero;

		return Padding
		(
			padding: EdgeInsets.only(right: 24.0),
			child: Text
			(
				'${formatDuration(position)}',
				style: TextStyle
				(
					color: Colors.white,
					fontSize: 14.0,
				),
			),
		);
	}

	Widget _buildDuration()
	{
		final duration = _latestValue != null && _latestValue.duration != null ? _latestValue.duration : Duration.zero;
		return Padding
		(
			padding: EdgeInsets.only(right: 24.0),
			child: Text
			(
				'${formatDuration(duration)}',
				style: TextStyle
				(
					color: Colors.white,
					fontSize: 14.0,
				),
			),
		);
	}

	Widget _buildTitle()
	{
		return Padding
		(
			padding: EdgeInsets.only(right: 24.0),
			child: item.toString() == null
			? SizedBox.shrink() :
			Text
			(
				item.toString(),
				style: TextStyle
				(
					color: Colors.white,
					fontSize: 11.0,
				),
			),
		);
	}

	void _cancelAndRestartTimer()
	{
		_hideTimer?.cancel();
		_startHideTimer();

		setState(()
		{
			_hideStuff = false;
			_displayTapped = true;
		});
	}

	Future<Null> _initialize() async
	{
		controller.addListener(_updateState);

		_updateState();

		if ((controller.value != null && controller.value.isPlaying) || chewieController.autoPlay)
		{
			_startHideTimer();
		}

		if (chewieController.showControlsOnInitialize)
		{
			_initTimer = Timer(Duration(milliseconds: 200), ()
			{
				setState(()
				{
					_hideStuff = false;
				});
			});
		}
	}

	void _onExpandCollapse()
	{
		setState(()
		{
			_hideStuff = true;

			chewieController.enterFullScreen();
			// chewieController.fullScreenByDefault();
			_showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), ()
			{
				setState(()
				{
					_cancelAndRestartTimer();
				});
			});
		});
	}

	void _playPause()
	{
		bool isFinished = _latestValue.position >= _latestValue.duration;

		setState(()
		{
			if (controller.value.isPlaying)
			{
				_hideStuff = false;
				_hideTimer?.cancel();
				controller.pause();
			}
			else
			{
				_cancelAndRestartTimer();
				if (!controller.value.isInitialized)
				{
					controller.initialize().then((_)
					{
						controller.play();
					});
				}
				else
				{
					if (isFinished)
					{
						controller.seekTo(Duration(seconds: 0));
					}
					controller.play();
				}
			}
		});
	}

	void _startHideTimer()
	{
		_hideTimer = Timer(const Duration(seconds: 3), ()
		{
			setState(()
			{
				_hideStuff = true;
			});
		});
	}

	void _updateState()
	{
		setState(()
		{
			_latestValue = controller.value;
		});
	}

	Widget _buildProgressBar()
	{
		return Expanded
		(
			child: Padding
			(
				padding: EdgeInsets.only(right: 20.0),
				child: MaterialVideoProgressBar
				(
					controller,
					onDragStart: ()
					{
						setState(()
						{
							_dragging = true;
						});
						_hideTimer?.cancel();
					},
					onDragEnd: ()
					{
						setState(()
						{
							_dragging = false;
						});
						_startHideTimer();
					},
					colors: chewieController.materialProgressColors ??
					ChewieProgressColors
					(
						playedColor: Theme.of(context).accentColor,
						handleColor: Theme.of(context).accentColor,
						bufferedColor: Theme.of(context).backgroundColor,
						backgroundColor: Theme.of(context).disabledColor
					)
				)
			)
		);
	}
}
