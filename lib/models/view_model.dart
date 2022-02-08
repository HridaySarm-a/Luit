// To parse this JSON data, do
//
//     final viewsModel = viewsModelFromJson(jsonString);

import 'dart:convert';

ViewsModel viewsModelFromJson(String str) => ViewsModel.fromJson(json.decode(str));

String viewsModelToJson(ViewsModel data) => json.encode(data.toJson());

class ViewsModel {
    ViewsModel({
        this.response,
        this.message,
        this.total,
    });

    String response;
    String message;
    int total;

    factory ViewsModel.fromJson(Map<String, dynamic> json) => ViewsModel(
        response: json["response"],
        message: json["message"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "response": response,
        "message": message,
        "total": total,
    };
}
