class VerifyOtpModel {
  bool? status;
  String? message;
  String? token;
  bool? isProfileComplete;
  bool? isVerified;
  UserData? data;

  VerifyOtpModel({
    this.status,
    this.message,
    this.token,
    this.isProfileComplete,
    this.isVerified,
    this.data,
  });

  VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    isProfileComplete = json['isProfileComplete'];
    isVerified = json['verified'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['token'] = token;
    data['isProfileComplete'] = isProfileComplete;
    data['verified'] = isVerified;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? id;
  String? phone;
  String? name;
  String? email;
  String? gender;
  String? profilePhoto;
  String? role;
  bool? isVerified;

  UserData({
    this.id,
    this.phone,
    this.name,
    this.email,
    this.gender,
    this.profilePhoto,
    this.role,
    this.isVerified,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    profilePhoto = json['profilePhoto'];
    role = json['role'];
    isVerified = json['verified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['name'] = name;
    data['email'] = email;
    data['gender'] = gender;
    data['profilePhoto'] = profilePhoto;
    data['role'] = role;
    data['verified'] = isVerified;
    return data;
  }
}
