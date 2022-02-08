// To parse this JSON data, do
//
//     final settingsModel = settingsModelFromJson(jsonString);

import 'dart:convert';

SettingsModel settingsModelFromJson(String str) => SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
  SettingsModel({
    this.response,
    this.message,
    this.data,
  });

  String response;
  String message;
  List<Datum> data;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    response: json["response"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "response": response,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.settingsId,
    this.featuresName,
    this.value,
    this.description,
    this.icon,
    this.status,
  });

  String settingsId;
  String featuresName;
  String value;
  String description;
  String icon;
  String status;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    settingsId: json["settings_id"],
    featuresName: json["features_name"],
    value: json["value"],
    description: json["description"],
    icon: json["icon"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "settings_id": settingsId,
    "features_name": featuresName,
    "value": value,
    "description": description,
    "icon": icon,
    "status": status,
  };
}
