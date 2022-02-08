import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:luit/apis.dart';
import 'package:luit/global.dart';

class Server {
  static String baseUrl = "https://release.luit.co.in/api";
  static final _logger = Logger(
      printer: PrettyPrinter(
    printTime: true,
  ));

  static registration(var name, var email, var password, var mobile, var dob,
      var imagePath) async {
    var endPoint = Uri.parse(baseUrl + "/registration");

    var formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'dob': dob,
      'mobile': mobile,
      'image': await MultipartFile.fromFile(imagePath, filename: 'file.jpg')
    });

    var dio = Dio();
    var response = new Response();

    response = await dio.post(endPoint.toString(), data: formData);

    return response.data;
  }

  //3. USER PROFILE
  static userProfile(userId) async {
    String endPoint = baseUrl + "/profile";
    var logger = Logger();

    try {
      var map = new Map<String, dynamic>();

      map["id"] = luitUser["id"];

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      var result = json.decode(response.body);

      var data = result["data"][0];

      sanitize(response);

      if (result["response"] == "success") {
        // TODO: Remove this.
        username = data["name"];
        email = data["email"];
        userId = data["id"];
        dob = data["dob"];
        mobile = data["mobile"];
        joinedDate = data["created_at"];
        profilePic = data["image"];
        luitUser["joinedOn"] = joinedDate;
        // TODO: Remove this.

        luitUser["name"] = data["name"];
        luitUser["email"] = data["email"];
        luitUser["id"] = data["id"];
        luitUser["dob"] = data["dob"];
        luitUser["mobile"] = data["mobile"];
        luitUser["joinedOn"] = data["created_at"];
        luitUser["image"] = data["image"];

        logger.d(data["id"]);

        setSharedPreference("luitUser", jsonEncode(luitUser));
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //4. api to fetch only the top movies from exisiting api list of /movies
  static fetchMovies() async {
    fetchAllMovies();

    String endPoint = baseUrl + "/top_movies";

    try {
      var response = await http.get(
        Uri.parse(endPoint),
      );

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      if (fetchMoviesResponse != response) {
        fetchMoviesResponse = temp;

        movies = List.generate(temp.length, (index) {
          var video = {
            "type": temp[index]["type"],
            "id": temp[index]["movie_id"],
            "title": temp[index]["movie_title"],
            "description": temp[index]["description"],
            "video_url": temp[index]["movie_upload"] == null
                ? null
                : temp[index]["movie_upload"],
            "trailer_url": temp[index]["trailer_upload"] == null
                ? null
                : temp[index]["trailer_upload"],
            "audio_languages": temp[index]["audio_languages"],
            "maturity_rating": temp[index]["maturity_rating"],
            "thumbnail": temp[index]["thumbnail"],
            "poster": temp[index]["poster"],
            "free": temp[index]["free"],
            "amount": temp[index]["amount"],
            "meta_keyword": temp[index]["meta_keyword"],
            "meta_description": temp[index]["meta_description"],
            "directors": temp[index]["directors"],
            "actors": temp[index]["actors"],
            "genre": temp[index]["genre"],
            "duration": temp[index]["duration"],
            "ratings": temp[index]["ratings"],
            "publish_year": temp[index]["publish_year"],
            "status": temp[index]["status"]
          };

          // allVideos.add(video);

          return video;
        });
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // all movies list
  static fetchAllMovies() async {
    String endPoint = baseUrl + "/movies";

    try {
      var response = await http.get(
        Uri.parse(endPoint),
      );

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      if (fetchMoviesResponse != response) {
        fetchMoviesResponse = temp;

        movies = List.generate(temp.length, (index) {
          var video = {
            "type": temp[index]["type"],
            "id": temp[index]["movie_id"],
            "title": temp[index]["movie_title"],
            "description": temp[index]["description"],
            "video_url": temp[index]["movie_upload"] == null
                ? null
                : temp[index]["movie_upload"],
            "trailer_url": temp[index]["trailer_upload"] == null
                ? null
                : temp[index]["trailer_upload"],
            "audio_languages": temp[index]["audio_languages"],
            "maturity_rating": temp[index]["maturity_rating"],
            "thumbnail": temp[index]["thumbnail"],
            "poster": temp[index]["poster"],
            "free": temp[index]["free"],
            "amount": temp[index]["amount"],
            "meta_keyword": temp[index]["meta_keyword"],
            "meta_description": temp[index]["meta_description"],
            "directors": temp[index]["directors"],
            "actors": temp[index]["actors"],
            "genre": temp[index]["genre"],
            "duration": temp[index]["duration"],
            "ratings": temp[index]["ratings"],
            "publish_year": temp[index]["publish_year"],
            "status": temp[index]["status"]
          };

          allVideos.add(video);

          return video;
        });
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //5. MOVIES BY LANGUAGES
  static fetchMoviesByLanguages() async {
    String endPoint = baseUrl + "/language-movies";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

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
            "publish_year": langMovie["publish_year"],
            "status": langMovie["status"]
          };

          language["data"].add(movie);
        }

        moviesByLanguagesList.add(language);
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //6. MUSIC DETAILS
  static fetchMusic() async {
    String endPoint = baseUrl + "/musics";

    try {
      var response = await http.get(
        Uri.parse(endPoint),
      );

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      music = List.generate(temp.length, (index) {
        var video = {
          "type": temp[index]["type"],
          "id": temp[index]["id"],
          "title": temp[index]["title"],
          "description": temp[index]["description"],
          "video_url": temp[index]["upload_music"] == null
              ? null
              : temp[index]["upload_music"],
          "trailer_url": temp[index]["upload_trailer"] == null
              ? null
              : temp[index]["upload_trailer"],
          "audio_languages": temp[index]["audio_languages"],
          "maturity_rating": temp[index]["maturity_rating"],
          "thumbnail": temp[index]["thumbnail"],
          "poster": temp[index]["poster"],
          "amount": temp[index]["amount"],
          "metaKeyword": temp[index]["meta_keyword"],
          "metaDescription": temp[index]["meta_description"],
          "directors": temp[index]["directors"],
          "actors": temp[index]["actors"],
          "singers": temp[index]["singer"],
          "musicDirectors": temp[index]["music_director"],
          "choreographer": temp[index]["choreographer"],
          "genre": temp[index]["genre"],
          "duration": temp[index]["duration"],
          "ratings": temp[index]["ratings"],
          "publish_year": temp[index]["publish_year"],
          "status": temp[index]["status"]
        };

        allVideos.add(video);

        return video;
      });

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //7. SHORT MOVIES
  static fetchShortMovies() async {
    String endPoint = baseUrl + "/short_films";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      shortFilms = List.generate(temp.length, (index) {
        var video = {
          "type": temp[index]["type"],
          "id": temp[index]["id"],
          "title": temp[index]["title"],
          "description": temp[index]["description"],
          "video_url": temp[index]["upload_sf"],
          "trailer_url": temp[index]["upload_trailer"],
          "upload_subtitle": temp[index]["upload_subtitle"],
          "audio_languages": temp[index]["audio_languages"],
          "maturity_rating": temp[index]["maturity_rating"],
          "thumbnail": temp[index]["thumbnail"],
          "poster": temp[index]["poster"],
          "amount": temp[index]["amount"],
          "meta_keyword": temp[index]["meta_keyword"],
          "meta_description": temp[index]["meta_description"],
          "directors": temp[index]["directors"],
          "actors": temp[index]["actors"],
          "genre": temp[index]["genre"],
          "duration": temp[index]["duration"],
          "ratings": temp[index]["ratings"],
          "publish_year": temp[index]["publish_year"],
          "status": temp[index]["status"]
        };

        allVideos.add(video);

        return video;
      });

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //8. ARTIST DETAILS
  static fetchArtist() async {
    String endPoint = baseUrl + "/actor";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //9. DIRECTORS DETAILS
  static fetchDirectors() async {
    String endPoint = baseUrl + "/director";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  //10. SUBSCRIPTION PLANS
  static fetchSubscriptionPlans() async {
    String endPoint = baseUrl + "/subscription_plan";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      if (result["response"] == "success") {
        subscriptionPlans = result["data"];

        print(subscriptionPlans.length);
        print(
            "subscriptionPlans.lengthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");

        return response.body;
      } else {
        print(subscriptionPlans.length);
        subscriptionPlans.length = 0;
        print("subscriptionPlans.failed");
      }
    } catch (e) {
      print(e);
    }
  }

  // 11. NEW RELEASE MOVIES
  static fetchNewReleasedMovies() async {
    String endPoint = baseUrl + "/new_releases_movies";
    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      newReleasedMovies = List.generate(temp.length, (index) {
        return ({
          "type": temp[index]["type"],
          "id": temp[index]["movie_id"],
          "title": temp[index]["movie_title"],
          "description": temp[index]["description"],
          "video_url": temp[index]["movie_upload"],
          "trailer_url": temp[index]["trailer_upload"],
          "upload_subtitle": temp[index]["upload_subtitle"],
          "audio_languages": temp[index]["audio_languages"],
          "maturity_rating": temp[index]["maturity_rating"],
          "thumbnail": temp[index]["thumbnail"],
          "poster": temp[index]["poster"],
          "amount": temp[index]["amount"],
          "meta_keyword": temp[index]["meta_keyword"],
          "meta_description": temp[index]["meta_description"],
          "directors": temp[index]["directors"],
          "actors": temp[index]["actors"],
          "genre": temp[index]["genre"],
          "duration": temp[index]["duration"],
          "ratings": temp[index]["ratings"],
          "publish_year": temp[index]["publish_year"],
          "status": temp[index]["status"]
        });
      });

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 12. MOVIES BY ACTORS
  static fecthMoviesByActors() async {
    String endPoint = baseUrl + "/actor-movies";
    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      moviesByActors = [];

      for (int i = 0; i < result["data"].length; i++) {
        var language = {
          "actor_id": result["data"][i]["actor_id"],
          "actor_name": result["data"][i]["actor_name"],
          "actor_image": result["data"][i]["actor_image"],
          "data": []
        };

        for (int j = 0; j < result["data"][i]["data"].length; j++) {
          var movieArtist = result["data"][i]["data"][j];

          var music = {
            "type": movieArtist["type"],
            "id": movieArtist["movie_id"],
            "title": movieArtist["movie_title"],
            "description": movieArtist["description"],
            "video_url": movieArtist["movie_upload"],
            "trailer_url": movieArtist["trailer_upload"],
            "audio_languages": movieArtist["audio_languages"],
            "maturity_rating": movieArtist["maturity_rating"],
            "thumbnail": movieArtist["thumbnail"],
            "poster": movieArtist["poster"],
            "free": movieArtist["free"],
            "amount": movieArtist["amount"],
            "meta_keyword": movieArtist["meta_keyword"],
            "meta_description": movieArtist["meta_description"],
            "genre": movieArtist["genre"],
            "directors": movieArtist["directors"],
            "actors": movieArtist["actors"],
            "duration": movieArtist["duration"],
            "ratings": movieArtist["ratings"],
            "publish_year": movieArtist["publish_year"],
            "status": movieArtist["status"]
          };

          language["data"].add(music);
        }

        moviesByActors.add(language);
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 13. MUSIC BY LANGUAGES
  static fetchMusicByLanguages() async {
    String endPoint = baseUrl + "/language_music";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      musicByLanguagesList = [];

      for (int i = 0; i < result["data"].length; i++) {
        var language = {
          "lang_id": result["data"][i]["lang_id"],
          "lang_name": result["data"][i]["lang_name"],
          "thumbnail_link": result["data"][i]["thumbnail_link"],
          "data": []
        };

        for (int j = 0; j < result["data"][i]["data"].length; j++) {
          var langMusic = result["data"][i]["data"][j];

          var music = {
            "type": langMusic["type"],
            "id": langMusic["id"],
            "title": langMusic["title"],
            "description": langMusic["description"],
            "video_url": langMusic["upload_music"],
            "trailer_url": langMusic["upload_trailer"] == null
                ? null
                : langMusic["upload_trailer"],
            "audio_languages": langMusic["audio_languages"],
            "maturity_rating": langMusic["maturity_rating"],
            "thumbnail": langMusic["thumbnail"],
            "poster": langMusic["poster"],
            "amount": langMusic["amount"],
            "meta_keyword": langMusic["meta_keyword"],
            "meta_description": langMusic["meta_description"],
            "directors": langMusic["directors"],
            "actors": langMusic["actors"],
            "singers": langMusic["singer"],
            "musicDirectors": langMusic["music_director"],
            "choreographer": langMusic["choreographer"],
            "genre": langMusic["genre"],
            "duration": langMusic["duration"],
            "ratings": langMusic["ratings"],
            "publish_year": langMusic["publish_year"],
            "status": langMusic["status"]
          };

          language["data"].add(music);
        }

        musicByLanguagesList.add(language);
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 14. NEW RELEASED MUSIC
  static fetchNewReleasedMusic() async {
    String endPoint = baseUrl + "/new_releases_music";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      newReleasedMusic = List.generate(temp.length, (index) {
        return ({
          "type": temp[index]["type"],
          "id": temp[index]["id"],
          "title": temp[index]["title"],
          "description": temp[index]["description"],
          "video_url": temp[index]["upload_music"],
          "trailer_url": temp[index]["upload_trailer"],
          "upload_subtitle": temp[index]["upload_subtitle"],
          "audio_languages": temp[index]["audio_languages"],
          "maturity_rating": temp[index]["maturity_rating"],
          "thumbnail": temp[index]["thumbnail"],
          "poster": temp[index]["poster"],
          "amount": temp[index]["amount"],
          "meta_keyword": temp[index]["meta_keyword"],
          "meta_description": temp[index]["meta_description"],
          "directors": temp[index]["directors"],
          "actors": temp[index]["actors"],
          "singers": temp[index]["singer"],
          "musicDirectors": temp[index]["music_director"],
          "choreographer": temp[index]["choreographer"],
          "genre": temp[index]["genre"],
          "duration": temp[index]["duration"],
          "ratings": temp[index]["ratings"],
          "publish_year": temp[index]["publish_year"],
          "status": temp[index]["status"]
        });
      });

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 15. SHORT FILMS BY LANGUAGES
  static fecthShortFilmsByLanguages() async {
    String endPoint = baseUrl + "/language-short-film";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      shortFilmByLanguageList = [];

      for (int i = 0; i < result["data"].length; i++) {
        var language = {
          "lang_id": result["data"][i]["lang_id"],
          "lang_name": result["data"][i]["lang_name"],
          "thumbnail_link": result["data"][i]["thumbnail_link"],
          "data": []
        };

        for (int j = 0; j < result["data"][i]["data"].length; j++) {
          var langShortFilm = result["data"][i]["data"][j];

          var shortFilm = {
            "type": langShortFilm["type"],
            "id": langShortFilm["id"],
            "title": langShortFilm["title"],
            "description": langShortFilm["description"],
            "video_url": langShortFilm["upload_sf"],
            "trailer_url": langShortFilm["upload_trailer"],
            "audio_languages": langShortFilm["audio_languages"],
            "maturity_rating": langShortFilm["maturity_rating"],
            "thumbnail": langShortFilm["thumbnail"],
            "poster": langShortFilm["poster"],
            // "free": langShortFilm["free"],
            "amount": langShortFilm["amount"],
            "meta_keyword": langShortFilm["meta_keyword"],
            "meta_description": langShortFilm["meta_description"],
            "directors": langShortFilm["directors"],
            "actors": langShortFilm["actors"],
            "genre": langShortFilm["genre"],
            "duration": langShortFilm["duration"],
            "ratings": langShortFilm["ratings"],
            "publish_year": langShortFilm["publish_year"],
            "status": langShortFilm["status"]
          };

          language["data"].add(shortFilm);
        }

        shortFilmByLanguageList.add(language);
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 16. NEW RELEASE SHORT FILMS
  static fetchNewReleasedShortFilms() async {
    String endPoint = baseUrl + "/short-films-new-releases";

    try {
      var response = await http.get(Uri.parse(endPoint));

      sanitize(response);

      var result = json.decode(response.body);

      var temp = result["data"];

      newReleasedShortFilms = List.generate(temp.length, (index) {
        return ({
          "type": temp[index]["type"],
          "id": temp[index]["id"],
          "title": temp[index]["title"],
          "description": temp[index]["description"],
          "video_url": temp[index]["upload_sf"],
          "trailer_url": temp[index]["upload_trailer"],
          "upload_subtitle": temp[index]["upload_subtitle"],
          "audio_languages": temp[index]["audio_languages"],
          "maturity_rating": temp[index]["maturity_rating"],
          "thumbnail": temp[index]["thumbnail"],
          "poster": temp[index]["poster"],
          "amount": temp[index]["amount"],
          "meta_keyword": temp[index]["meta_keyword"],
          "meta_description": temp[index]["meta_description"],
          "directors": temp[index]["directors"],
          "actors": temp[index]["actors"],
          "genre": temp[index]["genre"],
          "duration": temp[index]["duration"],
          "ratings": temp[index]["ratings"],
          "publish_year": temp[index]["publish_year"],
          "status": temp[index]["status"]
        });
      });

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 17. VIDEO PAYMENT
  static payForVideo(
      var contentType, var contentId, var amount, var refNo) async {
    String endPoint = baseUrl + "/video-payment";

    try {
      var map = new Map<String, dynamic>();

      map["content_type"] = contentType;
      map["content_id"] = contentId;
      map["user_id"] = userId;
      map["amount"] = amount;
      map["ref_no"] = refNo;

      // print(map);

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 18. MONTHLY PAYMENT
  static monthlyPayment(
      var days, var startDate, var endDate, var amount, var refNumber) async {
    String endPoint = baseUrl + "/monthly-payment";

    try {
      var map = new Map<String, dynamic>();

      map["user_id"] = userId;
      map["valid_days"] = days;
      map["start_date"] = startDate;
      map["end_date"] = endDate;
      map["amount"] = amount;
      map["ref_no"] = refNumber;

      // print(map);

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 19. CHECK PAYMENT STATUS
  static checkPaymentStatus(var type, var contentId) async {
    String endPoint = baseUrl + "/checking_content_payment";

    try {
      var map = new Map<String, dynamic>();

      map["content_type"] = type;
      map["content_id"] = contentId;
      map["user_id"] = userId;

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 20. MONTHLY PAYMENT LIST
  static displayMonthlySubscription() async {
    String endPoint = baseUrl + "/monthly-payments-list";
    try {
      var map = new Map<String, dynamic>();

      map["user_id"] = userId;

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 21 ADD TO WISHLIST
  static addToWishlist(var type, var contentId) async {
    String endPoint = baseUrl + "/add_wishlist";

    try {
      var map = new Map<String, dynamic>();

      map["user_id"] = userId;
      map["video_id"] = contentId;
      map["video_type"] = type;

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 22. DISPLAY WISHLIST
  static displayWishlist() async {
    String endPoint = baseUrl + "/all_wishlist";

    try {
      var map = new Map<String, dynamic>();

      map["user_id"] = userId;

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      var result = json.decode(response.body);

      if (result["response"] == "failed") {
        wishList = [];
      } else {
        wishList.clear();
        userWishListVideoIds.clear();

        for (int i = 0; i < result["data"].length; i++) {
          var data = result["data"][i];

          var videoDetails = result["data"][i]["video_details"][0];

          // For showing the plus button on the home page slider.
          userWishListVideoIds
              .add(data["video_id"] + "_" + videoDetails["type"]);

          var list = {
            "listId": data["id"],
            "video_id": data["video_id"],
            "video_type": data["video_type"],
            "type": videoDetails["type"],
            "id": videoDetails["type"] == "movie"
                ? videoDetails["movie_id"]
                : videoDetails["id"],
            "title": videoDetails["type"] == "movie"
                ? videoDetails["movie_title"]
                : videoDetails["title"],
            "description": videoDetails["description"],
            "video_url": videoDetails["type"] == "movie"
                ? videoDetails["movie_upload"]
                : videoDetails["type"] == "music"
                    ? videoDetails["upload_music"]
                    : videoDetails["upload_sf"],
            "trailer_url": videoDetails["type"] == "movie"
                ? videoDetails["trailer_upload"]
                : videoDetails["upload_trailer"],
            "audio_languages": videoDetails["audio_languages"],
            "maturity_rating": videoDetails["maturity_rating"],
            "thumbnail": videoDetails["thumbnail"],
            "poster": videoDetails["poster"],
            "free": videoDetails["free"],
            "amount": videoDetails["amount"],
            "meta_keyword": videoDetails["meta_keyword"],
            "meta_description": videoDetails["meta_description"],
            "genre": videoDetails["genre"],
            "directors": videoDetails["directors"],
            "actors": videoDetails["actors"],
            "duration": videoDetails["duration"],
            "ratings": videoDetails["ratings"],
            "publish_year": videoDetails["publish_year"],
            "status": videoDetails["status"]
          };

          wishList.add(list);
        }

        return response.body;
      }
    } catch (e) {
      print(e);
    }
  }

  // 23. DELETE WISHLIST
  static deleteWishlist(var wishListId) async {
    String endPoint = baseUrl + "/delete_wishlist";

    try {
      var map = new Map<String, dynamic>();

      map["user_id"] = userId;
      map["whishlist_id"] = wishListId;

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: map,
      );

      sanitize(response);

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  // 24. CHECK IF ADDED TO WISHLIST
  static wishlistIsPresent(var contentType, var contentId) async {
    String endPoint = baseUrl + "/check-wishlist";

    var map = new Map<String, dynamic>();

    map["user_id"] = userId;
    map["video_id"] = contentId;
    map["video_type"] = contentType;

    // print(map);

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    return response.body;
  }

  //25. RATING CHECK
  static overallRating(var contentId, var contentType) async {
    String endPoint = baseUrl + "/video-rating";

    var map = new Map<String, dynamic>();

    map["video_id"] = contentId;
    map["video_type"] = contentType;

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    // print("response.body");
    // print(response.body);
    // print("response.body");

    return response.body;
  }

  // 26. RATE THE CONTENT
  static rateContent(var contentId, var contentType, var remarks) async {
    String endPoint = baseUrl + "/rating-submit";

    var map = new Map<String, dynamic>();

    map["user_id"] = userId == null ? luitUser["id"] : userId;
    map["video_id"] = contentId;
    map["video_type"] = contentType;
    map["remarks"] = remarks;

    // print(map);
    // print(luitUser);
    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    // print(response.body);

    return response.body;
  }

  // 27. RESET PASSWORD
  static resetPassword(var email, var password) async {
    String endPoint = baseUrl + "/forgot-password";

    var map = Map<String, dynamic>();

    map["email"] = email;
    map["password"] = password;

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    return response.body;
  }

  //28. PAYMENT HISTORY
  static fetchPaymentHistory() async {
    String endPoint = baseUrl + "/content-payment-history";

    var map = Map<String, dynamic>();

    map["user_id"] = userId;

    // print(map);

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    var temp = json.decode(response.body);

    // // print(temp);

    var data = temp["data"];

    paymentHistory = [];

    if (temp["response"] == "success") {
      paymentHistory = List.generate(data.length, (index) {
        return ({
          "db_id": data[index]["db_id"],
          "content_type": data[index]["content_type"],
          "content_id": data[index]["content_id"],
          "amount": "0",
          "ref_no": data[index]["ref_no"],
          "datetime": data[index]["datetime"],
          "type": data[index]["array"][0]["type"],
          "id": data[index]["array"][0]["type"] == "movie"
              ? data[index]["array"][0]["movie_id"]
              : data[index]["array"][0]["id"],
          "title": data[index]["array"][0]["type"] == "movie"
              ? data[index]["array"][0]["movie_title"]
              : data[index]["array"][0]["title"],
          "description": data[index]["array"][0]["description"],
          "video_url": data[index]["array"][0]["type"] == "movie"
              ? data[index]["array"][0]["movie_upload"]
              : data[index]["array"][0]["type"] == "music"
                  ? data[index]["array"][0]["upload_music"]
                  : data[index]["array"][0]["upload_sf"],
          "trailer_url": data[index]["array"][0]["type"] == "movie"
              ? data[index]["array"][0]["trailer_upload"]
              : data[index]["array"][0]["upload_trailer"],
          "audio_languages": data[index]["array"][0]["audio_languages"],
          "maturity_rating": data[index]["array"][0]["maturity_rating"],
          "thumbnail": data[index]["array"][0]["thumbnail"],
          "poster": data[index]["array"][0]["poster"],
          "metaKeyword": data[index]["array"][0]["meta_keyword"],
          "metaDescription": data[index]["array"][0]["meta_description"],
          "directors": data[index]["array"][0]["directors"],
          "actors": data[index]["array"][0]["actors"],
          "genre": data[index]["array"][0]["genre"],
          "duration": data[index]["array"][0]["duration"],
          "ratings": data[index]["array"][0]["ratings"],
          "publishYear": data[index]["array"][0]["publish_year"],
          "status": data[index]["array"][0]["status"]
        });
      });

      return response.body;
    } else {
      paymentHistory = [];

      return paymentHistory;
    }
  }

  // 29. SUBSCRIPTION PLANS
  static subscribedContents() async {
    String endPoint = baseUrl + "/subscription-payment-history";

    var map = Map<String, dynamic>();

    map["user_id"] = userId;

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    return response.body;
  }

  // 30 facebook login
  static facebookLogin(fId,userName,eMail,pic,) async {
    String endPoint = baseUrl + "/fb-login";

    try {
      Map body = {
        "facebook_id": fId,
        "name": userName,
        "email": eMail,
        "dob": "",
        "age": "",
        "image": pic,
        "login_phone_no": "",
        "token": tokenId,
        "device_id": deviceId
      };

      print(body);
      Fluttertoast.showToast(msg: "$body", toastLength: Toast.LENGTH_LONG);

      var response = await http.post(
        Uri.parse(endPoint),
        headers: {
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: body,
      );
      Fluttertoast.showToast(msg: "${response.body}", toastLength: Toast.LENGTH_LONG);
      return response.body;

    } catch (e) {
      print(e);
    }
  }

  // 31 google login
  static googleLogin() async {
    String endPoint = baseUrl + "/google-login";

    var map = Map<String, dynamic>();

    map["google_id"] = googleId;
    map["name"] = username;
    map["email"] = email;
    map["dob"] = "";
    map["age"] = "";
    map["image"] = profilePic == null ? "" : profilePic;
    map["login_phone_no"] = "";
    map["token"] = tokenId;
    map["device_id"] = deviceId;

    // map["google_id"] = "23274324";
    // map["name"] = "abc";
    // map["email"] = "abc@gmail.com";
    // map["dob"] = "";
    // map["age"] = "";
    // map["image"] = profilePic;
    // map["login_phone_no"] = "";
    // map["token"] = "dfdsfdsfdsdgetet";
    // map["device_id"] = "fr44534t6terg";

    print(map);

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    print(response.body);

    return response.body;
  }

  // 33 login with OTP
  static loginWithOtp() async {
    String endPoint = baseUrl + "/login-first";

    var map = Map<String, dynamic>();

    map["login_phone_no"] = mobile;
    map["token"] = tokenId;
    map["device_id"] = deviceId;

    print(map);

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    return response.body;
  }

  // 34. Check if video was already reated or not.
  static checkIfVideoRated(var videoId, var videoType) async {
    String endPoint = baseUrl + "/rating_check";

    var map = Map<String, dynamic>();

    map["user_id"] = userId;
    map["video_id"] = videoId;
    map["video_type"] = videoType;

    var response = await http.post(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: map,
    );

    sanitize(response);

    // print(response.body);

    return response.body;
  }

  // 35. Fecth series
  static fetchSeries() async {
    String endPoint = baseUrl + "/webseries";

    var response = await http.get(
      Uri.parse(endPoint),
      headers: {
        HttpHeaders.contentTypeHeader:
            "application/x-www-form-urlencoded; charset=UTF-8"
      },
    );

    sanitize(response);

    var temp = json.decode(response.body);

    series.clear();

    for (int i = 0; i < temp["data"].length; i++) {
      series.add(temp["data"][i]);
    }
  }

  // 36. slider
  static slider(var category) async {
    print(category);
    try {
      String endPoint = baseUrl + "/slider";

      Map body = {"category": category};

      var response = await http.post(Uri.parse(endPoint),
          headers: {
            HttpHeaders.contentTypeHeader:
                "application/x-www-form-urlencoded; charset=UTF-8"
          },
          body: body);

      print(body);

      var decodedResponse = json.decode(response.body);

      print(decodedResponse);
      print("slider images");

      return (decodedResponse == null ||
              decodedResponse["response"] == "failed")
          ? []
          : decodedResponse;
    } catch (e) {
      // print(e);
    }
  }

  // 37. MUSIC BY ACTORS
  static fecthMusicByActors() async {
    final _logger = Logger();
    String endPoint = baseUrl + "/actor-music";
    try {
      var response = await http.get(Uri.parse(endPoint));
      _logger.d("I am here");
      _logger.d(response);
      sanitize(response);

      var result = json.decode(response.body);

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
        }

        musicByActors.add(language);
      }

      return response.body;
    } catch (e) {
      print(e);
    }
  }

  static sanitize(var response) {
    _logger.e(response.body);
    _logger.e(response.statusCode);
    try {
      if (response.statusCode != 200) {
        throw Exception("Server Error: Didn't return 200!");
      } else if (response.body == null || response.body == "") {
        throw Exception("Server Error: Response is empty!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // update user profile
  static updateUserProfie() async {
    String endPoint = baseUrl + "/profile-update";

    var tempUserData = luitUser;

    print(tempUserData["image64"].runtimeType);

    tempUserData["image"] =
        tempUserData["image64"] != null && tempUserData["image64"] != ""
            ? await MultipartFile.fromFile(tempUserData["image64"],
                filename: 'file.jpg')
            : luitUser["image"];

    print("tempUserdata");
    print(tempUserData);
    print("tempUserdata");

    try {
      var formData = FormData.fromMap(tempUserData);

      var dio = Dio();
      var response = new Response();

      response = await dio.post(endPoint, data: formData);
      var responseData = json.decode(response.data);

      luitUser["image"] = responseData["image"];

      setSharedPreference("luitUser", jsonEncode(luitUser));

      print(response.data);

      return responseData;
    } catch (e) {
      Fluttertoast.showToast(msg: "Server Error");
      print(e);
    }
  }
}
