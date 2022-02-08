import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/LoadingComponents/loadingScreen.dart';
import 'package:luit/global.dart';
import 'package:image_picker/image_picker.dart';


class Register extends StatefulWidget
{
	@override
  	State<StatefulWidget> createState()
	{
		return RegisterState();
  	}
}

class RegisterState extends State<Register>
{

	final formKey =  GlobalKey<FormState>();
	final scaffoldKey =  GlobalKey<ScaffoldState>();

	final TextEditingController nameField = TextEditingController();
	final TextEditingController emailField = TextEditingController();
	final TextEditingController phoneField = TextEditingController();
	final TextEditingController passwordField = TextEditingController();
	final TextEditingController confirmPasswordField = TextEditingController();
	final TextEditingController dobField = TextEditingController();
	String base64Image;

	DateTime selectedDate = DateTime.now();
	String pickedDate;

	// File _image;
	final picker = ImagePicker();

	Future getImage() async
	{
    	final pickedFile = await picker.getImage(source: ImageSource.gallery);

    	setState(()
		{
      		if (pickedFile != null)
			{
				base64Image = pickedFile.path;
      		}
			else
			{
				Fluttertoast.showToast(msg: 'No image selected.', backgroundColor: Colors.white, textColor: Colors.black);
			}
    	});
		return pickedFile;
  	}

	Widget build(BuildContext context)
	{
		return Scaffold
		(
			body: signUpForm(context),
		);
	}

	Widget signUpForm(context)
	{
		return Form
		(
			onWillPop: () async
			{
				return true;
			},
			key: formKey,
			child: Container
			(
				color: Color(int.parse("0xff02071a")),
				alignment: Alignment.center,
				child: Center
				(
					child:  ListView
					(
						children: <Widget>
						[
							// StickyHeader
							// (
							// 	overlapHeaders: false,
								// header: 
								signUpPageStickyHeader(context),
								// content:
								 stickyHeaderContent(context),
							// ),
						],
					),
				),
			),
		);
	}

	Widget signUpPageStickyHeader(context)
	{
		var fontSize = getFontSize(context);

		return Stack
		(
			children: <Widget>
			[
				IconButton
				(
					icon: Icon
					(
						Icons.arrow_back,
						size: 25,
						color: Colors.white,
					),
					onPressed: ()
					{
						// Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
					}
				),
				Row
				(
					crossAxisAlignment: CrossAxisAlignment.center,
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>
					[
						Padding
						(
							padding: EdgeInsets.only(top: 35.0, left: 20.0, bottom: 5),
							child: Container
							(
								child: Text
								(
									"Register To Luit",
									textAlign: TextAlign.left,
									style: TextStyle
									(
										color: Colors.white,
										fontSize: fontSize / 15,
										fontWeight:FontWeight.bold,
										fontFamily: "arial"
									),
								),
							)
						)
					]
				),
			],
		);
	}

	Widget stickyHeaderContent(context)
	{
		var fontSize = getFontSize(context);

		return  Column
		(
			children: <Widget>
			[
				// signUpHeading(),
				Container
				(
					padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 20),
					child: Column
					(
						children: <Widget>
						[
							// NAME
							TextFormField
							(
								textCapitalization: TextCapitalization.words,
								keyboardType: TextInputType.text,
								controller: nameField,
								decoration: InputDecoration
								(
									hintText: 'Full Name',
									hintStyle: TextStyle(color: Colors.white),
									enabledBorder: UnderlineInputBorder
									(
										borderSide:  BorderSide(color: Colors.white)
									)
								),
								style: TextStyle
								(
									fontSize: 13,
									color: Colors.white
								),
								validator: (val)
								{
									if(val.length == 0)
									{
										return 'Name cannot be empty';
									}
									if(val.length < 2)
									{
										return 'Name too short';
									}
									return null;
								},
								onSaved: (val) => nameField.text = val,
							),
							// EMAIL
							TextFormField
							(
								keyboardType: TextInputType.emailAddress,
								controller: emailField,
								decoration: InputDecoration
								(
									hintText: 'Email',
									hintStyle: TextStyle(color: Colors.white),
									enabledBorder: UnderlineInputBorder
									(
										borderSide:  BorderSide(color: Colors.white)
									)
								),
								style: TextStyle
								(
									fontSize: 13,
									color: Colors.white
								),
								validator: (val)
								{
									if (val.length == 0)
									{
										return 'Email can not be empty';
									}
									else
									{
										if (!val.contains('@'))
										{
											return 'Invalid Email';
										}
										else
										{
											return null;
										}
									}
								},
								onSaved: (val) => emailField.text = val,
							),
							// MOBILE NUMBER
							TextFormField
							(
								keyboardType: TextInputType.number,
								controller: phoneField,
								maxLength: 10,
								decoration: InputDecoration
								(
									hintText: 'Mobile Number',
									hintStyle: TextStyle(color: Colors.white),
									enabledBorder: UnderlineInputBorder
									(
										borderSide:  BorderSide(color: Colors.white)
									)
								),
								style: TextStyle
								(
									fontSize: 13,
									color: Colors.white
								),
								validator: (val)
								{
									if (val.length == 0)
									{
										return 'Phone can not be empty';
									}
									return null;
								},
								onSaved: (val) => phoneField.text = val,
							),
							// PASSWORD
							TextFormField
							(
								obscureText: true,
								keyboardType: TextInputType.text,
								controller: passwordField,
								decoration: InputDecoration
								(
									hintText: 'Password',
									hintStyle: TextStyle(color: Colors.white),
									enabledBorder: UnderlineInputBorder
									(
										borderSide:  BorderSide(color: Colors.white)
									)
								),
								style: TextStyle
								(
									fontSize: 13,
									color: Colors.white
								),
								validator: (val)
								{
									if (val.length < 6)
									{
										if (val.length == 0)
										{
											return 'Password can not be empty';
										}
										else
										{
											return 'Password too short';
										}
									}
									else
									{
										return null;
									}
								},
								onSaved: (val) => passwordField.text = val,
							),
							// CONFIRM PASSWORD
							TextFormField
							(
								obscureText: true,
								controller: confirmPasswordField,
								decoration: InputDecoration
								(
									hintText: 'Confirm Password',
									hintStyle: TextStyle(color: Colors.white),
									enabledBorder: UnderlineInputBorder
									(
										borderSide:  BorderSide(color: Colors.white)
									),
								),
								style: TextStyle
								(
									fontSize: 13,
									color: Colors.white
								),
								validator: (val)
								{
									// if (val.length < 6)
									// {
									// 	if (val.length == 0)
									// 	{
									// 		return 'Confirm Password can not be empty';
									// 	}
									// 	// else
									// 	// {
									// 	// 	return null;
									// 	// }
									// }
									// else
									// {
										if(passwordField.text == val)
										{
											return null;
										}
										else
										{
											return 'Password & Confirm Password does not match';
										}
									// }
								},
								onSaved: (val) => confirmPasswordField.text = val
							),
							// DATE OF BIRTH
							TextFormField
							(
								controller: dobField,
								decoration: InputDecoration
								(
									hintText: "Date of Birth",
									hintStyle: TextStyle(color: Colors.white),
									enabledBorder: UnderlineInputBorder
									(
										borderSide:  BorderSide(color: Colors.white)
									),
								),
								onTap: () async
								{
									// print("date");

									DateTime date = DateTime(1900);
									FocusScope.of(context).requestFocus(new FocusNode());

									date = await showDatePicker
									(
										context: context,
										initialDate:DateTime.now(),
										firstDate:DateTime(1900),
										lastDate: DateTime(2100),
										builder: (BuildContext context, Widget child) 
										{
											return Theme
											(
												data: ThemeData.light().copyWith
												(
													primaryColor: Colors.pink,
													accentColor: Colors.pink,
													colorScheme: ColorScheme.light(primary: Colors.pink),
													buttonTheme: ButtonThemeData
													(
														textTheme: ButtonTextTheme.primary
													),
												),
												child: child,
											);
										}
									);

									var formattedDate = "${date.year}-${date.month}-${date.day}";
									// print(formattedDate);
                					dobField.text = formattedDate;
								},
								validator: (val)
								{
									if(val.length == 0)
									{
										return "Date of birth cannot be empty";
									}
									else
									{
										return null;
									}
								},
								onSaved: (val) => dobField.text = val
							),
							SizedBox(height: 5,),
							OutlineButton
							(
								color: Colors.blue,
								onPressed: ()
								{
									getImage();
								},
								child: Text( "Upload File")
							),
							SizedBox(height: 20.0),
							RichText
							(
								textAlign: TextAlign.center,
								text: TextSpan
								(
									text: 'By registering you agree to',
									style: TextStyle(color: Colors.white, fontSize: fontSize / 28), /*defining default style is optional */
									children: <TextSpan>
									[
										TextSpan(
											text: ' Terms & Conditions',
											style: TextStyle(color: Color(int.parse("0xffcf2350"))),
										),
										TextSpan(
											text: ' and',
											style: TextStyle(color: Colors.white)),
										TextSpan(
											text: ' Privacy Policy',
											style: TextStyle(color: Color(int.parse("0xffcf2350")))),
										TextSpan(
											text: ' of Luit',
											style: TextStyle(color: Colors.white)),
									],
								),
							),
							Padding(padding: EdgeInsets.only(bottom: 25)),
							SizedBox
							(
								width: double.infinity,
								child: MaterialButton
								(
									height: 50.0,
									color: Color(int.parse("0xffcf2350")),
									child: Text
									(
										"REGISTER",
										style: TextStyle(color: Colors.white, fontSize: fontSize / 25, letterSpacing: 1.2),
									),
									onPressed: () async
									{
										// print("got it");
										var response = await  _signUp(nameField.text, emailField.text, passwordField.text, phoneField.text, dobField.text);

										var temp = json.decode(response);

										if(temp["response"] == "success")
										{
											email = emailField.text;
											Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
										}
										else
										{
											Fluttertoast.showToast(msg: temp["message"]);
										}
									}
								)
							),
							Padding(padding: EdgeInsets.only(bottom: 20.0)),
							InkWell
							(
								child: RichText
								(
									textAlign: TextAlign.center,
									text: TextSpan
									(
										text: 'Already have an account?',
										style: TextStyle(color: Colors.white, fontSize: fontSize / 25), /*defining default style is optional */
										children: <TextSpan>
										[
											TextSpan
											(
												text: ' Sign In', style: TextStyle(color: Color(int.parse("0xffcf2350")))
											),
										],
									),
								),
								onTap: ()
								{
									// var router = new MaterialPageRoute(builder: (BuildContext context) => Login());
									// Navigator.of(context).push(router);
								},
							),
							Padding(padding: EdgeInsets.only(bottom: 20.0)),
						],
					)
				)
			]
		);
	}

	// _selectDate() async
	// {
    // 	final DateTime picked = await showDatePicker
	// 	(
    //     	context: context,
    //     	initialDate: selectedDate,
    //     	firstDate: DateTime(2015, 8),
    //     	lastDate: DateTime(2101)
	// 	);
	// 	if (picked != null && picked != selectedDate)
	// 	setState(()
	// 	{
	// 		selectedDate = picked;
	// 	});
  	// }



	Future  _signUp(var name, var email, var password, var mobile, var dob)async
	{
		final form = formKey.currentState;
		form.save();

		if (form.validate() == true)
		{
			// print("success");
			// var response = await Server.registration(name, email, password, mobile, dob, base64Image);

			// return response;
		}
	}
}