import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:luit/models/payment_model.dart';
import 'package:http/http.dart';

class PaymentRequest{
  final baseUrl = "https://release.luit.co.in/api/";
  final endUrl = "open-screen-payment";
  final logger = Logger(
    printer: PrettyPrinter(
      colors: true,
    ),
  );

  Future<PaymentModel> getPayment(var userId, var refNo, var amount) async {
    Map<String, dynamic> body = {'user_id': userId, 'ref_no': refNo, 'amount': amount.toString()};
    PaymentModel paymentModel;
    Response response = await post(Uri.parse(baseUrl + endUrl), body: body);
    logger.d(response.body);
    if (response.statusCode == 200) {
      paymentModel = PaymentModel.fromJson(jsonDecode(response.body));
    }
    return paymentModel;
  }
}