import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/seriesDetailedPage.dart';
import 'package:luit/Home%20Components/bottomNavigationBar.dart';
import 'package:luit/Home%20Components/gridView.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/Menu%20Bar/VideoPlayer/chewiePlayer.dart';
import 'package:luit/global.dart';
import 'package:luit/utilities/popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({this.reload = true});

  bool reload = true;

  @override
  State<StatefulWidget> createState() {
    return HomeState(this.reload);
  }
}

class HomeState extends State<Home> {
  HomeState(this.reload);

  bool reload = true;

  GlobalKey _keyRed = GlobalKey();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  SwiperController swiperController;

  String heading = "";
  String title;

  int sliderPosition = 0;
  int pageIndex = 0;
  int selected = 0;

  bool shimmerState = true;
  bool shared = false;
  bool added = false;
  bool serverError = false;

  String isAdded = "0";
  String messageTitle = "Empty";
  String notificationAlert = "alert";
  String messageDescription = "";

  List lastPlayedVideos = [];
  List sliderList = [];
  List homeSlider = [];
  List moviesSlider = [];
  List musicSlider = [];
  List shortFilmSlider = [];

  //INIT STATE
  @override
  void initState() {
    super.initState();
    getSubscriptionPlans();
    firebaseMessaging();
    handleStartUpLogic();
    getSlider(0);
    if (this.reload) {
      fetchHomeApi();
    } else {
      this.shimmerState = true;
    }
    allVideos = [];
  }

  firebaseMessaging() async {
    print("HELLOOO");
    await _firebaseMessaging.subscribeToTopic('weather');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      var itemId;
      var itemType;
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      itemId = message.data["title"];
      itemType = message.data["item_category"];
      messageTitle = message.data["title"];
      messageDescription = message.data["description"];
      notificationAlert = "Application opened from Notification";

      //print(message["data"]);

      for (int i = 0; i < allVideos.length; i++) {
        print(message);
        if (allVideos[i]["type"] == itemType && allVideos[i]["id"] == itemId) {
          print("CLICKED");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ContentDetails(allVideos[i])));
          break;
        }
      }
    });
    /* _firebaseMessaging.configure(
        // The onMessage function triggers when the notification is received while we are running the app.
        onMessage: (message) async {
      print("FLUTTER_NOTIFICATION_CLICK");

      // setState(()
      // {
      // 	messageTitle = message["notification"]["title"];
      // 	messageDescription = message["notification"]["description"];
      // 	notificationAlert = "New Notification Alert";
      // });
    },
        // The onResume function triggers when we receive the notification alert in the device notification bar and opens the app through the push notification itself. In this case, the app can be running in the background or not running at all.
        onResume: (message) async {
      print("onLaunch: $message");

      var temp = message;
      var itemId;
      var itemType;

      messageTitle = message["data"]["title"];
      itemId = message["data"]["item_id"];
      itemType = message["data"]["item_category"];
      messageDescription = message["notification"]["description"];
      notificationAlert = "Application opened from Notification";

      print(message["data"]);

      for (int i = 0; i < allVideos.length; i++) {
        print(message);
        if (allVideos[i]["type"] == itemType && allVideos[i]["id"] == itemId) {
          print("CLICKED");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ContentDetails(allVideos[i])));
          break;
        }
      }
    }, onLaunch: (Map<String, dynamic>
                message) async // Called when app is terminated
            {
      print("onLaunch: $message");

      var data = message["data"];

      print(data);

      // Navigator.pushNamed(context, "details");
    }); */
  }

  Future handleStartUpLogic() async {
    // call handle dynamic links
    await dynamicLinkService.handleDynamicLinks();
  }

  // SUBSCRIPTION  PLANS
  getSubscriptionPlans() async {
    await Server.fetchSubscriptionPlans();
  }

  fetchHomeApi() async {
    Server.displayWishlist();
    getMovies();
    getMoviesByArtist();
    getMusicByArtist();
    getMoviesByLanguages();
    getMusic();
    getShortFilms();
    Future.delayed(Duration(seconds: 5), () => fetchLastPlayedVideos());
  }

  fetchMovies() async {
    getNewReleasedMovies();
    getMoviesByLanguages();

    this.setState(() {
      shimmerState = true;
    });
  }

  fetchSeries() async {
    getSeries();
  }

  fetchMusic() async {
    getMusic();
    getNewReleasedMusic();
    getMusicByLanguage();
  }

  fetchShortFilm() async {
    getShortFilms();
    getNewReleasedShortFilms();
    getShortFilmByLanguages();
  }

  fetchLastPlayedVideos() async {
    try {
      if (prefs.containsKey("userLastPlayedVideos")) {
        userVideos = json.decode(prefs.getString("userLastPlayedVideos"));

        lastPlayedVideos = [];

        for (int i = 0; i < userVideos.length; i++) {
          var videoId = userVideos[i]["id"];
          var videoType = userVideos[i]["type"];
          var resumeAt = userVideos[i]["resumeAt"];

          for (int i = 0; i < allVideos.length; i++) {
            if (allVideos[i]["id"] == videoId &&
                allVideos[i]["type"] == videoType) {
              var data = allVideos[i];
              data["resumeAt"] = resumeAt;

              lastPlayedVideos.add(data);
              break;
            }
          }
        }

        setState(() {});

        return imageTile(lastPlayedVideos);
      }
    } catch (e) {
      // print(e);
    }
  }

  //REFRESH THE HOME PAGE
  Future refreshList() async {
    refreshKey.currentState?.show();
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      shimmerState = false;
      fetchHomeApi();
    });
  }

  List tabs = ["Home", "Movies", "Music", "Kids"];

  List shape = [Icon(Icons.share)];

  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: SafeArea(
        child: shimmerState == false ? shimmer(300) : slider(context),
        bottom: true,
        top: false,
      ),
      onRefresh: refreshList,
      color: Colors.blue,
      backgroundColor: Colors.white,
    );
  }

  Widget serverErrorDisplay() {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(
        top: 250,
        left: 10,
        right: 10,
      ),
      child: Center(
          child: Column(
        children: [
          Icon(
            Icons.warning,
            size: 50,
          ),
          Text(
            "We encountered an error, try again later",
            style: TextStyle(fontSize: 25),
          ),
        ],
      )),
    ));
  }

  //SHIMMER
  Widget shimmer(width) {
    return SingleChildScrollView(
        child: Column(
            key: _keyRed,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          bannerShimmer(width),
          headingTextShimmer(),
          videoImageShimmer(width),
          // circularAvatar(actors),
          headingTextShimmer(),
          videoImageShimmer(width),
          // circularAvatar(actors),
          headingTextShimmer(),
          videoImageShimmer(width),
          headingTextShimmer(),
          videoImageShimmer(width),
        ]));
  }

  // BANNER SHIMMER
  Widget bannerShimmer(width) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: SizedBox(
                child: Shimmer.fromColors(
                  baseColor: Color.fromRGBO(45, 45, 45, 1.0),
                  highlightColor: Color.fromRGBO(50, 50, 50, 1.0),
                  child: Card(
                    elevation: 0.0,
                    color: Color.fromRGBO(45, 45, 45, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: SizedBox(
                      width: 1000,
                      height: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //HEADING SHIMMER
  Widget headingTextShimmer() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 8.0, 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: SizedBox(
                    child: Shimmer.fromColors(
                      baseColor: Color.fromRGBO(45, 45, 45, 1.0),
                      highlightColor: Color.fromRGBO(50, 50, 50, 1.0),
                      child: Card(
                        elevation: 0.0,
                        color: Color.fromRGBO(45, 45, 45, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(0),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: SizedBox(
                          width: 150,
                          height: 8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //IMAGE SHIMMER
  Widget videoImageShimmer(width) {
    return SizedBox.fromSize(
        size: const Size.fromHeight(180.0),
        child: ListView.builder(
            itemCount: 10,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            itemBuilder: (BuildContext context, int position) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: SizedBox(
                            child: Shimmer.fromColors(
                              baseColor: Color.fromRGBO(45, 45, 45, 1.0),
                              highlightColor: Color.fromRGBO(50, 50, 50, 1.0),
                              child: Card(
                                elevation: 0.0,
                                color: Color.fromRGBO(45, 45, 45, 1.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: SizedBox(
                                  width: 100,
                                  height: 160,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  // shimmer when slider list is empty
  // BANNER SHIMMER
  Widget sliderShimmer(width) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: SizedBox(
                child: Shimmer.fromColors(
                  baseColor: Color(int.parse("0xff040b24")),
                  highlightColor: Colors.black,
                  child: Card(
                    elevation: 0.0,
                    color: Color.fromRGBO(45, 45, 45, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: SizedBox(
                      width: 1000,
                      height: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SLIDER OF BANNER IMAGE
  Widget slider(context) {
    return Scaffold(
      backgroundColor: Color(int.parse("0xff02071a")),
      body: ListView(
        children: <Widget>[
          Stack(
            children: [
              // BANNER IAMGE
              sliderList.length == 0
                  ? sliderShimmer(400)
                  : Container(
                      constraints: BoxConstraints.expand(
                          height: MediaQuery.of(context).size.height * .60,
                          width: MediaQuery.of(context).size.width + 524),
                      child: sliderList.length <= 0
                          ? ""
                          : Swiper(
                              controller: swiperController,
                              pagination: new SwiperPagination(
                                alignment: Alignment.bottomCenter,
                                builder: new RectSwiperPaginationBuilder(
                                    color: Color(int.parse("0xff3D3447")),
                                    size: Size(30, 9)),
                              ),
                              itemCount: sliderList.length,
                              autoplay: true,
                              autoplayDelay: 6000,
                              autoplayDisableOnInteraction: true,
                              itemBuilder: (BuildContext context, int index) {
                                return ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black,
                                        Colors.transparent
                                      ],
                                    ).createShader(Rect.fromLTRB(
                                        0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: Image.network(
                                      sliderList[index]["thumbnail"].toString(),
                                      fit: BoxFit.fill, errorBuilder:
                                          (BuildContext context,
                                              Object exception,
                                              StackTrace stackTrace) {
                                    return Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.contain,
                                    );
                                  }),
                                );
                              },
                              onIndexChanged: (int index) {
                                sliderPosition = index;

                                setState(() {
                                  isAdded =
                                      sliderList[sliderPosition]["isAdded"];
                                });
                              }),
                    ),
              // TABBAR
              Row(
                children: <Widget>[
                  InkWell(
                      child: Padding(
                          padding: EdgeInsets.only(left: 15, top: 5, right: 5),
                          child: Image.asset(
                            "assets/images/logo.png",
                            width: 50,
                            height: 50,
                          )),
                      onTap: () {
                        refreshList();
                      }),
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: new ListView.builder(
                        padding: EdgeInsets.only(left: 10, top: 15),
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return GestureDetector(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 2.0, right: 5.0),
                              decoration: BoxDecoration(
                                  color: selected == index
                                      ? Colors.blue[600]
                                      : Colors.black.withOpacity(0.5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 3, bottom: 3),
                                child: Text(tabs[index],
                                    style: selected == index
                                        ? TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700)
                                        : TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400)),
                              ),
                            ),
                            onTap: () {
                              sliderList.clear();
                              setState(() {
                                selected = index;
                                setTabBar(index);
                                getSlider(index);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // MY LIST PLAY AND SHARE BUTTONS
              sliderList.length <= 0
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .45,
                          left: 10),
                      child: Row(
                        children: [
                          // MY LIST BUTTON
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                    icon: (isAdded == "1")
                                        ? Icon(Icons.done)
                                        : Icon(Icons.add),
                                    onPressed: () async {
                                      setState(() {
                                        sliderList[sliderPosition]["isAdded"] =
                                            sliderList[sliderPosition]
                                                        ["isAdded"] ==
                                                    "1"
                                                ? "0"
                                                : "1";

                                        addToWishList(
                                            sliderList[sliderPosition]);
                                      });
                                    }),
                                Text(
                                  isAdded == "1" ? "Added" : "My List",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                          // PLAY BUTTON
                          Expanded(
                            child: OutlineButton(
                              textColor: Colors.white,
                              padding: EdgeInsets.only(left: 20),
                              borderSide: BorderSide(color: Colors.blue),
                              onPressed: () {
                                print(allVideos.length.toString() +
                                    "slider ontap");
                                print(" slider ontap" +
                                    sliderList[sliderPosition].toString());
                                for (int i = 0; i < allVideos.length; i++) {
                                  print(allVideos[i]["type"] +
                                      "----" +
                                      sliderList[sliderPosition]["type"]);
                                  print(allVideos[i]["id"] +
                                      "-------" +
                                      sliderList[sliderPosition]["id"]);
                                  if (allVideos[i]["type"] ==
                                          sliderList[sliderPosition]["type"] &&
                                      allVideos[i]["id"] ==
                                          sliderList[sliderPosition]["id"]) {
                                    print("CLICKED");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContentDetails(allVideos[i])));
                                    break;
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.play_arrow),
                                  SizedBox(width: 10),
                                  Text(
                                    "PLAY",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 17),
                                  )
                                ],
                              ),
                            ),
                          ),
                          // SHARE BUTTON
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                    icon: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async{
                                      for (int i = 0;
                                          i < allVideos.length;
                                          i++) {
                                        if (allVideos[i]["type"] ==
                                                sliderList[sliderPosition]
                                                    ["type"] &&
                                            allVideos[i]["id"] ==
                                                sliderList[sliderPosition]
                                                    ["id"]) {
                                          popup(context);
                                          dynamicLinkService
                                              .createDynamicLink(
                                                  (allVideos[i]["id"]
                                                      .toString()),
                                                  allVideos[i]["type"],
                                                  allVideos[i]["title"],
                                                  allVideos[i]["description"],
                                                  allVideos[i]["thumbnail"])
                                              .then((newDynamicLink) async {
                                            // print(newDynamicLink + " Dynamic Link");


                                            final uri = Uri.parse(allVideos[i]["thumbnail"]);
                                            final res = await http.get(uri);
                                            final bytes = res.bodyBytes;

                                            final temp = await getTemporaryDirectory();
                                            final path = '${temp.path}/image.jpg';
                                            File(path).writeAsBytesSync(bytes);

                                            await Share.shareFiles(
                                              [path],
                                              text: "Watch " +
                                                  allVideos[i]["title"] +
                                                  "\n" +
                                                  newDynamicLink,

                                            );
                                            Navigator.pop(context);
                                          });
                                          break;
                                        }
                                      }
                                    }),
                                Text(
                                  "Share",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          SizedBox(height: 25),
          text(300, context),
        ],
      ),
      bottomNavigationBar: BottomNavBar(pageInd: 0),
    );
  }

  // TABS TEXT SETTING IN SLIDER TOP SECTION
  Future setTabBar(int index) async {
    if (index == 0) {
      setState(() {
        pageIndex = index;
        fetchHomeApi();
      });
    } else if (index == 1) {
      title = "Movies";

      setState(() {
        pageIndex = index;
        fetchMovies();
      });
    } else if (index == 2) {
      title = "Music";
      setState(() {
        pageIndex = index;
        fetchMusic();
      });
    } else if (index == 3) {
      title = "Kids";
      setState(() {
        pageIndex = index;
        fetchShortFilm();
      });
    }

    return null;
  }

  // CHANGE THE PAGE WHILE CLICK ON TABS
  Widget text(width, context) {
    return SingleChildScrollView(
        child: pageIndex == 0
            ? homePage(context)
            : pageIndex == 1
                ? moviesHomePage(context)
                : pageIndex == 2
                    ? musicHomePage(context)
                    : shortFilmsHomePage(context));
  }

  // HOME PAGE
  Widget homePage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lastPlayedVideos.length == 0
            ? SizedBox.shrink()
            : titleText("Continue Watching", lastPlayedVideos, context),
        lastPlayedVideos.length == 0
            ? SizedBox.shrink()
            : continueWatchingTile(lastPlayedVideos),
        movies.length == 0
            ? SizedBox.shrink()
            : titleText("Latest Movies", movies, context),
        movies.length == 0 ? SizedBox.shrink() : imageTile(movies),
        moviesByActors.length == 0
            ? SizedBox.shrink()
            : titleText("Movie by Artist", moviesByActors, context),
        moviesByActors.length == 0
            ? SizedBox.shrink()
            : circularAvatar(moviesByActors),
        // series.length == 0 ? SizedBox.shrink() : titleText("Latest Series", series, context),
        // series.length == 0 ? SizedBox.shrink() : imageTile(series),
        movies.length == 0
            ? SizedBox.shrink()
            : titleText("Movies by Language", moviesByLanguagesList, context),
        movies.length == 0 ? SizedBox.shrink() : circularAvatarLanguages(),
        music.length == 0
            ? SizedBox.shrink()
            : titleText("Latest Music", music, context),
        music.length == 0 ? SizedBox.shrink() : imageTile(music),
        shortFilms.length == 0
            ? SizedBox.shrink()
            : titleText("Kids", shortFilms, context),
        shortFilms.length == 0 ? SizedBox.shrink() : imageTile(shortFilms),
      ],
    );
  }

  // MOVIES HOME PAGE
  Widget moviesHomePage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        newReleasedMovies.length == 0
            ? SizedBox.shrink()
            : titleText("New Releases", newReleasedMovies, context),
        newReleasedMovies.length == 0
            ? SizedBox.shrink()
            : imageTile(newReleasedMovies),
        movies.length == 0
            ? SizedBox.shrink()
            : titleTextByCategory(title, context, movies),
        movies.length == 0 ? SizedBox.shrink() : imageTile(movies),
        moviesByLanguagesList.length == 0
            ? SizedBox.shrink()
            : movieByLanguage(context)
      ],
    );
  }

  // WEB SERIES
  Widget seriesHomePage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText("New Releases", series, context),
        imageTile(series),
        titleTextByCategory(title, context, series),
        imageTile(series),
        // titleText("Latest Series", movies, context),
        // imageTile(movies)
      ],
    );
  }

  // MUSIC HOME PAGE
  Widget musicHomePage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        music.length == 0
            ? SizedBox.shrink()
            : titleText("New Releases", music, context),
        music.length == 0 ? SizedBox.shrink() : imageTile(music),
        music.length == 0
            ? SizedBox.shrink()
            : titleTextByCategory(title, context, music),
        music.length == 0 ? SizedBox.shrink() : imageTile(music),
        musicByLanguagesList.length == 0
            ? SizedBox.shrink()
            : musicByLanguage(context),
        musicByActors.length == 0
            ? SizedBox.shrink()
            : titleText("Music by Artist", musicByActors, context),
        musicByActors.length == 0
            ? SizedBox.shrink()
            : circularAvatar(musicByActors),
      ],
    );
  }

  // SHORT FILMS HOME PAGE
  Widget shortFilmsHomePage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        newReleasedShortFilms.length == 0
            ? SizedBox.shrink()
            : titleText("New Releases", newReleasedShortFilms, context),
        newReleasedShortFilms.length == 0
            ? SizedBox.shrink()
            : imageTile(newReleasedShortFilms),
        shortFilms.length == 0
            ? SizedBox.shrink()
            : titleText("Kids", shortFilms, context),
        shortFilms.length == 0 ? SizedBox.shrink() : imageTile(shortFilms),
        shortFilmByLanguageList.length == 0
            ? SizedBox.shrink()
            : shortFilmsByLanguage(context)
      ],
    );
  }

  // display the video contents thumbnail images
  Widget imageTile(List items) {
    return SizedBox.fromSize(
        size: const Size.fromHeight(180.0),
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: items.length < 10 ? items.length : 10,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            color: Colors.white.withOpacity(0.1),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: InkWell(
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 160,
                                          child: Image.network(
                                              items[index]["thumbnail"]
                                                  .toString(),
                                              fit: BoxFit.cover, errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace stackTrace) {
                                            return Image.asset(
                                                "assets/images/logo.png");
                                          }),
                                        ),
                                        items[index]["amount"] != "0"
                                            ? Container(
                                                padding: EdgeInsets.only(
                                                    top: 2, left: 2),
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                    "assets/images/premium.png"))
                                            : SizedBox.shrink()
                                      ],
                                    ),
                                    onTap: () {
                                      if (items[index]["type"] == "webseries") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SeriesContentDetails(
                                                        items[index])));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ContentDetails(
                                                        items[index])));
                                      }
                                    })))
                      ]));
            }));
  }

  // thumbnail images of continue watching
  Widget continueWatchingTile(List items) {
    return SizedBox.fromSize(
        size: const Size.fromHeight(180.0),
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: items.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            color: Colors.white.withOpacity(0.1),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: InkWell(
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 160,
                                          child: Image.network(
                                              items[index]["thumbnail"]
                                                  .toString(),
                                              fit: BoxFit.cover, errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace stackTrace) {
                                            return Image.asset(
                                                "assets/images/logo.png");
                                          }),
                                        ),
                                        items[index]["amount"] != "0"
                                            ? Container(
                                                padding: EdgeInsets.only(
                                                    top: 2, left: 2),
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                    "assets/images/premium.png"))
                                            : SizedBox.shrink()
                                      ],
                                    ),
                                    onTap: () {
                                      if (items[index]["type"] == "webseries") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SeriesContentDetails(
                                                        items[index])));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyCustomPlayer(
                                                        items[index])));
                                      }
                                    })))
                      ]));
            }));
  }

  // SPLIT MOVIES ACCORDING TO LANGUAGES AND SEND AS A ROW
  movieByLanguage(context) {
    List<Column> rows = [];

    for (int index = 0; index < moviesByLanguagesList.length; index++) {
      rows.add(Column(children: [
        titleText(moviesByLanguagesList[index]["lang_name"],
            moviesByLanguagesList[index]["data"], context),
        contentByLanguage(moviesByLanguagesList[index]["data"], context)
      ]));
    }

    return Column(children: rows);
  }

  // SPLIT MUSIC BASED ON LANGUAGES
  musicByLanguage(context) {
    // // print(musicByLanguagesList);
    // print("musicByLanguage");

    List<Column> rows = [];

    for (int index = 0; index < musicByLanguagesList.length; index++) {
      rows.add(Column(children: [
        titleText(musicByLanguagesList[index]["lang_name"],
            musicByLanguagesList[index]["data"], context),
        contentByLanguage(musicByLanguagesList[index]["data"], context)
      ]));
    }

    return Column(children: rows);
  }

  // SPLIT MUSIC BASED ON LANGUAGES
  shortFilmsByLanguage(context) {
    List<Column> rows = [];

    for (int index = 0; index < shortFilmByLanguageList.length; index++) {
      rows.add(Column(children: [
        titleText(shortFilmByLanguageList[index]["lang_name"],
            shortFilmByLanguageList[index]["data"], context),
        contentByLanguage(shortFilmByLanguageList[index]["data"], context)
      ]));
    }

    return Column(children: rows);
  }

  // title text
  Widget titleText(String text, items, context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 15.0, 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pageIndex == 0 ? text : text.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            InkWell(
              child: Text("View All"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewAll(items)));
              },
            )
          ],
        ),
      ),
    );
  }

  // Category title
  Widget titleTextByCategory(String text, context, items) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 15.0, 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pageIndex == 0 ? text : "Top " + title.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            InkWell(
              child: Text("View All"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewAll(items)));
              },
            )
          ],
        ),
      ),
    );
  }

  // MOVIE BY ATRIST
  Widget circularAvatar(circularImages) {
    return SizedBox(
        height: 200,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: circularImages.length < 10 ? circularImages.length : 10,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            itemBuilder: (BuildContext context, int position) {
              var outerCircleRadius = MediaQuery.of(context).size.width * 0.15;
              var innerCircleRadiues = outerCircleRadius * 0.95;

              return Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          child: CircleAvatar(
                              radius: outerCircleRadius,
                              backgroundColor: Color(0xffFDCF09),
                              child: CircleAvatar(
                                backgroundColor: Color(0xff02071A),
                                foregroundColor: Colors.white,
                                radius: innerCircleRadiues,
                                backgroundImage: NetworkImage(circularImages[
                                                position]["actor_image"]
                                            .toString() ==
                                        null
                                    ? "https://t4.ftcdn.net/jpg/03/46/93/61/360_F_346936114_RaxE6OQogebgAWTalE1myseY1Hbb5qPM.jpg"
                                    : circularImages[position]["actor_image"]
                                        .toString()),
                              )),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewAll(
                                        circularImages[position]["data"])));
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Text(circularImages[position]["actor_name"]
                              .toString()),
                        )
                      ]));
            }));
  }

  // MOVIES BY LANGUAGES
  Widget circularAvatarLanguages() {
    return SizedBox(
        height: 180,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: moviesByLanguagesList.length < 10
                ? moviesByLanguagesList.length
                : 10,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            itemBuilder: (BuildContext context, int position) {
              var outerCircleRadius = MediaQuery.of(context).size.width * 0.15;
              var innerCircleRadius = outerCircleRadius * 0.95;

              return Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          child: CircleAvatar(
                              radius: outerCircleRadius,
                              backgroundColor: Color(0xffFDCF09),
                              child: CircleAvatar(
                                backgroundColor: Color(0xff02071A),
                                foregroundColor: Colors.white,
                                radius: innerCircleRadius,
                                backgroundImage: NetworkImage(
                                    moviesByLanguagesList[position]
                                        ["thumbnail_link"]),
                              )),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewAll(
                                        moviesByLanguagesList[position]
                                            ["data"])));
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                              moviesByLanguagesList[position]["lang_name"]),
                        )
                      ]));
            }));
  }

  //Movies by languages
  Widget contentByLanguage(items, context) {
    return SizedBox(
        height: 180,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: items.length < 10 ? items.length : 10,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white.withOpacity(0.1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: InkWell(
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 160,
                                child: Image.network(
                                    items[index]["thumbnail"].toString(),
                                    fit: BoxFit.cover, errorBuilder:
                                        (BuildContext context, Object exception,
                                            StackTrace stackTrace) {
                                  return Image.asset("assets/images/logo.png");
                                }),
                              ),
                              items[index]["amount"] != "0"
                                  ? Container(
                                      padding: EdgeInsets.only(top: 2, left: 2),
                                      height: 25,
                                      width: 25,
                                      child: Image.asset(
                                          "assets/images/premium.png"))
                                  : SizedBox.shrink()
                            ],
                          ),
                          onTap: () {
                            // // print(movies[index]["thumbnail"].toString());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ContentDetails(items[index])));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  // GET MOVIES
  getMovies() async {
    try {
      await Server.fetchMovies();
    } catch (e) {
      setState(() {
        serverError = true;
      });
    }

    this.setState(() {
      shimmerState = true;
    });
  }

  getSeries() async {
    await Server.fetchSeries();
  }

  // GET MUSIC
  getMusic() async {
    await Server.fetchMusic();
    await Server.displayWishlist();
    setState(() {});
  }

  // GET SHORT FILMS
  getShortFilms() async {
    await Server.fetchShortMovies();
    setState(() {});
  }

  // GET ARTIST
  getArtist() async {
    var response = await Server.fetchArtist();

    var result = json.decode(response);

    actors = result["data"];
  }

  // GET AUDIO LANGUAGES
  getMoviesByLanguages() async {
    await Server.fetchMoviesByLanguages();
  }

  // GET NEW RELEASED MOVIES
  getNewReleasedMovies() async {
    await Server.fetchNewReleasedMovies();

    setState(() {});
  }

  // MOVIES BY ARTIST
  getMoviesByArtist() async {
    await Server.fecthMoviesByActors();
  }

  // MOVIES BY ARTIST
  getMusicByArtist() async {
    await Server.fecthMusicByActors();
  }

  // MUSIC BY LANGUAGES
  getMusicByLanguage() async {
    await Server.fetchMusicByLanguages();

    this.setState(() {
      shimmerState = true;
    });
  }

  // new released movies
  getNewReleasedMusic() async {
    await Server.fetchNewReleasedMusic();
  }

  // SHORT FILSM BY LANGUAGES
  getShortFilmByLanguages() async {
    await Server.fecthShortFilmsByLanguages();
  }

  // SHORT FILMS BY NEW RELEASED SHORT FILMS
  getNewReleasedShortFilms() async {
    await Server.fetchNewReleasedShortFilms();

    this.setState(() {
      shimmerState = true;
    });
  }

  getSlider(int index) async {
    print("asd");
    var categories = ["home", "movie", "music", "short-film"];

    sliderList.clear();

    var response = await Server.slider(categories[index]);

    await Server.displayWishlist();

    if (response != []) {
      setState(() {
        for (int i = 0; i < response["slider"].length; i++) {
          response["slider"][i]["type"] = categories[index] != "home"
              ? categories[index]
              : response["slider"][i]["type"];
          response["slider"][i]["isAdded"] = "0";

          if (userWishListVideoIds.contains(response["slider"][i]["id"] +
              "_" +
              response["slider"][i]["type"])) {
            response["slider"][i]["isAdded"] = "1";
          }

          sliderList.add(response["slider"][i]);
        }
      });
    }
  }

  // add to wishlist
  addToWishList(item) async {
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

    if (result["response"] == "success") {
      setState(() {
        added = true;
        Fluttertoast.showToast(
            msg: "Added to wish list",
            backgroundColor: Colors.white,
            textColor: Colors.black);
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
}
