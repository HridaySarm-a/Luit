// To parse this JSON data, do
//
//     final viewsSuccessModel = viewsSuccessModelFromJson(jsonString);

import 'dart:convert';

ViewsSuccessModel viewsSuccessModelFromJson(String str) => ViewsSuccessModel.fromJson(json.decode(str));

String viewsSuccessModelToJson(ViewsSuccessModel data) => json.encode(data.toJson());

class ViewsSuccessModel {
    ViewsSuccessModel({
        this.response,
        this.message,
        this.total,
    });

    String response;
    String message;
    int total;

    factory ViewsSuccessModel.fromJson(Map<String, dynamic> json) => ViewsSuccessModel(
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
