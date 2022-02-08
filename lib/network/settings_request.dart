import 'dart:convert';

import 'package:luit/models/settings_model.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart';

class SettingsRequest {
  //final Dio _dio = Dio();
  final logger = Logger(
    printer: PrettyPrinter(
      colors: true,
    ),
  );

  final baseUrl = "https://release.luit.co.in/api/";
  final endUrl = "settings";


  Future<SettingsModel> getSettingsModel() async {
    SettingsModel settingsModel;
    Response response = await get(Uri.parse(baseUrl + endUrl));
    logger.d(response.body);
    if (response.statusCode == 200) {
      settingsModel = SettingsModel.fromJson(jsonDecode(response.body));
    }
    return settingsModel;
  }
}
