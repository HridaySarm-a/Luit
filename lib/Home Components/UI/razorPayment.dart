import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPyamentPage extends StatefulWidget {
  final Map item;
  final title;
  final cost;
  final days;

  RazorPyamentPage(this.item, this.title, this.cost, this.days);

  @override
  _RazorPyamentPageState createState() => _RazorPyamentPageState(this.item, this.title, this.cost, this.days);
}

class _RazorPyamentPageState extends State<RazorPyamentPage> with SingleTickerProviderStateMixin {
  final Map item;
  final title;
  final cost;
  final days;

  _RazorPyamentPageState(this.item, this.title, this.cost, this.days);

  AnimationController _controller;
  Razorpay _razorpay;

  @override
  void initState() {
    // print(days);
    super.initState();
    _controller = AnimationController(vsync: this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    if (days == null) {
      oneTimePayment = true;
      subscriptionMode = false;
    } else {
      subscriptionMode = true;
      oneTimePayment = false;
    }

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _razorpay.clear(); // Removes all listeners
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    referenceNumber = response.paymentId;
    // print(referenceNumber);

    if (oneTimePayment == true) {
      paymentUpdation(response);
    } else if (subscriptionMode == true) {
      monthlySubscription(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse("0xff02071a")),
      appBar: appBar(context),
      body: body(context),
    );
  }

  // APPBAR
  Widget appBar(context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContentDetails(item)));
          }),
      centerTitle: true,
      title: Text("Razor Payment"),
    );
  }

  Widget body(context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(height: 20.0),
          Card(
            child: razorLogoContainer(),
          ),
          SizedBox(height: 10.0),
          paymentDetailsCard(),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: payButtonRow(context),
          )
        ],
      ),
    );
  }

  Widget razorLogoContainer() {
    return Container(
      height: 250,
      width: 250,
      color: Color(int.parse("0xff02071a")),
      child: Image.asset("assets/images/razorpay.png"),
    );
  }

  Widget paymentDetailsCard() {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color(int.parse("0xf02071a")).withOpacity(0.4), borderRadius: BorderRadius.circular(10.0)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 20.0),
              decoration: new BoxDecoration(border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))),
              child: Icon(
                Icons.payment,
                color: Colors.white,
                size: 20.0,
              ),
            ),
            trailing: Column(children: <Widget>[
              Text("Amount: "),
              SizedBox(
                height: 10,
              ),
              Text("INR " + cost)
            ]),
          ),
        ));
  }

  Widget payButtonRow(context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            onPressed: () {
              openCheckout();
              // successTicket(context);
            },
            color: Color.fromRGBO(72, 163, 198, 1.0),
            child: Text(
              "CONTINUE PAY",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  successTicket(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Thank You",
              style: TextStyle(color: Colors.green, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15)),
            content: Container(
              height: 300,
              width: 1000,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Date",
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      "Jan 2, 2021",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    trailing: Text(
                      "Time : ",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                  // SizedBox(height: 5,),
                  ListTile(
                      title: Text(
                        "John",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      subtitle: Text(
                        "john@gmail.com",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      trailing: Container(
                        height: 30,
                        width: 30,
                        child: Image.asset(
                          "assets/images/logo.png",
                          scale: 0.5,
                        ),
                      )),
                  // SizedBox(height: 5,),
                  ListTile(
                    title: Text(
                      "Amount",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    subtitle: Text(
                      "Rs 43",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    trailing: Text(
                      "Completed",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                  Text("Payment Id: Cdidik23ytpt", style: TextStyle(color: Colors.black, fontSize: 15))
                ],
              ),
            ),
          );
        });
  }

  void openCheckout() async {
    int amount = int.parse(cost);

    amount = amount * 100;

    var options = {
      'key': "rzp_test_EWXRJuLt7G1VMb",
      'amount': amount,
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

    var result = await Server.payForVideo(contentType, contentId, cost, referenceNumber);

    var temp = json.decode(result);

    if (temp["response"] == "success") {
      Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId);
      successTicket(context);
    } else {
      Fluttertoast.showToast(msg: "Already Paid: ");
    }
  }

  monthlySubscription(response) async {
    // print("MONTHLY SUBSCRIPTION");
    // print("DAYS" + days.toString());

    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(Duration(days: int.parse(days)));

    DateFormat formatter = DateFormat('yyyy-MM-dd');

    var startDateFormatted = formatter.format(startDate);
    var endDateFormatted = formatter.format(endDate);

    // print(startDateFormatted);
    // print(endDateFormatted);

    var result = await Server.monthlyPayment(days, startDateFormatted, endDateFormatted, cost, referenceNumber);
    // print(result);

    // print("tadddaaaaaaaaaa");

    var temp = json.decode(result);

    // print(temp);

    if (temp["response"] == "success") {
      Fluttertoast.showToast(msg: "SUCCESS: " + referenceNumber);
    } else {
      Fluttertoast.showToast(msg: "Already Paid: ");
    }
  }
}
