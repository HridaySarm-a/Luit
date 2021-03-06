import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luit/Menu%20Bar/aboutPhone.dart';
import 'package:luit/global.dart';

class AppSettingsPage extends StatefulWidget
{
	@override
	_AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettingsPage>
{
	bool changed = true;

	Widget appBar()
	{
		return AppBar
		(
			title: Text
			(
				"App Settings",
				style: TextStyle(fontSize: 16.0),
			),
			centerTitle: true,
			backgroundColor: Colors.black,
		);
	}

	Widget wifiTitleText()
	{
		return Text
		(
			"Wi-Fi Only",
			style: TextStyle(
			color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
		);
	}

	Widget leadingWifiListTile()
	{
		return Container
		(
			padding: EdgeInsets.only(right: 20.0),
			decoration: new BoxDecoration
			(
				border: new Border
				(
					right: new BorderSide(width: 1.0, color: Colors.white24)
				)
			),
			child: Icon
			(
				FontAwesomeIcons.signal,
				color: Colors.white,
				size: 20.0,
			),
		);
	}

	Widget wifiSubtitle()
	{
		return Container
		(
			height: 40.0,
			child: Column
			(
				children: <Widget>
				[
					SizedBox(height: 8.0,),
					Row
					(
						children: <Widget>
						[
							Expanded
							(
								flex: 1,
								child: Text("Download video only when connected to wi-fi.",
								style: TextStyle(color: Colors.white, fontSize: 12.0)),
							),
						],
					),
				],
			),
		);
	}

	Widget wifiSwitch()
	{
		return Switch
		(
			activeColor: Colors.blue,
			value: changed,
			onChanged: (bool newValue)
			{
				setState(()
				{
					changed = newValue;
					if(changed == true)
					{
						wifiEnabled = true;
						print(wifiEnabled);
					}
					else
					{
						wifiEnabled = false;
					}
				});
			}
		);
        // return null;
	}

	//Widget used to create ListTile to show wi-fi status
	Widget makeListTile1()
	{
		return ListTile
		(
			contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
			leading: leadingWifiListTile(),
			title: wifiTitleText(),
			subtitle: wifiSubtitle(),
			trailing: wifiSwitch(),
		);
	}

	Widget _listTile4(context)
	{
		return ListTile
		(
			contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
			leading: Container
			(
				padding: EdgeInsets.only(right: 20.0),
				decoration: new BoxDecoration
				(
					border: new Border
					(
						right: new BorderSide(width: 1.0, color: Colors.white24)
					)
				),
				child: Icon
				(
					FontAwesomeIcons.mobile,
					color: Colors.white,
					size: 20.0,
				),
			),
			title: Text
			(
				"About Phone",
				style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
			),
			subtitle: Container
			(
				height: 40.0,
				child: Column
				(
					children: <Widget>
					[
						SizedBox(height: 8.0,),
						Row
						(
							children: <Widget>
							[
								Expanded
								(
									flex: 1,
									child: Text("Phone info, version, build number",
									style: TextStyle(color: Colors.white, fontSize: 12.0)),
								),
							],
						),
					],
				),
			),
			trailing: Icon
			(
				Icons.arrow_forward_ios,
				size: 15.0,
				color: Color.fromRGBO(237, 237, 237, 1.0),
			),
			onTap: ()
			{
				var route = MaterialPageRoute(builder: (context) => AboutPhone());
				Navigator.push(context, route);
			},
		);
	}

	Widget scaffold(context)
	{
		return Scaffold
		(
			backgroundColor: Color(int.parse("0xff02071A")),
			appBar: appBar(),
			body: Container
			(
				child: Card
				(
					elevation: 8.0,
					margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
					child: Container
					(
						decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
						child: ListView
						(
							shrinkWrap: true,
							scrollDirection: Axis.vertical,
							physics: ClampingScrollPhysics(),
							children: <Widget>
							[
								makeListTile1(),
								Container
								(
									color: Color(int.parse("0xff02071A")),
									height: 15.0,
								),
								_listTile4(context)
							],
						),
					),
				)
			)
		);
	}

	//  Used to save value to shared preference of wi-fi switch
	// addBoolToSF(value) async
	// {
	// 	// print("va $value");
	// 	prefs = await SharedPreferences.getInstance();
	// 	prefs.setBool('boolValue', value);
	// }

	//  Used to get saved value from shared preference of wi-fi switch
	// getValuesSF() async
	// {
	// 	prefs = await SharedPreferences.getInstance();
	// 	setState(()
	// 	{
	// 		boolValue = prefs.getBool('boolValue');
	// 	});
	// }

	@override
	void initState()
	{
		super.initState();
		// this.getValuesSF();

		//Used to check connection status of use device
		// connectivity = new Connectivity();
		// subscription =
		// connectivity.onConnectivityChanged.listen((ConnectivityResult result)
		// {
		// 	_connectionStatus = result.toString();
		// 	// print(_connectionStatus);
		// 	checkConnectionStatus = result.toString();

		// 	if (result == ConnectivityResult.wifi)
		// 	{
		// 		setState(()
		// 		{
		// 			_connectionStatus = 'Wi-Fi';
		// 		});
		// 	}
		// 	else if (result == ConnectivityResult.mobile)
		// 	{
		// 		setState(()
		// 		{
		// 			_connectionStatus = 'Mobile';
		// 		});
		// 	} 
		// 	else if (result == ConnectivityResult.none)
		// 	{
		// 		var router = new MaterialPageRoute(builder: (BuildContext context) => new NoNetwork());
		// 		Navigator.of(context).push(router);
		// 	}
		// });
	}

	@override
	Widget build(BuildContext context)
	{
		// if (boolValue == null)
		// {
		// 	boolValue = false;
		// }
		return scaffold(context);
  	}
}
