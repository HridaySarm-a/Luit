import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luit/Home%20Components/home.dart';
import 'package:luit/LoadingComponents/server.dart';
import 'package:luit/global.dart';
import 'package:luit/models/user.dart';
import 'package:splashscreen/splashscreen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  UserProfile userProfile;
  List temp;

  @override
  void initState() {
    super.initState();
    getUserProfile();
    getSubscriptionPlans();
    getMoviesByLanguages();
    getMoviesByArtist();
    getMusicByArtist();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("loading screen");
    return Container(
        color: Color(int.parse("0xff02071a")),
        padding: EdgeInsets.only(top: 150),
        child: SplashScreen(
            seconds: 2,
            navigateAfterSeconds: Home(),
            image: Image.asset(
              "assets/images/luit-logo.png",
              scale: 1.0,
            ),
            backgroundColor: Color(int.parse("0xff02071a")),
            styleTextUnderTheLoader: TextStyle(),
            photoSize: 100.0,
            loaderColor: Colors.red));
  }

  // USER PROFILE
  getUserProfile() async {
    await Server.userProfile(userId);
  }

  // SUBSCRIPTION  PLANS
  getSubscriptionPlans() async {
    await Server.fetchSubscriptionPlans();
  }

  // GET AUDIO LANGUAGES
  getMoviesByLanguages() async {
    var response = await Server.fetchMoviesByLanguages();

    var result = json.decode(response);

    moviesByLanguagesList = [];

    for (int i = 0; i < result["data"].length; i++) {
      var language = {
        "lang_id": result["data"][i]["lang_id"],
        "lang_name": result["data"][i]["lang_name"],
        "thumbnail_link": result["data"][i]["thumbnail_link"],
        "data": []
      };

      for (int j = 0; j < result["data"][i]["data"].length; j++) {
        var langMovie = result["data"][i]["data"][j];

        var movie = {
          "type": langMovie["type"],
          "id": langMovie["movie_id"],
          "title": langMovie["movie_title"],
          "description": langMovie["description"],
          "video_url": langMovie["movie_upload"],
          "trailer_url": langMovie["trailer_upload"],
          "audio_languages": langMovie["audio_languages"],
          "maturity_rating": langMovie["maturity_rating"],
          "thumbnail": langMovie["thumbnail"],
          "poster": langMovie["poster"],
          "free": langMovie["free"],
          "amount": langMovie["amount"],
          "meta_keyword": langMovie["meta_keyword"],
          "meta_description": langMovie["meta_description"],
          "directors": langMovie["directors"],
          "actors": langMovie["actors"],
          "genre": langMovie["genre"],
          "duration": langMovie["duration"],
          "ratings": langMovie["ratings"],
          "publish_year": langMovie["publish_year"]
        };

        language["data"].add(movie);
      }

      moviesByLanguagesList.add(language);
    }
  }

  // MOVIES BY ARTIST
  getMoviesByArtist() async {
    var response = await Server.fecthMoviesByActors();

    var result = json.decode(response);

    moviesByActors = [];

    for (int i = 0; i < result["data"].length; i++) {
      var language = {
        "actor_id": result["data"][i]["actor_id"],
        "actor_name": result["data"][i]["actor_name"],
        "actor_image": result["data"][i]["actor_image"],
        "data": []
      };

      for (int j = 0; j < result["data"][i]["data"].length; j++) {
        var langMusic = result["data"][i]["data"][j];

        var music = {
          "type": langMusic["type"],
          "id": langMusic["movie_id"],
          "title": langMusic["movie_title"],
          "description": langMusic["description"],
          "video_url": langMusic["movie_upload"],
          "trailer_url": langMusic["trailer_upload"],
          "audio_languages": langMusic["audio_languages"],
          "maturity_rating": langMusic["maturity_rating"],
          "thumbnail": langMusic["thumbnail"],
          "poster": langMusic["poster"],
          "free": langMusic["free"],
          "amount": langMusic["amount"],
          "meta_keyword": langMusic["meta_keyword"],
          "meta_description": langMusic["meta_description"],
          "genre": langMusic["genre"],
          "directors": langMusic["directors"],
          "actors": langMusic["actors"],
          "duration": langMusic["duration"],
          "ratings": langMusic["ratings"],
          "publish_year": langMusic["publish_year"]
        };

        language["data"].add(music);
      }

      moviesByActors.add(language);
    }
  }

  // MOVIES BY ARTIST
  getMusicByArtist() async {
    var response = await Server.fecthMusicByActors();

    var result = json.decode(response);

    musicByActors = [];

    for (int i = 0; i < result["data"].length; i++) {
      var language = {
        "actor_id": result["data"][i]["actor_id"],
        "actor_name": result["data"][i]["actor_name"],
        "actor_image": result["data"][i]["actor_image"],
        "data": []
      };

      for (int j = 0; j < result["data"][i]["data"].length; j++) {
        var movieArtist = result["data"][i]["data"][j];
        //var langMusic = result["data"][i]["data"][j];

        var music = {
          "type": movieArtist["type"],
          "id": movieArtist["id"],
          "title": movieArtist["title"],
          "description": movieArtist["description"],
          "video_url": movieArtist["upload_music"] == null
              ? null
              : movieArtist["upload_music"],
          "trailer_url": movieArtist["upload_trailer"] == null
              ? null
              : movieArtist["upload_trailer"],
          "audio_languages": movieArtist["audio_languages"],
          "maturity_rating": movieArtist["maturity_rating"],
          "thumbnail": movieArtist["thumbnail"],
          "poster": movieArtist["poster"],
          "amount": movieArtist["amount"],
          "metaKeyword": movieArtist["meta_keyword"],
          "metaDescription": movieArtist["meta_description"],
          "directors": movieArtist["directors"],
          "actors": movieArtist["actors"],
          "singers": movieArtist["singer"],
          "musicDirectors": movieArtist["music_director"],
          "choreographer": movieArtist["choreographer"],
          "genre": movieArtist["genre"],
          "duration": movieArtist["duration"],
          "ratings": movieArtist["ratings"],
          "publish_year": movieArtist["publish_year"],
          "status": movieArtist["status"]
        };

        language["data"].add(music);

        /* var music = {
          "type": langMusic["type"],
          "id": langMusic["movie_id"],
          "title": langMusic["movie_title"],
          "description": langMusic["description"],
          "video_url": langMusic["movie_upload"],
          "trailer_url": langMusic["trailer_upload"],
          "audio_languages": langMusic["audio_languages"],
          "maturity_rating": langMusic["maturity_rating"],
          "thumbnail": langMusic["thumbnail"],
          "poster": langMusic["poster"],
          "free": langMusic["free"],
          "amount": langMusic["amount"],
          "meta_keyword": langMusic["meta_keyword"],
          "meta_description": langMusic["meta_description"],
          "genre": langMusic["genre"],
          "directors": langMusic["directors"],
          "actors": langMusic["actors"],
          "duration": langMusic["duration"],
          "ratings": langMusic["ratings"],
          "publish_year": langMusic["publish_year"]
        }; */

        language["data"].add(music);
      }

      musicByActors.add(language);
    }
  }
}
