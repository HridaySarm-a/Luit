import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentRating.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/downloadVideos.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/shareTab.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/tabBar.dart';
import 'package:luit/Home%20Components/UI/subscriptionPage.dart';
import 'package:luit/Home%20Components/downloadPage.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewiePlayer.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/trailerVideoPlayer.dart';
import 'package:luit/global.dart';
import 'package:http/http.dart' as http;
import 'package:luit/models/view_model.dart';
import 'package:luit/models/views_success_model.dart';

class ContentDetails extends StatefulWidget {
  ContentDetails(this.item);

  final Map item;

  @override
  _ContentDetailsState createState() {
    return _ContentDetailsState(this.item);
  }
}

class _ContentDetailsState extends State<ContentDetails>
    with SingleTickerProviderStateMixin {
  _ContentDetailsState(this.item);

  final Map item;

  Icon _iconUp = Icon(Icons.keyboard_arrow_up);
  Icon _iconDown = Icon(Icons.keyboard_arrow_down);

  String temp;

  bool added = false;
  bool paymentStatus;
  bool singlePayment = true;
  bool iconExpanded = false;

  int rating = 0;

  Connectivity connectivity = new Connectivity();
  final _logger = Logger();
  var _isViewLoaded = false;
  var _totalView = 0;

  @override
  void initState() {
    print(item);
    super.initState();
    checkPaymentStatus();
    checkAddedToWishlist();
    displayWishlist();
    globalRating();
    _getViews();
    // checkNetworkMode();
    temp = item["description"];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(int.parse("0xff02071a")),
        body: SingleChildScrollView(
          child: Column(children: [
            // BACKGROUND IMAGE, POSTER AND ITEM DETAILS
            backGroundImage(context),
           // SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 20,left:8,right:8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PLAY BUTTON
                  item["video_url"] != ""
                      ? Container(
                    width: 180,
                    padding: EdgeInsets.only(left: 10),
                    child: OutlineButton(
                      textColor: Colors.white,
                      padding: EdgeInsets.only(left: 20),
                      borderSide: BorderSide(color: Colors.blue),
                      onPressed: () {
                        if (paymentStatus == false) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SubscriptionPage(
                                          item, singlePayment)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MyCustomPlayer(item)));
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 15),
                          Text(
                            "PLAY NOW",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  )
                      : SizedBox.shrink(),
                  SizedBox(width: 10,),
                  item["trailer_url"] != ""
                      ? Container(
                    width: 180,
                    padding: EdgeInsets.only(left: 10),
                    child: OutlineButton(
                      padding: EdgeInsets.only(left: 20),
                      borderSide: BorderSide(color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TrailerVideoPlayer(item)));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15),
                          Text(
                            "PREVIEW",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            // DESCRIPTION
            item["description"] != ""
                ? description(context)
                : SizedBox.shrink(),
            SizedBox(
              height: 10,
            ),
            //4 ICON BUTTONS
            iconButtons(context),
            SizedBox(height: 40),
            // MORE LIKE THIS AND INFO
            ContentPageTabBar(item)
          ]),
        ));
  }

  Widget backGroundImage(context) {
    return Stack(
      children: <Widget>[
        // BACKGROUND IMAGE
        Container(
            height: 410.0,
            width: 500.0,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.6],
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(100, 100, 200, 350));
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(item["poster"].toString(), fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace stackTrace) {
                return Image.asset("assets/images/logo.png");
              }),
            )),
        // BACK ARROW BUTTON
        Positioned(
          top: 30.0,
          left: 4.0,
          child: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
        ),
        Positioned(
            top: 180,
            left: 20,
            //right: 0,
           // bottom: 0,
            child: Container(
                color: Colors.transparent,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      itemPoster(context),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // VIDEO TITLE
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: Text(
                              item["title"].toString() == "null"
                                  ? item["movie_title"].toString()
                                  : item["title"].toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700),
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          // RATING
                          SizedBox(height: 15),
                          ratingInfo(context),





                          // TRAILER BUTTON

                        ],
                      )
                    ])))
      ],
    );
  }

  Widget itemPoster(context) {
    var imageWidth = MediaQuery.of(context).size.width / 3;
    var imageHeight = MediaQuery.of(context).size.height / 4;

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: imageWidth,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item["thumbnail"].toString(), fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace stackTrace) {
                return Image.asset("assets/images/logo.png");
              }),
            )),


      ],
    );
  }

  Widget ratingInfo(context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // RATING AND HOW MUCH RATED
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
               children:[
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 5),
                    child: Text(
                      "Rating",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(),
                      child: ratingIcons()),
                ],
              ),
              // SizedBox(height: 5),
              // Text(
              //   rating.toString(),
              //   style: TextStyle(color: Colors.greenAccent[300], fontSize: 20),
              // ),

                 _isViewLoaded == true
                     ? _totalView != 0
                     ? Padding(
                   padding: const EdgeInsets.only(left: 70, top: 12),
                   child: Column(
                     children: [
                       Text(
                         "Total Views",
                         style: TextStyle(color: Colors.white),
                       ),
                       SizedBox(height: 10),
                       Text(
                         _totalView.toString(),
                         style: TextStyle(color: Colors.white),
                       ),
                     ],
                   ),
                 )
                     : SizedBox()
                     : CircularProgressIndicator(),
      ]),

              SizedBox(height: 15),
              paymentStatus != null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Watch for",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    !paymentStatus
                        ? "INR " + item["amount"].toString() + ".00"
                        : "Free",
                    style: TextStyle(color: Colors.yellowAccent, fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              )
                  : Container(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 1.4,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),


          //SizedBox(width: 40),

          SizedBox(width: 40),

        ],
      ),
    ]),
    );
  }

  ratingIcons() {
    List<Row> icons = [];

    // var icon = double.parse(item["ratings"]);

    var icon = rating;

    var temp = icon.round();

    for (int index = 0; index < temp; index++) {
      icons.add(Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.greenAccent,
          ),
        ],
      ));
    }

    return Row(children: icons);
  }

  Widget description(context) {
    double textSize = getFontSize(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            iconExpanded == true
                ? item["description"]
                : temp.length < 100
                    ? item["description"]
                    : temp.substring(0, 100),
            style: TextStyle(color: Colors.white, fontSize: textSize / 26),
          ),
        ),
        temp.length < 25
            ? SizedBox.shrink()
            : IconButton(
                icon: iconExpanded ? _iconUp : _iconDown,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    iconExpanded = !iconExpanded;
                  });
                })
      ],
    );
  }

  Widget iconButtons(context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              IconButton(
                icon: Icon(added == true ? Icons.done : Icons.add),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    !added ? addToWishList() : deleteFromWishList();
                    added = !added;
                  });
                },
              ),
              Text(added == true ? "Added" : "My List",
                  style: TextStyle(color: Colors.white, fontSize: 15))
            ],
          ),
        ),
        Expanded(
          child: SharePage(item),
        ),
        Expanded(
          child: ContentRating(item, this.updateRating),
        ),
        item["video_url"] != ""
            ? Expanded(
                child: paymentStatus == true
                    ? Container(
                        height: 100, width: 100, child: MyHomePage(item))
                    : Column(
                        children: [
                          IconButton(
                              icon: Icon(Icons.file_download),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SubscriptionPage(
                                            item, singlePayment)));
                              }),
                          Text("Download")
                        ],
                      ))
            : SizedBox.shrink(),
      ],
    );
  }

  updateRating(rating) {
    print("updated rating" + rating.toString());
    setState(() {
      item["ratings"] = rating.toString();
      ratingIcons();
    });
  }

  // overall rating of the item, every time user rates the content, this api is called to display the rating.
  globalRating() async {
    var contentId = item["id"];
    var contentType;

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

    var temp = await Server.overallRating(contentId, contentType);

    var result = json.decode(temp);

    if (result["response"] == "success") {
      setState(() {
        item["ratings"] = result["data"].toString();
        rating = result["data"];
      });
    } else {
      setState(() {
        rating = 0;
      });
    }
  }

  // check if payment was done already.
  checkPaymentStatus() async {
    var contentType;
    var contentId = item["id"];

    if (item["amount"] != "0") {
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

      var response = await Server.checkPaymentStatus(contentType, contentId);

      var result = json.decode(response);

      if (result["payment_status"] == 1) {
        setState(() {
          paymentStatus = true;
        });
      } else {
        setState(() {
          paymentStatus = false;
        });
      }
    } else {
      setState(() {
        paymentStatus = true;
      });
    }
  }

  // api to add to wishlist.
  addToWishList() async {
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

    var response = await Server.addToWishlist(contentType, contentId);

    var result = json.decode(response);

    print(result);

    if (result["response"] == "success") {
      setState(() {
        added = true;
      });
    } else if (result["message"] == "Video Already in Wishlist") {
      setState(() {
        added = true;
      });
    } else {
      setState(() {
        added = false;
      });
    }
  }

  // api to remove from wishlist.
  deleteFromWishList() async {
    var listId = item["listId"];

    var response = await Server.deleteWishlist(listId);

    var temp = json.decode(response);

    if (temp["message"] == "success") {
      setState(() {
        added = false;
      });
    } else {
      setState(() {
        added = false;
      });
    }
  }

  // api to check if item already added to wishlist.
  checkAddedToWishlist() async {
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
      case "short_film":
        contentType = "4";
        break;
    }

    var response = await Server.wishlistIsPresent(contentType, contentId);

    var result = json.decode(response);

    if (result["response"] == "failed") {
      setState(() {
        added = false;
      });
    } else {
      setState(() {
        added = true;
      });
    }
  }

  // display wishlist data.
  displayWishlist() async {
    for (int i = 0; i < wishList.length; i++) {
      if (wishList[i]["id"] == item["id"] &&
          wishList[i]["type"] == item["type"]) {
        item["listId"] = wishList[i]["listId"];
      }
    }
  }

  checkNetworkMode() {
    // Used to check connection status of use device
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        setState(() {
          wifiEnabled = true;
        });
      } else if (result == ConnectivityResult.mobile) {
        setState(() {
          wifiEnabled = false;
        });
      } else if (result == ConnectivityResult.none) {
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => DownloadPage());
        Navigator.of(context).push(router);
      }
    });
  }

  _getViews() async {
    setState(() {
      _logger.d("I am here");
      _isViewLoaded = false;
    });

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
    _logger.d(contentType+"   "+contentId);
    var _body = {
      "user_id": luitUser["id"],
      "content_type": contentType,
      "content_id": contentId,
    };
    var _response = await http.post(
      Uri.parse("https://release.luit.co.in/api/movie-view-api"),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: _body,
    );
    _logger.d(_response.body);
    var _result = viewsModelFromJson(_response.body);
    if (_result.response == "success") {
      var _success = viewsSuccessModelFromJson(_response.body);
      setState(() {
        _totalView = _success.total;
        _isViewLoaded = true;
      });
    } else {
      setState(() {
        _totalView = 0;
        _isViewLoaded = true;
      });
    }
  }
}
