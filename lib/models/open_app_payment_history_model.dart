class OpenAppPaymentHistoryModel {
  String response;
  String message;
  List<Data> data;

  OpenAppPaymentHistoryModel({this.response, this.message, this.data});

  OpenAppPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    response = json['response'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response'] = this.response;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String dbId;
  String date;
  String amount;
  String refNo;

  Data({this.dbId, this.date, this.amount, this.refNo});

  Data.fromJson(Map<String, dynamic> json) {
    dbId = json['db_id'];
    date = json['date'];
    amount = json['amount'];
    refNo = json['ref_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['db_id'] = this.dbId;
    data['date'] = this.date;
    data['amount'] = this.amount;
    data['ref_no'] = this.refNo;
    return data;
  }
}
