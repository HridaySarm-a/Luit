import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:luit/Home%20Components/downloadPage.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/Home%20Components/menuBar.dart';
import 'package:luit/Home%20Components/myList.dart';
import 'package:luit/Home%20Components/searchPage.dart';
import 'package:luit/global.dart';
import 'package:luit/models/payment_model.dart';
import 'package:luit/models/profile_model.dart';
import 'package:luit/models/settings_model.dart';
import 'package:luit/network/payment_request.dart';
import 'package:luit/network/profile_request.dart';
import 'package:luit/network/settings_request.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({this.pageInd});

  final pageInd;

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  var currentBackPressTime;
  final Connectivity _connectivity = Connectivity();
  bool hasNetwork = true;
  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    SearchPage(),
    MyList(),
    DownloadPage(),
    MenuBar()
  ];

  Razorpay _razorpay;
  var logger = Logger();
  BuildContext dialogContext;
  int amount;
  var title;
  final SettingsRequest _settingRequest = SettingsRequest();

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _currentIndex = widget.pageInd != null ? widget.pageInd : 0;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    //settingsCheck();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    logger.d("The amount in option is $amount and title is $title");
    var options = {
      'key': "rzp_live_w5lknDA3gkDYMk",
      'amount': amount * 100,
      'name': "Pay to watch",
      'description': title.toString(),
      'external': {
        'wallets': ['paytm']
      }
    };

    /* var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': 2000,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    }; */

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
      logger.e(e);
    }
  }

  void settingsCheck() async {
    var id = luitUser["id"];
    final ProfileRequest _profileRequest = ProfileRequest();
    ProfileModel _profileModel = await _profileRequest.getProfileData(id);
    var boolValue = (_profileModel.openScreenPaymentAllow == true &&
        _profileModel.response == "success");
    if (boolValue) {
      logger.d("OPEN SESAME");
      SettingsModel _settingsModel = await _settingRequest.getSettingsModel();
      if (_settingsModel.response == "success") {
        for (final settings in _settingsModel.data) {
          if (settings.featuresName == "open_screen_payment") {
            if (settings.status == "1") {
              amount = int.parse(settings.value);
              title = settings.description;
              Future.delayed(
                Duration(milliseconds: 1),
                () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    dialogContext = context;
                    return WillPopScope(
                      onWillPop: () {
                        return Future.value(false);
                      },
                      child: SimpleDialog(
                        title: Text("Pay to watch"),
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              "${settings.description}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Lottie.asset("assets/payments.json",
                              repeat: true, height: 100, width: 100),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                print("Here I am");
                                openCheckout();
                              },
                              child: Text("Pay ${settings.value} ₹"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          }
        }
      }
    } else {
      logger.d("CLOSE SESAME");
    }

    //Future.delayed(Duration(minutes: 3), () => showDialog(context: context, builder: (_) => DialogPay()));
  }

  Future<void> initConnectivity() async {
    print("HELLOOO");
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      print("result " + result.toString());
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          print("yes");
          wifiEnabled = true;
          hasNetwork = true;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          wifiEnabled = false;
          hasNetwork = true;
        });
        break;
      case ConnectivityResult.none:
        setState(() {
          wifiEnabled = false;
          hasNetwork = false;
        });
        break;
      default:
        setState(() {
          wifiEnabled = false;
          hasNetwork = false;
        });
        break;
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;

      if (hasNetwork == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => _widgetOptions[_currentIndex]));
      } else {
        Fluttertoast.showToast(
            msg: "Lost network connection",
            backgroundColor: Colors.white,
            textColor: Colors.black);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DownloadPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search)),
            BottomNavigationBarItem(
                label: "Wishlist", icon: Icon(Icons.favorite_border)),
            BottomNavigationBarItem(
                label: "Download", icon: Icon(Icons.file_download)),
            BottomNavigationBarItem(
                label: "Account", icon: Icon(Icons.account_circle))
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedLabelStyle: TextStyle(color: Colors.white),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
        onWillPop: () {
          onWillPopScope(_currentIndex);
          return null;
        });
  }

  // Handle back press to exit
  Future<bool> onWillPopScope(_currentIndex) {
    if (widget.pageInd != 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => Home(reload: false)));
    } else {
      DateTime now = DateTime.now();

      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(milliseconds: 1000)) {
        currentBackPressTime = now;
        Fluttertoast.showToast(msg: "Press again to exit.");
        return Future.value(true);
      }
      return SystemNavigator.pop();
      // return Future.value(true);
    }

    return null;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    //Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId, toastLength: Toast.LENGTH_SHORT);
    logger.d("Amount: $amount");
    setPaymentRequest(response);
  }

  void setPaymentRequest(PaymentSuccessResponse response) async {
    PaymentRequest paymentRequest = PaymentRequest();
    logger.d(luitUser["id"]);
    PaymentModel paymentModel = await paymentRequest.getPayment(
        luitUser["id"], response.paymentId, amount);
    if (paymentModel.response == "failed") {
      Fluttertoast.showToast(
          msg: paymentModel.message, toastLength: Toast.LENGTH_SHORT);
    } else {
      Fluttertoast.showToast(
          msg: paymentModel.message, toastLength: Toast.LENGTH_SHORT);
    }
    Navigator.pop(dialogContext);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    //Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message, toastLength: Toast.LENGTH_SHORT);
    logger.e("Error: ${response.code.toString()}");
    Fluttertoast.showToast(
        msg: "Transaction Cancelled", toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName,
        toastLength: Toast.LENGTH_SHORT);
  }
}
