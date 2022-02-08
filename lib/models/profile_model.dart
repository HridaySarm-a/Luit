// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  ProfileModel({
    this.response,
    this.message,
    this.openScreenPaymentAllow,
    this.data,
  });

  String response;
  String message;
  bool openScreenPaymentAllow;
  List<Datum> data;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    response: json["response"],
    message: json["message"],
    openScreenPaymentAllow: json["open_screen_payment_allow"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "response": response,
    "message": message,
    "open_screen_payment_allow": openScreenPaymentAllow,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.id,
    this.name,
    this.image,
    this.dob,
    this.mobile,
    this.email,
    this.createdAt,
  });

  String id;
  String name;
  String image;
  String dob;
  String mobile;
  String email;
  DateTime createdAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    dob: json["dob"],
    mobile: json["mobile"],
    email: json["email"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "dob": dob,
    "mobile": mobile,
    "email": email,
    "created_at": createdAt.toIso8601String(),
  };
}
