import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/LoadingComponents/loadingScreen.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';
import 'package:sms_retriever_api/sms_retriever_api.dart';



class LoginOTP extends StatefulWidget
{
	LoginOTP(this.firebaseOTPVerificationId);

	final firebaseOTPVerificationId;

	@override
	_LoginOTPState createState() => _LoginOTPState(this.firebaseOTPVerificationId);
}

class _LoginOTPState extends State<LoginOTP>
{
	_LoginOTPState(this.firebaseOTPVerificationId);

	final firebaseOTPVerificationId;

	final focus = FocusNode();
	final focus1 = FocusNode();
	final focus2 = FocusNode();
	final focus3 = FocusNode();
	final focus4 = FocusNode();
	final focus5 = FocusNode();

	var f1Controller = TextEditingController();
	var f2Controller = TextEditingController();
	var f3Controller = TextEditingController();
	var f4Controller = TextEditingController();
	var f5Controller = TextEditingController();
	var f6Controller = TextEditingController();

	int disabledCounter = 0;


	Timer _timer;
	int _start = 60;

	var otpEntered = "";

	@override
	void initState()
	{
		super.initState();
		startTimer();
		reteriveSms();
	}

	@override
	void dispose()
	{
		super.dispose();
	}

	reteriveSms() async
	{
		var otpCode = "";

		var _api = SmsRetrieverApi();

		_api.getAppSignature().then((signature)
		{

			return _api.startListening(onReceived: (value) async
			{
				otpCode = value.split(" ")[0];

				_api.stopListening();

				if(otpCode != null)
				{
					setState(()
					{
						f1Controller.text = otpCode[0];
						f2Controller.text = otpCode[1];
						f3Controller.text = otpCode[2];
						f4Controller.text = otpCode[3];
						f5Controller.text = otpCode[4];
						f6Controller.text = otpCode[5];
					});
				}

				UserCredential user = await firebaseVerifyOTP(firebaseOTPVerificationId, otpCode);

				if(user != null)
				{
					verifyOtp(otpEntered);
				}
				else
				{
					Fluttertoast.showToast(msg: "Invalid OTP");
				}
			});
		});
	}


	void startTimer()
	{
		_start = 70;
  		const oneSec = const Duration(seconds: 1);

  		_timer = new Timer.periodic(oneSec, (Timer timer)
		{
      		if (_start == 0)
			{
        		setState(()
				{
          			_timer.cancel();
        		});
      		}
			else
			{
        		setState(()
				{
          			_start--;
        		});
      		}
    	},);
	}

	@override
	Widget build(BuildContext context)
	{
		return Scaffold
		(
			resizeToAvoidBottomInset: false,
			backgroundColor: Color(int.parse("0xff02071a")),
			body: Container
			(
				padding: EdgeInsets.only(top: 55, left: 25, right: 25),
				child: Column
				(
					children:
					[
						Center
						(
							child: Image.asset("assets/images/luit-logo.png", scale: 1.0,),
						),
						SizedBox(height: 50,),
						Row
						(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children:
							[
								Text("Enter OTP"),
								Text(_start.toString() + " sec", style: TextStyle(color: Color(int.parse("0xffcf2450"))),)
							],
						),
						Container
						(
							padding: EdgeInsets.only(top:10),
							child: Row
							(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children:
								[
									Container
									(
										color: Colors.white,
										height: 50,
										width: 38,
										margin: EdgeInsets.only(right:8, bottom:10),
										child: TextFormField
										(
											style: TextStyle(fontSize: 18, color: Colors.black),
											controller: f1Controller,
											textInputAction: TextInputAction.next,
											textAlign: TextAlign.center,
											maxLength: 1,
											focusNode: focus,
											decoration: InputDecoration
											(
												counterText: ''
											),
											keyboardType: TextInputType.number,
											onChanged: (v)
											{
												editOtp();

												if (v.length == 0)
												{

												}
												else
												{
													FocusScope.of(context).requestFocus(focus1);
												}
											},
										),
									),
									Container
									(
										color: Colors.white,
										height: 50,
										width: 38,
										margin: EdgeInsets.only(right:8, bottom:10),
										child: TextFormField
										(
											style: TextStyle(fontSize: 18, color: Colors.black),
											controller: f2Controller,
											textInputAction: TextInputAction.next,
											focusNode: focus1,
											textAlign: TextAlign.center,
											maxLength: 1,
											decoration: InputDecoration
											(
												counterText: ''
											),
											keyboardType: TextInputType.number,
											onChanged: (v)
											{
												editOtp();

												if (v.length == 0)
												{
													FocusScope.of(context).requestFocus(focus);
												}
												else
												{
													FocusScope.of(context).requestFocus(focus2);
												}
											},
										),
									),
									Container
									(
										color: Colors.white,
										height: 50,
										width: 38,
										margin: EdgeInsets.only(right:8, bottom:10),
										child: TextFormField
										(
											style: TextStyle(fontSize: 18, color: Colors.black),
											controller: f3Controller,
											textInputAction: TextInputAction.next,
											focusNode: focus2,
											keyboardType: TextInputType.number,
											textAlign: TextAlign.center,
											maxLength: 1,
											decoration: InputDecoration
											(
												counterText: ''
											),
											onChanged: (v)
											{
												editOtp();

												if (v.length == 0)
												{
													FocusScope.of(context).requestFocus(focus1);
												}
												else
												{
													FocusScope.of(context).requestFocus(focus3);
												}
											}
										),
									),
									Container
									(
										color: Colors.white,
										height: 50,
										width: 38,
										margin: EdgeInsets.only(right:8, bottom:10),
										child: TextFormField
										(
											style: TextStyle(fontSize: 18, color: Colors.black),
											controller: f4Controller,
											textInputAction: TextInputAction.next,
											focusNode: focus3,
											keyboardType: TextInputType.number,
											textAlign: TextAlign.center,
											maxLength: 1,
											decoration: InputDecoration
											(
												counterText: ''
											),
											onChanged: (v)
											{
												editOtp();

												if (v.length == 0)
												{
													FocusScope.of(context).requestFocus(focus2);
												}
												else
												{
													FocusScope.of(context).requestFocus(focus4);
												}
											}
										),
									),
									Container
									(
										color: Colors.white,
										height: 50,
										width: 38,
										margin: EdgeInsets.only(right:8, bottom:10),
										child: TextFormField
										(
											style: TextStyle(fontSize: 18, color: Colors.black),
											controller: f5Controller,
											textInputAction: TextInputAction.next,
											focusNode: focus4,
											keyboardType: TextInputType.number,
											textAlign: TextAlign.center,
											maxLength: 1,
											decoration: InputDecoration
											(
												counterText: ''
											),
											onChanged: (v)
											{
												editOtp();

												if (v.length == 0)
												{
													FocusScope.of(context).requestFocus(focus3);
												}
												else
												{
													FocusScope.of(context).requestFocus(focus5);
												}
											}
										),
									),
									Container
									(
										color: Colors.white,
										height: 50,
										width: 38,
										margin: EdgeInsets.only(right:8, bottom:10),
										child: TextFormField
										(
											style: TextStyle(fontSize: 18, color: Colors.black),
											controller: f6Controller,
											textInputAction: TextInputAction.next,
											focusNode: focus5,
											keyboardType: TextInputType.number,
											textAlign: TextAlign.center,
											maxLength: 1,
											decoration: InputDecoration
											(
												counterText: ''
											),
											onChanged: (v)
											{
												editOtp();

												if (v.length == 0)
												{
													FocusScope.of(context).requestFocus(focus4);
												}
												else
												{

												}
											}
										),
									)
								],
							),
						),
						Row
						(
							mainAxisAlignment: MainAxisAlignment.center,
							children:
							[
								Text("Didn't receive the code? "),
								GestureDetector
								(
									child: Text("RESEND OTP", style:  TextStyle(color: _start != 0 ? Colors.grey : Colors.pink)),
									onTap: _start != 0 ? null :  () async
									{
										firebaseSendOtp(context, mobile, resend: true);
										startTimer();
									},
								)
							],
						),
						SizedBox(height: 75,),
						SizedBox
						(
							width: double.infinity,
							child: MaterialButton
							(
								disabledColor: Colors.grey,
								height: 50.0,
								color: Color(int.parse("0xffcf2450")),
								child: Text
								(
									"Verify OTP",
									style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.5),
								),
								onPressed: !isOtpEntered ? null : ()  async
								{

									editOtp();

									UserCredential user = await firebaseVerifyOTP(this.firebaseOTPVerificationId, otpEntered);

									if(user != null)
									{
										verifyOtp(otpEntered);
                      				}
									else
									{
                        				Fluttertoast.showToast(msg: "Invalid OTP");
                      				}
								}
							)
						),
					],
				),
			),
		);
	}

	verifyOtp(otpCode) async
	{
		var result = json.decode(await Server.loginWithOtp());

		if(result["response"] == "success")
		{
			userId = result["credential"][0]["id"];
			luitUser["id"] = userId;
			luitUser["name"] = null;
			luitUser["dob"] = null;
			luitUser["image"] = null;
			luitUser["email"] = null;
			luitUser["mobile"] = mobile;
			luitUser["joinedOn"] = "";

			setSharedPreference("luitUser", json.encode(luitUser));
			addBoolToSF();
			Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
		}
	}

	addBoolToSF() async
	{
  		await prefs.setBool("isLoggedIn", true);
	}

	editOtp()
	{
		var code = f1Controller.text + f2Controller.text + f3Controller.text + f4Controller.text + f5Controller.text + f6Controller.text;

		setState(()
		{
			isOtpEntered = code.length == 6 ? true : false;
			otpEntered = code;
		});
	}
}