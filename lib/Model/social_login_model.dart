class SocialLoginModel {
  bool? status;
  String? message;
  String? token;
  bool? isProfileComplete;
  bool? isVerified;
  String? verificationStatus;
  bool? isUserExist;
  SocialUserData? data;

  SocialLoginModel({
    this.status,
    this.message,
    this.token,
    this.isProfileComplete,
    this.isVerified,
    this.verificationStatus,
    this.isUserExist,
    this.data,
  });

  factory SocialLoginModel.fromJson(Map<String, dynamic> json) {
    bool isSuccess = false;
    if (json['status'] is bool) {
      isSuccess = json['status'] == true;
    } else if (json['success'] is bool) {
      isSuccess = json['success'] == true;
    }

    String? tokenVal = json['token']?.toString();
    if (tokenVal == null && json['data'] is Map<String, dynamic>) {
      tokenVal = json['data']['token']?.toString();
    }

    bool? profileCompleteVal;
    if (json['isProfileComplete'] is bool) {
      profileCompleteVal = json['isProfileComplete'];
    } else if (json['data'] is Map<String, dynamic> && json['data']['isProfileComplete'] is bool) {
      profileCompleteVal = json['data']['isProfileComplete'];
    }

    bool? isUserExistVal;
    if (json['isUserExist'] is bool) {
      isUserExistVal = json['isUserExist'];
    } else if (json['data'] is Map<String, dynamic> && json['data']['isUserExist'] is bool) {
      isUserExistVal = json['data']['isUserExist'];
    } else if (json['isUserExist'] != null) {
      isUserExistVal = json['isUserExist'].toString() == "true";
    }

    bool? verifiedVal;
    if (json['verified'] is bool) {
      verifiedVal = json['verified'];
    } else if (json['data'] is Map<String, dynamic> && json['data']['verified'] is bool) {
      verifiedVal = json['data']['verified'];
    } else if (json['isVerified'] is bool) {
      verifiedVal = json['isVerified'];
    }

    SocialUserData? userData;
    if (json['data'] is Map<String, dynamic>) {
      if (json['data']['user'] is Map<String, dynamic>) {
        userData = SocialUserData.fromJson(json['data']['user']);
      } else {
        userData = SocialUserData.fromJson(json['data']);
      }
    }

    String? statusVal = json['verificationStatus']?.toString() ??
        json['verification_status']?.toString() ??
        userData?.verificationStatus ??
        (verifiedVal == true ? 'Verified' : (verifiedVal == false ? 'Pending' : null));

    return SocialLoginModel(
      status: isSuccess,
      message: json['message']?.toString(),
      token: tokenVal,
      isProfileComplete: profileCompleteVal ?? userData?.isProfileComplete,
      isVerified: verifiedVal ?? userData?.isVerified,
      verificationStatus: statusVal,
      isUserExist: isUserExistVal,
      data: userData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    map['token'] = token;
    map['isProfileComplete'] = isProfileComplete;
    map['isVerified'] = isVerified;
    map['verificationStatus'] = verificationStatus;
    map['isUserExist'] = isUserExist;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class SocialUserData {
  String? id;
  String? phone;
  String? name;
  String? email;
  String? gender;
  String? profilePhoto;
  String? role;
  bool? isVerified;
  String? verificationStatus;
  bool? isProfileComplete;

  SocialUserData({
    this.id,
    this.phone,
    this.name,
    this.email,
    this.gender,
    this.profilePhoto,
    this.role,
    this.isVerified,
    this.verificationStatus,
    this.isProfileComplete,
  });

  factory SocialUserData.fromJson(Map<String, dynamic> json) {
    return SocialUserData(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      phone: json['phone']?.toString(),
      name: json['name']?.toString() ?? json['displayName']?.toString(),
      email: json['email']?.toString(),
      gender: json['gender']?.toString(),
      profilePhoto: json['profilePhoto']?.toString() ?? json['photoUrl']?.toString() ?? json['avatar']?.toString(),
      role: json['role']?.toString() ?? json['userType']?.toString(),
      isVerified: json['verified'] ?? json['isVerified'],
      verificationStatus: json['verificationStatus']?.toString() ??
          json['verification_status']?.toString() ??
          (json['verified'] == true || json['isVerified'] == true ? 'Verified' : null),
      isProfileComplete: json['isProfileComplete'] is bool
          ? json['isProfileComplete']
          : (json['isProfileComplete']?.toString() == "true"),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['phone'] = phone;
    map['name'] = name;
    map['email'] = email;
    map['gender'] = gender;
    map['profilePhoto'] = profilePhoto;
    map['role'] = role;
    map['verified'] = isVerified;
    map['verificationStatus'] = verificationStatus;
    map['isProfileComplete'] = isProfileComplete;
    return map;
  }
}
