class ProfileSetupModel {
  bool? status;
  String? message;
  ProfileData? data;

  ProfileSetupModel({this.status, this.message, this.data});

  ProfileSetupModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? id;
  String? phone;
  String? name;
  String? email;
  String? gender;
  String? profilePhoto;
  bool? isProfileComplete;

  ProfileData({
    this.id,
    this.phone,
    this.name,
    this.email,
    this.gender,
    this.profilePhoto,
    this.isProfileComplete,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    profilePhoto = json['profilePhoto'];
    isProfileComplete = json['isProfileComplete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['name'] = name;
    data['email'] = email;
    data['gender'] = gender;
    data['profilePhoto'] = profilePhoto;
    data['isProfileComplete'] = isProfileComplete;
    return data;
  }
}
