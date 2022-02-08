import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:luit/models/open_app_payment_history_model.dart';
import 'package:http/http.dart';

class OpenAppPaymentHistoryRequest{
  final baseUrl = "https://release.luit.co.in/api/";
  final endUrl = "open-screen-payment-history";
  final logger = Logger(
    printer: PrettyPrinter(
      colors: true,
    ),
  );

  Future<OpenAppPaymentHistoryModel> getOpenPaymentHistory(var id) async {
    Map<String, dynamic> body = {'user_id': id};
    OpenAppPaymentHistoryModel openAppPaymentHistoryModel;
    Response response = await post(Uri.parse(baseUrl + endUrl), body: body);
    logger.d(response.body);
    if (response.statusCode == 200) {
      openAppPaymentHistoryModel = OpenAppPaymentHistoryModel.fromJson(jsonDecode(response.body));
    }
    return openAppPaymentHistoryModel;
  }
}