import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionPage extends StatefulWidget {
  SubscriptionPage(this.item, this.isSinglePayment);

  final item;
  final isSinglePayment;

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState(this.item, this.isSinglePayment);
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  _SubscriptionPageState(this.item, this.isSinglePayment);

  final item;
  final isSinglePayment;

  Razorpay _razorpay;

  int _radioValue = 0;

  var title;
  var amount;
  var duration;

  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    if (item.length != 0) {
      title = item["title"];
      amount = item["amount"];
      duration = "364";
    }

    oneTimePayment = true;
    subscriptionMode = false;
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            appBar: appBar(context),
            body: isSinglePayment == false && subscriptionPlans.length == 0 ? displayText() : body(context),
            backgroundColor: Color(int.parse("0xff2B0D25")),
          ),
        ),
        onWillPop: () {
          onWillPopScope(context);
          return null;
        });
  }

  // pack press willpopscope event, should go to detailed page if single payment , else go back to subscription page
  onWillPopScope(context) {
    isSinglePayment == true
        ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContentDetails(item)))
        : Navigator.pop(context);
  }

  // shows when Luit doesn't have any subscription plans
  Widget displayText() {
    return Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Center(
            child: Text(
          "Enjoy watching Luit! It's Free. ",
          style: TextStyle(fontSize: 25),
        )));
  }

  // appbar
  Widget appBar(context) {
    return AppBar(
        centerTitle: true,
        title: Text("Subscribe"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            isSinglePayment == true
                ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContentDetails(item)))
                : Navigator.pop(context);
          },
        ),
        backgroundColor: Color(int.parse("0xff1E091E")));
  }

  // list of subscription plans
  Widget body(context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 25, right: 25),
      child: Column(
        children: [
          isSinglePayment == false && subscriptionPlans.length == 0
              ? SizedBox.shrink()
              : TextFormField(
                  decoration: InputDecoration(
                      hintText: "Have a code?",
                      suffixIcon: FlatButton(
                        child: Text("APPLY"),
                        onPressed: () {},
                      )),
                ),
          isSinglePayment == true
              ? SizedBox(
                  height: 25,
                )
              : SizedBox.shrink(),
          isSinglePayment == true
              ? Center(
                  child: Text(
                    "Pay and Watch",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23, letterSpacing: 1.5),
                  ),
                )
              : SizedBox.shrink(),
          isSinglePayment == true
              ? SizedBox(
                  height: 25,
                )
              : SizedBox.shrink(),
          isSinglePayment == true
              ? Container(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Card(
                      color: Color(int.parse("0xff4C1F47")),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            title: Center(
                              child: Text(
                                // subscriptionPlans[0]["title"].toString().toUpperCase(),
                                "INR " + item["amount"],
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                            trailing: Radio(
                              value: 0,
                              activeColor: Colors.white,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                          ),
                          Container(
                            color: Color(int.parse("0xff242225")),
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'Watch and Download the selected contents for 364 days.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, letterSpacing: 1.2),
                                )),
                          )
                        ],
                      ),
                    ),
                  ))
              : SizedBox.shrink(),
          subscriptionPlans.length == 0
              ? SizedBox.shrink()
              : SizedBox(
                  height: 35,
                ),
          subscriptionPlans.length == 0
              ? SizedBox.shrink()
              : isSinglePayment == true
                  ? Center(
                      child: Text(
                        "or",
                        style: TextStyle(color: Colors.yellow, fontSize: 18),
                      ),
                    )
                  : SizedBox.shrink(),
          subscriptionPlans.length == 0
              ? SizedBox.shrink()
              : SizedBox(
                  height: 20,
                ),
          subscriptionPlans.length == 0
              ? SizedBox.shrink()
              : Center(
                  child: Text(
                    "Select Subscription Pack",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23, letterSpacing: 1.5),
                  ),
                ),
          SizedBox(
            height: 20,
          ),
          subscriptionPlans.length == 0 ? SizedBox.shrink() : Column(children: this.createSubscriptionPacks(subscriptionPlans)),
          SizedBox(
            height: 25,
          ),
          isSinglePayment == false && subscriptionPlans.length == 0 || subscriptionPlans.length == null
              ? SizedBox.shrink()
              : OutlineButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openCheckout();
                  },
                  child: Stack(
                    children: <Widget>[
                      Align(alignment: Alignment.centerLeft, child: Icon(Icons.payment)),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            "PAY NOW",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ))
                    ],
                  ),
                  highlightedBorderColor: Colors.orange,
                  color: Colors.blue,
                  borderSide: new BorderSide(color: Colors.blue),
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))),
          SizedBox(
            height: 20,
          )
        ],
      ),
      // )
    );
  }

  List<Container> createSubscriptionPacks(data) {
    List<Container> packs = [];

    for (int i = 0; i < data.length; i++) {
      packs.add(Container(
          color: Color(int.parse("0xff4C1F47")),
          margin: EdgeInsets.only(bottom: 30),
          child: Column(children: [
            Container(
              child: ListTile(
                title: Center(
                  child: Text(
                    "INR " + data[i]["amount"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                trailing: Radio(
                  value: i + 1,
                  groupValue: _radioValue,
                  activeColor: Colors.white,
                  onChanged: _handleRadioValueChange,
                ),
              ),
            ),
            Container(
                color: Color(int.parse("0xff242225")),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      // text: 'Hello ',
                      children: <TextSpan>[
                        TextSpan(text: 'Watch and Download ', style: TextStyle(color: Colors.white, letterSpacing: 1.2)),
                        TextSpan(text: 'all contents ', style: TextStyle(color: Colors.yellow)),
                        TextSpan(text: data[i]["duration"] + " days ", style: TextStyle(color: Colors.white, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ))
          ])));
    }

    return packs;
  }

  successMessage(var amount, var referenceNumber) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => new GestureDetector(
              child: Container(
                color: Colors.white.withOpacity(0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    successTicket(context, amount, referenceNumber),
                    SizedBox(height: 10.0),
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        isSinglePayment == true
                            ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContentDetails(item)))
                            : Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ));
  }

  successTicket(context, amount, referenceNumber) {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat.Hms().format(now);

    return WillPopScope(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            elevation: 2.0,
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Thank You",
                    style: TextStyle(color: Colors.green, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  ListTile(
                    title: Text("Date", style: TextStyle(color: Colors.black)),
                    subtitle: Text(
                      DateTime.now().toString().split(" ")[0],
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: Text("Time: " + formattedTime, style: TextStyle(color: Colors.black)),
                  ),
                  luitUser["name"] == null
                      ? ListTile(
                          title: Text(
                            "Name",
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            luitUser["name"].toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: profilePic != null
                              ? Image.network(
                                  profilePic.toString(),
                                  scale: 1.7,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "assets/images/logo.png",
                                  scale: 1.7,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : SizedBox.shrink(),
                  ListTile(
                    title: Text(
                      "Amount",
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      "₹ " + amount,
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: Text(
                      referenceNumber,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async => false);
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      if (_radioValue == 0) {
        // print("its one time payment");
        oneTimePayment = true;
        subscriptionMode = false;
        title = item["title"];
        amount = item["amount"];
        duration = "364";
      } else {
        oneTimePayment = false;
        subscriptionMode = true;
        title = subscriptionPlans[_radioValue - 1]["title"];
        amount = subscriptionPlans[_radioValue - 1]["amount"];
        duration = subscriptionPlans[_radioValue - 1]["duration"];
      }
    });
  }

  // razor payment gateway
  void openCheckout() async {
    int cost = int.parse(amount);

    cost = cost * 100;
    // print(cost.toString());
    // print(title);
    // print(duration);

    var options = {
      'key': "rzp_live_w5lknDA3gkDYMk",
      'amount': cost,
      'name': title,
      'description': "Test Payment",
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
      // print("PAYMENT WAS SUCCESS");
    } catch (e) {
      debugPrint(e);
      // print("GOT EXCEPETION " + e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    referenceNumber = response.paymentId;
    // print(referenceNumber);

    Fluttertoast.showToast(msg: "Payment Success" + "-" + referenceNumber.toString());

    if (oneTimePayment == true) {
      paymentUpdation(response);
    } else {
      monthlySubscription(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Cancelled");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: ");
  }

  paymentUpdation(response) async {
    var contentType;
    var contentId = item["id"];

    switch (item["type"]) {
      case "movie":
        contentType = "1";
        break;
      case "music":
        contentType = "2";
        break;
      case "short_film":
        contentType = "3";
        break;
      case "webseries":
        contentType = "4";
        break;
    }

    var result = await Server.payForVideo(contentType, contentId, amount, referenceNumber);

    var temp = json.decode(result);

    if (temp["response"] == "success") {
      successMessage(amount, referenceNumber);
    } else {
      Fluttertoast.showToast(msg: "Already Paid: ");
    }
  }

  monthlySubscription(response) async {
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(Duration(days: int.parse(duration)));

    DateFormat formatter = DateFormat('yyyy-MM-dd');

    var startDateFormatted = formatter.format(startDate);
    var endDateFormatted = formatter.format(endDate);

    var result = await Server.monthlyPayment(duration, startDateFormatted, endDateFormatted, amount, referenceNumber);

    var temp = json.decode(result);

    if (temp["response"] == "success") {
      successMessage(amount, referenceNumber);
    } else {
      Fluttertoast.showToast(msg: "Already Paid: ");
    }
  }
}
