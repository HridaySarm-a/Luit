import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';

class EditProfilePage extends StatefulWidget
{
	@override
	_EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
{
	FormData formdata = FormData();

	TextEditingController nameController = new TextEditingController(text:luitUser["name"]);
	TextEditingController dobController = new TextEditingController(text:luitUser["dob"]);
	TextEditingController phoneController = new TextEditingController(text:luitUser["mobile"]);
	TextEditingController emailController = new TextEditingController(text:luitUser["email"]);

	final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	final formKey = new GlobalKey<FormState>();

	final picker = ImagePicker();
	var pickedFile;
	String base64Image = "";
	var picture;

	File imageFile;

	var temp;

	bool isImageUploaded = false;

	@override
	void initState()
	{
		super.initState();
		getUserProfile();
	}

	@override
	Widget build(BuildContext context)
	{
		return Theme
        (
            data: ThemeData
            (
                scaffoldBackgroundColor: Color(int.parse("0xff02071a")),
                brightness: Brightness.dark,
                accentColor: Colors.white,
                canvasColor: Colors.white,
            ),
            child: Scaffold
            (
                key: _scaffoldKey,
                appBar: appbar(),
                body: scaffoldBody(),
            )
		);
	}

	//Appbar
	Widget appbar()
	{
		return AppBar
		(
			title: Text("Edit Profile",style: TextStyle(fontSize: 16.0, color: Colors.white),),
			centerTitle: true,
			leading: IconButton
			(
				icon: Icon
				(
					Icons.arrow_back,
					color: Colors.white
				),
				onPressed: ()
				{
					Navigator.pop(context);
				}
			),
			backgroundColor: Colors.black,
		);
	}

	//Scaffold body
	Widget scaffoldBody()
	{
		return SingleChildScrollView
		(
            padding: EdgeInsets.only(top:25),
			child: Column
			(
				children: <Widget>
				[
					Stack
					(
						children: <Widget>
						[
							showImage(),
							browseImageButton(),
						],
					),
					form(),
				]
			)
		);
	}

	//Browse button container
	Widget browseImageButton()
	{
		return Container
		(
			height: 45.0,
			width:45.0,
			margin: EdgeInsets.fromLTRB(125.0, 170.0, 0.0, 0.0),
			decoration: BoxDecoration
			(
				shape: BoxShape.circle,
				color: Colors.green,
			),
			child: IconButton
			(
				icon: Icon(Icons.add_a_photo),
				onPressed: _onButtonPressed,
			),
		);
	}

	//  Form that containing text fields to update profile
	Widget form()
	{
		print(luitUser);

		return Container
		(
			padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0, bottom: 20.0),
			child: Form
			(
				key: formKey,
				child: Column
				(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>
					[
						SizedBox(height: 30.0),
						buildNameTextField(username),
						SizedBox(height: 20.0),
						buildDOBTextField(dob),
						SizedBox(height: 20.0),
						buildMobileTextField(mobile),
						SizedBox(height: 20.0),
						buildEmailTextField(email),
						SizedBox(height: 20.0),
						updateButtonContainer(),
						SizedBox(height: 10.0),
					]
				)
			)
		);
	}

	//  Name TextField to update name
	Widget buildNameTextField(String hintText)
	{
		return TextFormField
		(
			controller: nameController,
			keyboardType: TextInputType.text,
			decoration: InputDecoration
			(
				contentPadding: EdgeInsets.all(5.0),
				hintText: hintText == null || hintText == "" ? " Name" : hintText,
				hintStyle: TextStyle
				(
					color: Colors.grey,
					fontSize: 16.0,
				),
				border: OutlineInputBorder
				(
					borderRadius: BorderRadius.circular(10.0),
				),
				prefixIcon: Icon(Icons.account_box),
			),
			validator: null
		);
	}

	//TextField Date of birth field
	Widget buildDOBTextField(String hintText)
	{
		return TextFormField
		(
			controller: dobController,
			focusNode: AlwaysDisabledFocusNode(),
			decoration: InputDecoration
			(
				contentPadding: EdgeInsets.all(5.0),
				border: OutlineInputBorder
				(
					borderRadius: BorderRadius.circular(10.0),
				),
				prefixIcon: Icon(Icons.calendar_today),
			),
            onTap: () async
            {
                DateTime date = DateTime(1900);
                FocusScope.of(context).requestFocus(new FocusNode());
                date = await showDatePicker
                (
                    context: context,
                    initialDate:DateTime.now(),
                    firstDate:DateTime(1900),
                    lastDate: DateTime(2100)
                );
				DateFormat formatter = DateFormat('dd-MM-yyyy');
                dobController.text = formatter.format(date);
            },
			validator: null,
		);
	}

	// TextField to update mobile number
	Widget buildMobileTextField(String hintText)
	{
		print(hintText.runtimeType);
		print("mobile text fiels");

		return TextFormField
		(
			enabled: false,
			controller: phoneController,
			keyboardType: TextInputType.phone,
			decoration: InputDecoration
			(
				contentPadding: EdgeInsets.all(5.0),
				hintText: hintText.toString() == null || hintText == "" ? "Mobile" : hintText.toString(),
				hintStyle: TextStyle
				(
					color: Colors.grey,
					fontSize: 16.0,
				),
				border: OutlineInputBorder
				(
					borderRadius: BorderRadius.circular(10.0),
				),
				prefixIcon: Icon(Icons.phone),
			),
			validator: null,
		);
	}

	Widget buildEmailTextField(String hintText)
	{
		return TextFormField
		(
			enabled: false,
			controller: emailController,
			keyboardType: TextInputType.text,
			decoration: InputDecoration
			(
				contentPadding: EdgeInsets.all(5.0),
				hintText: hintText == null || hintText == "" ?  " Email" : hintText,
				hintStyle: TextStyle
				(
					color: Colors.grey,
					fontSize: 16.0,
				),
				border: OutlineInputBorder
				(
					borderRadius: BorderRadius.circular(10.0),
				),
				prefixIcon: Icon(Icons.email),
			),
			validator: null
		);
	}

	//Update button container
	Widget updateButtonContainer()
	{
		return SizedBox
        (
            width: double.infinity,
            child: MaterialButton
            (
                height: 50.0,
                color: Color(int.parse("0xffcf2450")),
                child: Text
                (
                    "UPDATE PROFILE",
                    style: TextStyle(color: Colors.white),
                ),
                onPressed: ()
                {
                    // Navigator.pop(context);
					updateProfile();
                }
            )
        );
	}

	//Preview of selected image
	Widget showImage()
	{
		return  Container
		(
			color: Colors.white12,
			height: 210.0,
			width: 170.0,
			child: Container
			(
				color: Colors.black38,
				margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
				height: 190.0,
				width: 150.0,
				child: Card
				(
					color: Colors.transparent,
					child:   ClipRRect
					(
						child: !isImageUploaded ?
						Image.network
						(
							luitUser["image"].toString(),
							fit: BoxFit.cover,
							errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace)
							{
								return Image.asset("assets/images/logo.png", fit: BoxFit.contain,);
							}
						):
						Image.asset(base64Image.toString(), fit: BoxFit.cover,)
					),
				)
			)
		);
	}

	// Creating bottom sheet for selecting profile picture
	Widget bottomSheet()
	{
		return Container
		(
			child: Column
			(
				children: <Widget>
				[
					InkWell
					(
						onTap: ()
						{
							getCameraImage();
							Navigator.pop(context);
						},
						child: Padding
						(
							padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
							child: Row
							(
								crossAxisAlignment: CrossAxisAlignment.center,
								mainAxisAlignment: MainAxisAlignment.start,
								children: <Widget>
								[
									Icon(Icons.camera, color: Color.fromRGBO(34,34,34,1.0), size: 35,),
									Container
									(
										width: 250.0,
										child:  ListTile
										(
											title: Text('Camera',style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),),
											subtitle: Text("Click profile picture from camera.",style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),),
										),
									)
								],
							),
						)
					),
					InkWell
					(
						onTap: ()
						{
							getGalleryImage();
							Navigator.pop(context);
						},
						child: Padding
						(
							padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
							child: Row
							(
								crossAxisAlignment: CrossAxisAlignment.center,
								mainAxisAlignment: MainAxisAlignment.start,
								children: <Widget>
								[
									Icon(Icons.photo, color: Color.fromRGBO(34,34,34,1.0), size: 35,),
									Container
									(
										width: 260.0,
										child:  ListTile
										(
											title: Text('Gallery',style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),),
											subtitle: Text("Choose profile picture from gallery.",style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0))),
										),
									)
								],
							),
						)
					),
				],
			),
			decoration: BoxDecoration
			(
				color: Colors.white,
				borderRadius: BorderRadius.only
				(
					topLeft: const Radius.circular(10.0),
					topRight: const Radius.circular(10.0),
				),
			),
		);
	}

	//Show bottom sheet
	void _onButtonPressed()
	{
		showModalBottomSheet
		(
			context: context,
			builder: (builder)
			{
				return  Container
				(
					height: 190.0,
					color: Colors.transparent, //could change this to Color(0xFF737373),
					child: new Container
					(
						decoration: new BoxDecoration
						(
							color: Color.fromRGBO(34, 34, 34, 1.0),
							borderRadius: new BorderRadius.only
							(
								topLeft: const Radius.circular(10.0),
								topRight: const Radius.circular(10.0)
							)
						),
						child: bottomSheet()
					),
				);
			}
		);
	}

	Future chooseImageFromCamera() async
	{
    	pickedFile = await picker.getImage(source: ImageSource.camera);

    	setState(()
		{
      		if (pickedFile != null)
			{
				temp = pickedFile.path;
				// imageFile = picture.toString();
				isImageUploaded = true;
      		}
			else
			{
				print('No image selected.');
			}
    	});
  	}

	Future getGalleryImage() async
	{
    	final pickedFile = await picker.getImage(source: ImageSource.gallery);

    	setState(()
		{
      		if (pickedFile != null)
			{
				base64Image = pickedFile.path;
				print(pickedFile.path);
				isImageUploaded = true;
      		}
			else
			{
				Fluttertoast.showToast(msg: "No image choosen");
			}
    	});
		return pickedFile;
  	}

	Future getCameraImage() async
	{
    	final pickedFile = await picker.getImage(source: ImageSource.camera);

    	setState(()
		{
      		if (pickedFile != null)
			{
				base64Image = pickedFile.path;
				isImageUploaded = true;
      		}
			else
			{
				Fluttertoast.showToast(msg: "No image choosen");
			}
    	});
		return pickedFile;
  	}

	// update user details
	updateProfile() async
	{
		final form = formKey.currentState;
		form.save();

		luitUser["name"] = nameController.text;
		luitUser["email"] = emailController.text;
		luitUser["mobile"] = luitUser["login_phone_no"] = phoneController.text;
		luitUser["dob"] = dobController.text;
		luitUser["image64"] = base64Image;

		var response = await Server.updateUserProfie();

		print("CHALI");
		print(response);

		if (response["response"] == "success")
		{
			Navigator.pop(context);
			Fluttertoast.showToast(msg: "Profile Updated", backgroundColor: Colors.white, textColor: Colors.black);
			getUserProfile();

		}
		else
		{
			Fluttertoast.showToast(msg: "Please try again", backgroundColor: Colors.white, textColor: Colors.black);
		}
	}

	getUserProfile() async
	{
		await Server.userProfile(userId);
	}
}

class AlwaysDisabledFocusNode extends FocusNode
{
	@override
	bool get hasFocus => false;
}