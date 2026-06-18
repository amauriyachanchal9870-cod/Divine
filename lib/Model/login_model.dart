class LoginModel {
  bool? status;
  String? message;
  bool? isUserExist;
  String? phone;
  String? otp;

  LoginModel({
    this.status,
    this.message,
    this.isUserExist,
    this.phone,
    this.otp,
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    isUserExist = json['isUserExist'];
    phone = json['phone'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['isUserExist'] = isUserExist;
    data['phone'] = phone;
    data['otp'] = otp;
    return data;
  }
}
