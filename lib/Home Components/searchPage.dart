import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/UI/DetailedPage/contentDetails.dart';
import 'package:luit/Home%20Components/bottomNavigationBar.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/global.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List newDataList = [];
  List tempList = [];
  List allVideosList = [];

  bool search = false;

  @override
  void initState() {
    super.initState();
    print(allVideos.length);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse("0xff02071a")),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          },
        ),
        title: searchBar(),
      ),
      body: !search ? blankDisplay() : searchFilters(),
      bottomNavigationBar: BottomNavBar(
        pageInd: 1,
      ),
    );
  }

  Widget searchBar() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
          fillColor: Colors.white.withOpacity(0.13),
          filled: true,
          suffixIcon: Icon(
            Icons.search,
            color: Colors.white54,
          ),
          hintText: 'Search for movies, series, music...',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10)),
      // onChanged: onItemChanged,
      onSubmitted: onItemChanged,
    );
  }

  Widget blankDisplay() {
    return Padding(
        padding: EdgeInsets.fromLTRB(15, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Find what to watch next",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white54),
            ),
            SizedBox(height: 20),
            Text(
              "Search for your favourite shows and enjoy the moment...",
              style:
                  TextStyle(fontWeight: FontWeight.w400, color: Colors.white54),
            ),
          ],
        ));
  }

  Widget searchFilters() {
    return ListView.builder(
        padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 10),
        itemCount: newDataList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Card(
              margin: EdgeInsets.only(bottom: 20, left: 5, right: 5),
              elevation: 6,
              color: Colors.white12,
              child: Container(
                  padding: EdgeInsets.only(left: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 75,
                          height: 100,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Image.network(
                                  newDataList[index]["poster"].toString(),
                                  fit: BoxFit.cover, errorBuilder:
                                      (BuildContext context, Object exception,
                                          StackTrace stackTrace) {
                                return Image.asset("assets/images/logo.png");
                              }))),
                      SizedBox(width: 10),
                      details(index)
                    ],
                  )),
            ),
            onTap: () {
              // print(newDataList[index]);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ContentDetails(newDataList[index])));
            },
          );
        });
  }

  Widget details(index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.only(top: 15, left: 15),
        child: Text(
          newDataList[index]["title"].toString().length > 10
              ? newDataList[index]["title"].toString().substring(0, 10)
              : newDataList[index]["title"].toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 15, left: 15),
        child: Text(newDataList[index]["genre"].join(",") + " Videos",
            style: TextStyle(
                fontWeight: FontWeight.w300, fontSize: 12, letterSpacing: 1.5)),
      ),
      Padding(
        padding: EdgeInsets.only(top: 15, left: 15),
        child: Text(
            newDataList[index]["amount"] == "0"
                ? "Free"
                : "INR " + newDataList[index]["amount"],
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              letterSpacing: 1,
            )),
      )
    ]);
  }

  onItemChanged(String value) {
    newDataList.clear();

    search = true;

    if (value != "") {
      // for (int i = 0; i < movies.length; i++) {
      //
      //   String searchText = movies[i]["title"] +
      //       " " +
      //       movies[i]["description"].toString() +
      //       " " +
      //       movies[i]["meta_description"].toString() +
      //       " " +
      //       movies[i]["meta_keyword"].toString() +
      //       " " +
      //       movies[i]["directors"].toString() +
      //       " " +
      //       movies[i]["singer"].toString() +
      //       " " +
      //       movies[i]["music_director"].toString();
      //   if (searchText
      //           .toLowerCase()
      //           .indexOf(searchController.text.toLowerCase()) !=
      //       -1) {
      //     print("Search Result " + searchText);
      //     allVideos
      //         .where((element) => movies[i]["title"]
      //             .toString()
      //             .toLowerCase()
      //             .contains(element["title"].toString().substring(0,4).toLowerCase()))
      //         .forEach((vid) {
      //       tempList.add(vid);
      //     });
      //     allVideos.forEach((video) {
      //       if (movies[i]["description"].toString().toLowerCase() ==
      //           video["description"].toString().toLowerCase()) {
      //         tempList.add(video);
      //         return;
      //      } else if (movies[i]["meta_description"].toString().toLowerCase() ==
      //           video["meta_description"].toString().toLowerCase()) {
      //         tempList.add(video);
      //       } else if (movies[i]["meta_keyword"].toString().toLowerCase() ==
      //           video["meta_keyword"].toString().toLowerCase()) {
      //         tempList.add(video);
      //       } else if (movies[i]["directors"].toString().toLowerCase() ==
      //           video["directors"].toString().toLowerCase()) {
      //         tempList.add(video);
      //       } else if (movies[i]["actors"].toString().toLowerCase() ==
      //           video["actors"].toString().toLowerCase()) {
      //         tempList.add(video);
      //       } else if (movies[i]["music_director"].toString().toLowerCase() ==
      //           video["music_director"].toString().toLowerCase()) {
      //         tempList.add(video);
      //       }
      //     });
      //     break;
      //   }
      // }

      for (int i = 0; i < allVideos.length; i++) {
        String searchText = allVideos[i]["title"] +
            " " +
            allVideos[i]["description"].toString() +
            " " +
            allVideos[i]["meta_description"].toString() +
            " " +
            allVideos[i]["meta_keyword"].toString() +
            " " +
            allVideos[i]["genre"].toString() +
            " " +
            allVideos[i]["directors"].toString() +
            " " +
            allVideos[i]["actors"].toString() +
            " " +
            allVideos[i]["singer"].toString() +
            " " +
            allVideos[i]["choreographer "].toString() +
            " " +
            allVideos[i]["music_director"].toString();
        if (searchText
                .toLowerCase()
                .indexOf(searchController.text.toLowerCase()) !=
            -1) {
          print("Search Result " + searchText);
          tempList.add(allVideos[i]);
        }
      }
    } else {
      tempList = [];
    }

    // for (int i = 0; i < allVideos.length; i++) {
    //   for(int j = 0 ;j<movies.length)
    //  if(i<movies.length){
    //
    //  }

    // String searchText2 = music[i]["title"].toString() +
    //     " " +
    //     music[i]["meta_keyboard"].toString() +
    //     " " +
    //     music[i]["meta_description"].toString() +
    //     " " +
    //     music[i]["directors"].toString() +
    //     " " +
    //     music[i]["actors"].toString() +
    //     " " +
    //     music[i]["singer"].toString() +
    //     " " +
    //     music[i]["music_director"].toString() +
    //     " " +
    //     music[i]["choreographer"].toString() +
    //     " " +
    //     music[i]["genre"].toString();
    // print(searchText2);
    //
    // String searchText3 = shortFilms[i]["title"].toString() +
    //     " " +
    //     shortFilms[i]["meta_keyboard"].toString() +
    //     " " +
    //     shortFilms[i]["meta_description"].toString() +
    //     " " +
    //     shortFilms[i]["directors"] .toString()+
    //     " " +
    //     shortFilms[i]["actors"] .toString()+
    //     " " +
    //     shortFilms[i]["description"] .toString()+
    //     " " +
    //     shortFilms[i]["genre"].toString();
    //
    // print(searchText3);

    // if (searchText2
    //     .toLowerCase()
    //     .contains(searchController.text.toLowerCase())) {
    //   tempList.add(allVideos[i]);
    // }
    // if (searchText3
    //     .toLowerCase()
    //     .contains(searchController.text.toLowerCase())) {
    //   tempList.add(allVideos[i]);
    // }
    // }

    setState(() {
      newDataList = tempList;
    });
  }
}
