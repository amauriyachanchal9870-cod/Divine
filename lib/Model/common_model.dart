class CommonModel {
  bool? status;
  String? message;
  Map<String, dynamic>? data;

  CommonModel({this.status, this.message, this.data});

  CommonModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }
}
