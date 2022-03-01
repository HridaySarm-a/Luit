/// response : "success"
/// message : "data"
/// data : [{"singer_id":"1","singer_name":"Shahrukh Khan","singer_image":"http://release.luit.co.in/uploads/singer/1615557944sharukh.png","data":[{"type":"music","id":"1","title":"ASSAM DESER","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476300ASSAM DESER.mp4","upload_trailer":"","audio_languages":["Assamese"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628670731ASSAM DESER (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628670731ASSAM DESER (App Poster).jpg","amount":"0","meta_keyword":"","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan","Rakesh Riyan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"5.32","ratings":"","publish_year":"","status":"1"},{"type":"music","id":"2","title":"BARIRE SIMARE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476516BARIRE SIMARE.mp4","upload_trailer":"","audio_languages":["Assamese"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628670920BARIRE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628670920BARIRE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan","Rakesh Riyan"],"music_director":["Arijeet Singh1"],"choreographer":["Subhabrata Ch. paul"],"genre":["Music Video"],"duration":"4.15","ratings":"5","publish_year":"","status":"1"},{"type":"music","id":"3","title":"KARAM SALE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476719KARAM SALE.mp4","upload_trailer":"","audio_languages":["Baganiya"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628671304KARAM SALE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628671304KARAM SALE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"4.25","ratings":"5","publish_year":"","status":"1"},{"type":"music","id":"5","title":"O MINI RE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476947O MINI RE.mp4","upload_trailer":"","audio_languages":["Baganiya"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1631778636O MINI RE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1631778636O MINI RE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"4.16","ratings":"5","publish_year":"","status":"1"}]},{"singer_id":"2","singer_name":"Rakesh Riyan","singer_image":"https://release.luit.co.in/uploads/singer/1642772446Screen_Shot_2022-01-21_at_7_10_11_PM.png","data":[{"type":"music","id":"1","title":"ASSAM DESER","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476300ASSAM DESER.mp4","upload_trailer":"","audio_languages":["Assamese"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628670731ASSAM DESER (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628670731ASSAM DESER (App Poster).jpg","amount":"0","meta_keyword":"","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan","Rakesh Riyan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"5.32","ratings":"","publish_year":"","status":"1"},{"type":"music","id":"2","title":"BARIRE SIMARE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476516BARIRE SIMARE.mp4","upload_trailer":"","audio_languages":["Assamese"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628670920BARIRE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628670920BARIRE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan","Rakesh Riyan"],"music_director":["Arijeet Singh1"],"choreographer":["Subhabrata Ch. paul"],"genre":["Music Video"],"duration":"4.15","ratings":"5","publish_year":"","status":"1"},{"type":"music","id":"4","title":"MADHUPUR BAGANER","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476819MADHUPUR BAGANER.mp4","upload_trailer":"","audio_languages":["Baganiya"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628671425MADHUPUR (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628671425MADHUPUR (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Rakesh Riyan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"3.42","ratings":"5","publish_year":"","status":"1"}]}]

class MusicBySingerModel {
  MusicBySingerModel({
      String response, 
      String message, 
      List<Data> data,}){
    _response = response;
    _message = message;
    _data = data;
}

  MusicBySingerModel.fromJson(dynamic json) {
    _response = json['response'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data.add(Data.fromJson(v));
      });
    }
  }
  String _response;
  String _message;
  List<Data> _data;

  String get response => _response;
  String get message => _message;
  List<Data> get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['response'] = _response;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data.map((v) => v.toJson()).toList();
    }
    return map;
  }

}


/// singer_id : "1"
/// singer_name : "Shahrukh Khan"
/// singer_image : "http://release.luit.co.in/uploads/singer/1615557944sharukh.png"
/// data : [{"type":"music","id":"1","title":"ASSAM DESER","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476300ASSAM DESER.mp4","upload_trailer":"","audio_languages":["Assamese"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628670731ASSAM DESER (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628670731ASSAM DESER (App Poster).jpg","amount":"0","meta_keyword":"","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan","Rakesh Riyan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"5.32","ratings":"","publish_year":"","status":"1"},{"type":"music","id":"2","title":"BARIRE SIMARE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476516BARIRE SIMARE.mp4","upload_trailer":"","audio_languages":["Assamese"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628670920BARIRE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628670920BARIRE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan","Rakesh Riyan"],"music_director":["Arijeet Singh1"],"choreographer":["Subhabrata Ch. paul"],"genre":["Music Video"],"duration":"4.15","ratings":"5","publish_year":"","status":"1"},{"type":"music","id":"3","title":"KARAM SALE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476719KARAM SALE.mp4","upload_trailer":"","audio_languages":["Baganiya"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1628671304KARAM SALE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1628671304KARAM SALE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"4.25","ratings":"5","publish_year":"","status":"1"},{"type":"music","id":"5","title":"O MINI RE","description":"","upload_music":"https://release.luit.co.in/uploads/musics/1613476947O MINI RE.mp4","upload_trailer":"","audio_languages":["Baganiya"],"maturity_rating":"1","thumbnail":"https://release.luit.co.in/uploads/music_thumbnail/1631778636O MINI RE (Thumbnail) 001.jpg","poster":"https://release.luit.co.in/uploads/music_poster/1631778636O MINI RE (App Poster).jpg","amount":"0","meta_keyword":"TEA TRIBE SONG ","meta_description":"","directors":["Manas Robin"],"actors":["AKASH DEEP"],"singer":["Shahrukh Khan"],"music_director":[],"choreographer":[],"genre":["Music Video"],"duration":"4.16","ratings":"5","publish_year":"","status":"1"}]

class Data {
  Data({
      String singerId, 
      String singerName, 
      String singerImage, 
      List<DataChild> data,}){
    _singerId = singerId;
    _singerName = singerName;
    _singerImage = singerImage;
    _data = data;
}

  Data.fromJson(dynamic json) {
    _singerId = json['singer_id'];
    _singerName = json['singer_name'];
    _singerImage = json['singer_image'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data.add(DataChild.fromJson(v));
      });
    }
  }
  String _singerId;
  String _singerName;
  String _singerImage;
  List<DataChild> _data;

  String get singerId => _singerId;
  String get singerName => _singerName;
  String get singerImage => _singerImage;
  List<DataChild> get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['singer_id'] = _singerId;
    map['singer_name'] = _singerName;
    map['singer_image'] = _singerImage;
    if (_data != null) {
      map['data'] = _data.map((v) => v.toJson()).toList();
    }
    return map;
  }

}



/// type : "music"
/// id : "1"
/// title : "ASSAM DESER"
/// description : ""
/// upload_music : "https://release.luit.co.in/uploads/musics/1613476300ASSAM DESER.mp4"
/// upload_trailer : ""
/// audio_languages : ["Assamese"]
/// maturity_rating : "1"
/// thumbnail : "https://release.luit.co.in/uploads/music_thumbnail/1628670731ASSAM DESER (Thumbnail) 001.jpg"
/// poster : "https://release.luit.co.in/uploads/music_poster/1628670731ASSAM DESER (App Poster).jpg"
/// amount : "0"
/// meta_keyword : ""
/// meta_description : ""
/// directors : ["Manas Robin"]
/// actors : ["AKASH DEEP"]
/// singer : ["Shahrukh Khan","Rakesh Riyan"]
/// music_director : []
/// choreographer : []
/// genre : ["Music Video"]
/// duration : "5.32"
/// ratings : ""
/// publish_year : ""
/// status : "1"

class DataChild {
  DataChild({
      String type, 
      String id, 
      String title, 
      String description, 
      String uploadMusic, 
      String uploadTrailer, 
      List<String> audioLanguages, 
      String maturityRating, 
      String thumbnail, 
      String poster, 
      String amount, 
      String metaKeyword, 
      String metaDescription, 
      List<String> directors, 
      List<String> actors, 
      List<String> singer, 
      List<dynamic> musicDirector, 
      List<dynamic> choreographer, 
      List<String> genre, 
      String duration, 
      String ratings, 
      String publishYear, 
      String status,}){
    _type = type;
    _id = id;
    _title = title;
    _description = description;
    _uploadMusic = uploadMusic;
    _uploadTrailer = uploadTrailer;
    _audioLanguages = audioLanguages;
    _maturityRating = maturityRating;
    _thumbnail = thumbnail;
    _poster = poster;
    _amount = amount;
    _metaKeyword = metaKeyword;
    _metaDescription = metaDescription;
    _directors = directors;
    _actors = actors;
    _singer = singer;
    _musicDirector = musicDirector;
    _choreographer = choreographer;
    _genre = genre;
    _duration = duration;
    _ratings = ratings;
    _publishYear = publishYear;
    _status = status;
}

  DataChild.fromJson(dynamic json) {
    _type = json['type'];
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _uploadMusic = json['upload_music'];
    _uploadTrailer = json['upload_trailer'];
    _audioLanguages = json['audio_languages'] != null ? json['audio_languages'].cast<String>() : [];
    _maturityRating = json['maturity_rating'];
    _thumbnail = json['thumbnail'];
    _poster = json['poster'];
    _amount = json['amount'];
    _metaKeyword = json['meta_keyword'];
    _metaDescription = json['meta_description'];
    _directors = json['directors'] != null ? json['directors'].cast<String>() : [];
    _actors = json['actors'] != null ? json['actors'].cast<String>() : [];
    _singer = json['singer'] != null ? json['singer'].cast<String>() : [];
    if (json['music_director'] != null) {
      _musicDirector = [];
      // json['music_director'].forEach((v) {
      //   _musicDirector.add(Dynamic.fromJson(v));
      // });
    }
    if (json['choreographer'] != null) {
      _choreographer = [];
      // json['choreographer'].forEach((v) {
      //   _choreographer.add(Dynamic.fromJson(v));
      // });
    }
    _genre = json['genre'] != null ? json['genre'].cast<String>() : [];
    _duration = json['duration'];
    _ratings = json['ratings'];
    _publishYear = json['publish_year'];
    _status = json['status'];
  }
  String _type;
  String _id;
  String _title;
  String _description;
  String _uploadMusic;
  String _uploadTrailer;
  List<String> _audioLanguages;
  String _maturityRating;
  String _thumbnail;
  String _poster;
  String _amount;
  String _metaKeyword;
  String _metaDescription;
  List<String> _directors;
  List<String> _actors;
  List<String> _singer;
  List<dynamic> _musicDirector;
  List<dynamic> _choreographer;
  List<String> _genre;
  String _duration;
  String _ratings;
  String _publishYear;
  String _status;

  String get type => _type;
  String get id => _id;
  String get title => _title;
  String get description => _description;
  String get uploadMusic => _uploadMusic;
  String get uploadTrailer => _uploadTrailer;
  List<String> get audioLanguages => _audioLanguages;
  String get maturityRating => _maturityRating;
  String get thumbnail => _thumbnail;
  String get poster => _poster;
  String get amount => _amount;
  String get metaKeyword => _metaKeyword;
  String get metaDescription => _metaDescription;
  List<String> get directors => _directors;
  List<String> get actors => _actors;
  List<String> get singer => _singer;
  List<dynamic> get musicDirector => _musicDirector;
  List<dynamic> get choreographer => _choreographer;
  List<String> get genre => _genre;
  String get duration => _duration;
  String get ratings => _ratings;
  String get publishYear => _publishYear;
  String get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['upload_music'] = _uploadMusic;
    map['upload_trailer'] = _uploadTrailer;
    map['audio_languages'] = _audioLanguages;
    map['maturity_rating'] = _maturityRating;
    map['thumbnail'] = _thumbnail;
    map['poster'] = _poster;
    map['amount'] = _amount;
    map['meta_keyword'] = _metaKeyword;
    map['meta_description'] = _metaDescription;
    map['directors'] = _directors;
    map['actors'] = _actors;
    map['singer'] = _singer;
    if (_musicDirector != null) {
      map['music_director'] = _musicDirector.map((v) => v.toJson()).toList();
    }
    if (_choreographer != null) {
      map['choreographer'] = _choreographer.map((v) => v.toJson()).toList();
    }
    map['genre'] = _genre;
    map['duration'] = _duration;
    map['ratings'] = _ratings;
    map['publish_year'] = _publishYear;
    map['status'] = _status;
    return map;
  }

}