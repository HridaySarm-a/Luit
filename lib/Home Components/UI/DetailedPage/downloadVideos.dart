import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luit/Home%20Components/UI/subscriptionPage.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/downloadVideoPlayer.dart';
import 'package:luit/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';


const debug = true;

class MyHomePage extends StatefulWidget with WidgetsBindingObserver
{
	final TargetPlatform platform;

	MyHomePage(this.item, {Key key, this.title, this.platform}) : super(key: key);

	final  item;

	final String title;

	@override
	_MyHomePageState createState() => new _MyHomePageState(this.item);
}

class _MyHomePageState extends State<MyHomePage>
{

	_MyHomePageState(this.item);

	final  item;

	List <_TaskInfo> _tasks;
	List<_ItemHolder> _items;
	bool _isLoading;
	bool _permissionReady;
	String _localPath;
	TargetPlatform platform;
	ReceivePort _port = ReceivePort();
	var url;
	var name;
	final Connectivity _connectivity = Connectivity();
	StreamSubscription<ConnectivityResult> _connectivitySubscription;


	bool paymentStatus = false;

	@override
	void initState()
	{
		super.initState();
		_bindBackgroundIsolate();
		// STEP 3 UPDATE DOWNLOAD PROGRESS
		FlutterDownloader.registerCallback(downloadCallback);
		_isLoading = true;
		_permissionReady = false;
		_prepare();
		initPlatformState();
		 initConnectivity();
    	_connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
		wifiEnabled = false;
		// getSharedPreferenceData(_TaskInfo);
	}

	@override
	void dispose()
	{
		// dispose or remove the port name.
		_unbindBackgroundIsolate();
    	_connectivitySubscription.cancel();
		super.dispose();
	}

	void _bindBackgroundIsolate()
	{
		// USED TO MAINATAIN COMMUNICATION BETWEEN MAIN ISOLATE AND BACKGROUND ISOLATE IN WHICH DOWNLOAD HAPPENS SO REGISTRATION OF ISOLATE IS REQUIRED
		bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
		if (!isSuccess)
		{
			_unbindBackgroundIsolate();
			_bindBackgroundIsolate();
			return;
		}
		// LISTENER AT RECEIVER PORT TO RECEIVE DATA SEND BY SendPort.
		_port.listen((dynamic data)
		{
			if (debug)
			{
				// print('UI Isolate Callback: $data');
			}

			String id = data[0];
			DownloadTaskStatus status = data[1];
			int progress = data[2];

			if (_tasks != null && _tasks.isNotEmpty)
			{
				final task = _tasks.firstWhere((task) => task.taskId == id);

				if (task != null)
				{
					setState(()
					{
						task.status = status;
						task.progress = progress;
					});
				}
			}
		});
	}

	// REMOVE A PORT NAME AFTER THE DOWNLOAD TASK IS COMPLETED, WON"T BE OF GREATER USE IF CALLED IN DISPOSE AFTER TASK IS COMPLETED. STILL PORTS WILL BE ABLE TO COMMUNICATE BETWEEN EACH OTHER,
	void _unbindBackgroundIsolate()
	{
		IsolateNameServer.removePortNameMapping('downloader_send_port');
	}

	static void downloadCallback(String id, DownloadTaskStatus status, int progress)
	{
		if (debug)
		{
			// print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
		}

		final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
		send.send([id, status, progress]);
	}

	// gather device info
	Future<void> initPlatformState() async
	{
		Map<String, dynamic> deviceData;

		try
		{
			if (Platform.isAndroid)
			{
				platform = TargetPlatform.android;
			}
			else if (Platform.isIOS)
			{
				platform = TargetPlatform.iOS;
			}
		}
		on PlatformException
		{
			deviceData = <String, dynamic>
			{
				'Error:': 'Failed to get platform version.'
			};
		}

		if (!mounted) return;

			setState(()
			{
				// _deviceData = deviceData;
			});
	}

	Future<void> initConnectivity() async 
	{

		ConnectivityResult result;
		// Platform messages may fail, so we use a try/catch PlatformException.
		try 
		{
			result = await _connectivity.checkConnectivity();
		} on PlatformException catch (e) 
		{
			print(e);
		}

		if (!mounted) 
		{
			return Future.value(null);
		}

		return _updateConnectionStatus(result);
	}

	Future<void> _updateConnectionStatus(ConnectivityResult result) async 
	{
		switch (result) 
		{
		case ConnectivityResult.wifi:
			setState(()
			{
				wifiEnabled = true;
			});
			break;
		case ConnectivityResult.mobile:
			setState(()
			{
				wifiEnabled = false;
			});
			break;
		case ConnectivityResult.none:
			setState(()
			{
				wifiEnabled = false;
			});
			break;
		default:
			setState(()
			{
				wifiEnabled = false;
			});
			break;
		}
	}

	getSharedPreferenceData(task)
	{
		var oldData = [];

		if (prefs.containsKey("downloadedVideos"))
		{
			oldData = json.decode(prefs.getString("downloadedVideos"));
		}

		for(int i = 0; i < oldData.length; i++)
		{
			if(oldData[i]["id"] == item["id"] && oldData[i]["type"] == item["type"])
			{
				print("hellooo world, i am learning flutter");
			}
			else
			{
				setState(() 
				{
					task.status = DownloadTaskStatus.undefined;
				});
			}
		}
	}

	saveToSharedPreference(_TaskInfo task) async
	{
		var video =
		{
			"title": task.name,
			"id": item["id"],
			"type": item["type"],
			"url": task.link,
			"path": _localPath,
			"image": item["poster"],
			"duration": item["duration"],
			"publishedYear": item["publish_year"]
		};

		var oldData = [];

		if (prefs.containsKey("downloadedVideos"))
		{
			oldData = json.decode(prefs.getString("downloadedVideos"));
		}

		oldData.add(video);

		await prefs.setString("downloadedVideos", json.encode(oldData));
	}


	// STEP 2 CREATE A NEW DOWNLOAD TASK
	void _requestDownload(_TaskInfo task) async
	{
		print("loval path " + _localPath.toString());
		task.taskId = await FlutterDownloader.enqueue
		(
			url: task.link,
			headers: {"auth": "test_for_sql_encoding"},
			savedDir: _localPath,
			showNotification: true,
			openFileFromNotification: true
		);

		// if(task.status == DownloadTaskStatus.complete)
		// {
			print("saved");
			saveToSharedPreference(task);
		// }
	}

	// CANCEL A TASK
	void _cancelDownload(_TaskInfo task) async
	{
		await FlutterDownloader.cancel(taskId: task.taskId);
		_requestDownload(task);
	}

	// PAUSE A TASK
	void _pauseDownload(_TaskInfo task) async
	{
		await FlutterDownloader.pause(taskId: task.taskId);
	}

	// RESUME DOWNLOAD
	void _resumeDownload(_TaskInfo task) async
	{
		String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
		task.taskId = newTaskId;
	}

	// RETRY DOWNLOAD
	void _retryDownload(_TaskInfo task) async
	{
		// print("hiii");
		String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
		task.taskId = newTaskId;
	}

	void _showDialog3(task)
	{
		// flutter defined function
		showDialog(
			context: context,
			builder: (BuildContext context)
			{
				return AlertDialog
				(
					backgroundColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
					title: new Text
					(
						"Delete Download?",
						style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
					),
					content: new Text
					(
						"Delete the content from downloads",
						style: TextStyle
						(
						color: Colors.black.withOpacity(0.7),
						fontWeight: FontWeight.w600,
						fontSize: 16.0
						),
					),
					actions: <Widget>
					[
						new FlatButton
						(
							child: new Text
							(
								"Delete ",
								style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
							),
							onPressed: ()
							{
								_delete(task);
								Navigator.pop(context);
							},
						),
						new FlatButton
						(
							child: new Text
							(
								"Play",
								style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
							),
							onPressed: ()
							{
								// _openDownloadedFile(task, context);
								Navigator.of(context).pop();
							},
						),
					],
				);
			},
		);
	}

	// user permission to download over mobile data
	void downloadOverMobiledata(task)
	{
		// flutter defined function
		showDialog(
			context: context,
			builder: (BuildContext context)
			{
				return AlertDialog
				(
					backgroundColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
					title: new Text
					(
						"Connected to mobile data!",
						style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
					),
					content: new Text
					(
						"Do you want to download videos using mobile data?",
						style: TextStyle
						(
						color: Colors.black.withOpacity(0.7),
						fontWeight: FontWeight.w600,
						fontSize: 16.0
						),
					),
					actions: <Widget>
					[
						new FlatButton
						(
							child: new Text
							(
								"Yes ",
								style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
							),
							onPressed: ()
							{
								_requestDownload(task);
								Navigator.pop(context);
							},
						),
						new FlatButton
						(
							child: new Text
							(
								"Cancel",
								style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
							),
							onPressed: ()
							{
								// _openDownloadedFile(task, context);
								Navigator.of(context).pop();
							},
						),
					],
				);
			},
		);
	}

	// OPEN A TASK
	Future<bool> _openDownloadedFile(_TaskInfo task, BuildContext context)
	{
		var fileNamenew = task.link.split("/").last;

		var router = new MaterialPageRoute
		(
			builder: (BuildContext context) => DownloadedVideoPlayer
			(
				taskId: task.taskId,
				name: fileNamenew,
				fileName: fileNamenew,
				downloadStatus: 0,
				localPath :_localPath,
			)
		);

		Navigator.of(context).push(router);
		return null;
	}

	// REMOVE A TASK
	void _delete(_TaskInfo task) async
	{
		await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true);
		await _prepare();

		var oldData = [];

		if (prefs.containsKey("downloadedVideos"))
		{
			oldData = json.decode(prefs.getString("downloadedVideos"));
		}

		for(int i = 0; i < oldData.length; i++)
		{
			if(task.link == oldData[i]["url"] && task.name == oldData[i]["title"])
			{
				oldData.removeAt(i);
				await prefs.setString("downloadedVideos", json.encode(oldData));
				break;
			}
		}

		setState(() {});
	}

	Future<bool> _checkPermission() async
	{
		if (widget.platform == TargetPlatform.android)
		{
			final status = await Permission.storage.status;

			// print("PERSMISSIONS STATUS");
			// print(status);

			if (status != PermissionStatus.granted)
			{
				final result = await Permission.storage.request();
				if (result == PermissionStatus.granted)
				{
					return true;
				}
			}
			else
			{
				return true;
			}
		}
		else
		{
			return true;
		}
		return false;
	}

	// STEP 4 LOAD ALL TASKS OR TASK WITH CONDITIONS
	Future<Null> _prepare() async
	{

		final tasks = await FlutterDownloader.loadTasks();

		int count = 0;
		_tasks = [];
		_items = [];

		_tasks.add(_TaskInfo(name: item['title'].toString(), link: item['video_url'].toString()));

		for (int i = count; i < _tasks.length; i++)
		{
			_items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
			count++;
		}

		tasks?.forEach((task)
		{
			for (_TaskInfo info in _tasks)
			{
				if (info.link == task.url)
				{
					info.taskId = task.taskId;
					info.status = task.status;
					info.progress = task.progress;
				}
			}
		});

		_permissionReady = await _checkPermission();

		_localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

		final savedDir = Directory(_localPath);
		bool hasExisted =  savedDir.existsSync();

		if (!hasExisted)
		{
			print("created");
			savedDir.create();
		}

		print("has existed " + hasExisted.toString());
		print("saved " + savedDir.toString());

		setState(()
		{
			_isLoading = false;
		});
	}

	Future<String> _findLocalPath() async
	{
		final directory = platform == TargetPlatform.android ? await getApplicationSupportDirectory(): await getApplicationDocumentsDirectory();

		return directory.path;
	}

	@override
	Widget build(BuildContext context)
	{
		return new Container
		(
			child: Builder
			(
				builder: (context) => _isLoading
				? new Center
				(
					child: new CircularProgressIndicator(),
				)
				: _permissionReady
					? _buildDownloadList(context)
					: _buildNoPermissionWarning()),
		);
	}

	Widget _buildDownloadList(BuildContext context)
	{
		bool isSinglePayment = true;
		return Container
		(
			child: ListView
			(
				padding: const EdgeInsets.symmetric(vertical: 16.0),
				children: _items.map((item) => item.task == null
					// ? _buildListSection(item.name)
					? SizedBox.shrink()
					: DownloadItem
					(
						data: item,
						onItemClick: (task)
						{
							paymentStatus == true ?
							_openDownloadedFile(task, context).then((success)
							{
								if (!success)
								{
									Scaffold.of(context).showSnackBar(SnackBar
									(
										content: Text('Cannot open this file'))
									);
								}
							})
							: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SubscriptionPage(item, isSinglePayment)));
						},
						onActionClick: (task)
						{

							if (task.status == DownloadTaskStatus.undefined)
							{
								print(wifiEnabled);
								wifiEnabled == true ? _requestDownload(task) : downloadOverMobiledata(task);
							}
							else if (task.status == DownloadTaskStatus.running)
							{
								_pauseDownload(task);
							}
							else if (task.status == DownloadTaskStatus.paused)
							{
								// print("paused");
								_resumeDownload(task);
							}
							else if (task.status == DownloadTaskStatus.complete)
							{
								// print(task.status);

								_openDownloadedFile(task, context);
								// _showDialog3(task);
							}
							else if (task.status == DownloadTaskStatus.failed)
							{
								// print("RETYR");
								_retryDownload(task);
								// _requestDownload(task);
							}
							else if(task.status == DownloadTaskStatus.enqueued)
							{
								_showDialog3(task);
							}
						},
					)
				).toList(),
			),
		);
	}

	Widget _buildNoPermissionWarning()
	{
		return Container
		(
			child: Center
			(
				child: Column
				(
					mainAxisSize: MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.center,
					children:
					[
						Padding
						(
							padding: const EdgeInsets.symmetric(horizontal: 24.0),
							child: Text
							(
								'Please grant accessing storage permission to continue -_-',
								textAlign: TextAlign.center,
								style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
							),
						),
						SizedBox(height: 32.0),
						FlatButton
						(
							onPressed: ()
							{
								_checkPermission().then((hasGranted)
								{
									setState(()
									{
										_permissionReady = hasGranted;
									});
								});
							},
							child: Text
							(
								'Retry',
								style: TextStyle
								(
									color: Colors.blue,
									fontWeight: FontWeight.bold,
									fontSize: 20.0
								),
							)
						)
					],
				),
			),
		);
	}
}

class DownloadItem extends StatelessWidget
{
	final _ItemHolder data;
	final Function(_TaskInfo) onItemClick;
	final Function(_TaskInfo) onActionClick;

	DownloadItem({this.data, this.onItemClick, this.onActionClick});

	@override
	Widget build(BuildContext context)
	{
		// print(data);
		return Container
		(
			// color: Colors.blue,
			padding: const EdgeInsets.only(left: 16.0, right: 8.0),
			child: InkWell
			(
				onTap: data.task.status == DownloadTaskStatus.complete
					? ()
					{
						onItemClick(data.task);
					}
					: data.task.status == DownloadTaskStatus.running
						? ()
						{
							_buildActionForTask(data.task);
						}
						: null,
				onLongPress: data.task.status == DownloadTaskStatus.complete
				? ()
				{
					_buildActionForTask(data.task);
				}
				: null,
				child: Stack
				(
					children: <Widget>
					[
						Column
						(
							children:
							[
								_buildActionForTask(data.task),
							],
						),
						data.task.status == DownloadTaskStatus.running || data.task.status == DownloadTaskStatus.paused
							? Positioned
							(
								left: 0.0,
								right: 0.0,
								bottom: 0.0,
								child: LinearProgressIndicator(value: data.task.progress / 100),
							)
							: Container()
					].where((child) => child != null).toList(),
				),
			),
		);
	}

	Widget _buildActionForTask(_TaskInfo task)
	{
		if (task.status == DownloadTaskStatus.undefined)
		{
			return Column
			(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.end,
				children:
				[
					RawMaterialButton
					(
						onPressed: ()
						{
							onActionClick(task);
						},
						child: Icon(Icons.file_download),
						shape: CircleBorder(),
						constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
					),
					Text("Download")
				]
			);
		}
		else if (task.status == DownloadTaskStatus.running)
		{
			return Column
			(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.end,
				children:
				[
					RawMaterialButton
					(
						onPressed: ()
						{
							onActionClick(task);
						},
						onLongPress: ()
						{
							// print(task.status);
							onActionClick(task);

						},
						child: Icon
						(
							Icons.pause,
							color: Colors.red,
						),
						shape: CircleBorder(),
						constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
					),
					Text("")
				]
			);
		}
		else if (task.status == DownloadTaskStatus.paused)
		{
			// print("hellooo");
			return RawMaterialButton
			(
				onPressed: ()
				{
					// print(task.status);
					onActionClick(task);
				},
				onLongPress: ()
				{
					// print(task.status);
					onActionClick(task);

				},
				child: Icon
				(
					Icons.play_arrow,
					color: Colors.green,
				),
				shape: CircleBorder(),
				constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
			);
		}
		else if (task.status == DownloadTaskStatus.complete)
		{
			return Column
			(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.end,
				children:
				[
					RawMaterialButton
					(
						fillColor: Colors.amber,
						onPressed: ()
						{
							// print("hello");
							onActionClick(task);
						},
						onLongPress: () async
						{
							// remove a task
							// task.status = DownloadTaskStatus.enqueued;
							// onActionClick(task);
						},
						child: Icon
						(
							Icons.play_arrow,
							color: Colors.green,
						),
						shape: CircleBorder(),
						constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
					),
					Text
					(
						'Done',
						style: TextStyle(color: Colors.green),
					),
				],
			);
		}
		else if (task.status == DownloadTaskStatus.canceled)
		{
			return Text('Canceled', style: TextStyle(color: Colors.red));
		}
		else if (task.status == DownloadTaskStatus.failed)
		{
			return Column
			(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.end,
				children:
				[
					RawMaterialButton
					(
						onPressed: ()
						{
							// print(DownloadTaskStatus.failed);
							// print("TASK");
							// print(task.status);
							// print("TASK");
							task.status = DownloadTaskStatus.undefined;
							onActionClick(task);
						},
						child: Icon
						(
							Icons.refresh,
							color: Colors.green,
						),
						shape: CircleBorder(),
						constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
					),
					Text('Failed', style: TextStyle(color: Colors.red)),
				],
			);
		}
		else if (task.status == DownloadTaskStatus.enqueued)
		{
			return Column
			(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.end,
				children:
				[
					RawMaterialButton
					(
						onPressed: ()
						{
							onActionClick(task);
						},
						child: Icon(Icons.file_download),
						shape: CircleBorder(),
						constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
					),
					Text("Download")
				]
			);
		}
		else
		{
			return null;
		}
	}
}

class _TaskInfo
{
	final String name;
	final String link;

	String taskId;
	int progress = 0;
	DownloadTaskStatus status = DownloadTaskStatus.undefined;

	_TaskInfo({this.name, this.link});
}

class _ItemHolder
{
	final String name;
	final _TaskInfo task;

	_ItemHolder({this.name, this.task});
}
