import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:luit/models/profile_model.dart';
import 'package:http/http.dart';

class ProfileRequest{
  final baseUrl = "https://release.luit.co.in/api/";
  final endUrl = "profile";
  final logger = Logger(
    printer: PrettyPrinter(
      colors: true,
    ),
  );

  Future<ProfileModel> getProfileData(var id) async {
    Map<String, dynamic> body = {'id': id};
    ProfileModel profileModel;
    Response response = await post(Uri.parse(baseUrl + endUrl), body: body);
    logger.d(response.body);
    if (response.statusCode == 200) {
      profileModel = ProfileModel.fromJson(jsonDecode(response.body));
    }
    return profileModel;
  }
}