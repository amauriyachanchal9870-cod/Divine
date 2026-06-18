class ProfileModel {
  bool? status;
  ProfileData? data;

  ProfileModel({this.status, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      status: json['status'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class ProfileData {
  String? id;
  String? phone;
  String? role;
  String? gender;
  String? profilePhoto;
  double? walletBalance;
  String? name;
  String? organizationName;
  String? logo;
  double? rating;
  String? impactStats;
  String? registeredAddress;
  String? addressCertificate;
  String? authorizedPerson;
  String? designation;
  String? panNumber;
  String? panImage;
  String? tanNumber;
  String? tanImage;
  String? gstNumber;
  String? gstDocument;
  String? registration12A;
  String? certificate12A;
  String? registration80G;
  String? certificate80G;
  bool? hasDarpan;
  String? darpanNumber;
  String? darpanCertificate;
  bool? hasCSR1;
  String? csr1Number;
  String? csr1Certificate;
  bool? hasFCRA;
  String? fcraNumber;
  String? fcraCertificate;
  bool? hasOtherRegistration;
  String? otherRegistrationName;
  String? otherRegistrationCertificate;
  String? bankAccountHolder;
  String? bankName;
  String? bankBranch;
  String? bankAccountNumber;
  String? bankIFSC;
  String? otp;
  String? otpExpiry;
  bool? isProfileComplete;
  String? createdAt;
  String? updatedAt;
  String? email;
  List<dynamic>? couponsClaimed;
  List<dynamic>? followers;
  List<dynamic>? followingNgos;
  List<dynamic>? followingUsers;
  String? referralCode;
  String? referredBy;
  List<dynamic>? searchHistory;

  ProfileData({
    this.id,
    this.phone,
    this.role,
    this.gender,
    this.profilePhoto,
    this.walletBalance,
    this.name,
    this.organizationName,
    this.logo,
    this.rating,
    this.impactStats,
    this.registeredAddress,
    this.addressCertificate,
    this.authorizedPerson,
    this.designation,
    this.panNumber,
    this.panImage,
    this.tanNumber,
    this.tanImage,
    this.gstNumber,
    this.gstDocument,
    this.registration12A,
    this.certificate12A,
    this.registration80G,
    this.certificate80G,
    this.hasDarpan,
    this.darpanNumber,
    this.darpanCertificate,
    this.hasCSR1,
    this.csr1Number,
    this.csr1Certificate,
    this.hasFCRA,
    this.fcraNumber,
    this.fcraCertificate,
    this.hasOtherRegistration,
    this.otherRegistrationName,
    this.otherRegistrationCertificate,
    this.bankAccountHolder,
    this.bankName,
    this.bankBranch,
    this.bankAccountNumber,
    this.bankIFSC,
    this.otp,
    this.otpExpiry,
    this.isProfileComplete,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.couponsClaimed,
    this.followers,
    this.followingNgos,
    this.followingUsers,
    this.referralCode,
    this.referredBy,
    this.searchHistory,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'],
      phone: json['phone'],
      role: json['role'],
      gender: json['gender'],
      profilePhoto: json['profilePhoto'],
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      name: json['name'],
      organizationName: json['organizationName'],
      logo: json['logo'],
      rating: (json['rating'] as num?)?.toDouble(),
      impactStats: json['impactStats'],
      registeredAddress: json['registeredAddress'],
      addressCertificate: json['addressCertificate'],
      authorizedPerson: json['authorizedPerson'],
      designation: json['designation'],
      panNumber: json['panNumber'],
      panImage: json['panImage'],
      tanNumber: json['tanNumber'],
      tanImage: json['tanImage'],
      gstNumber: json['gstNumber'],
      gstDocument: json['gstDocument'],
      registration12A: json['registration12A'],
      certificate12A: json['certificate12A'],
      registration80G: json['registration80G'],
      certificate80G: json['certificate80G'],
      hasDarpan: json['hasDarpan'],
      darpanNumber: json['darpanNumber'],
      darpanCertificate: json['darpanCertificate'],
      hasCSR1: json['hasCSR1'],
      csr1Number: json['csr1Number'],
      csr1Certificate: json['csr1Certificate'],
      hasFCRA: json['hasFCRA'],
      fcraNumber: json['fcraNumber'],
      fcraCertificate: json['fcraCertificate'],
      hasOtherRegistration: json['hasOtherRegistration'],
      otherRegistrationName: json['otherRegistrationName'],
      otherRegistrationCertificate: json['otherRegistrationCertificate'],
      bankAccountHolder: json['bankAccountHolder'],
      bankName: json['bankName'],
      bankBranch: json['bankBranch'],
      bankAccountNumber: json['bankAccountNumber'],
      bankIFSC: json['bankIFSC'],
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      isProfileComplete: json['isProfileComplete'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      email: json['email'],
      couponsClaimed: json['couponsClaimed'] != null ? List<dynamic>.from(json['couponsClaimed']) : null,
      followers: json['followers'] != null ? List<dynamic>.from(json['followers']) : null,
      followingNgos: json['followingNgos'] != null ? List<dynamic>.from(json['followingNgos']) : null,
      followingUsers: json['followingUsers'] != null ? List<dynamic>.from(json['followingUsers']) : null,
      referralCode: json['referralCode'],
      referredBy: json['referredBy'],
      searchHistory: json['searchHistory'] != null ? List<dynamic>.from(json['searchHistory']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'role': role,
      'gender': gender,
      'profilePhoto': profilePhoto,
      'walletBalance': walletBalance,
      'name': name,
      'organizationName': organizationName,
      'logo': logo,
      'rating': rating,
      'impactStats': impactStats,
      'registeredAddress': registeredAddress,
      'addressCertificate': addressCertificate,
      'authorizedPerson': authorizedPerson,
      'designation': designation,
      'panNumber': panNumber,
      'panImage': panImage,
      'tanNumber': tanNumber,
      'tanImage': tanImage,
      'gstNumber': gstNumber,
      'gstDocument': gstDocument,
      'registration12A': registration12A,
      'certificate12A': certificate12A,
      'registration80G': registration80G,
      'certificate80G': certificate80G,
      'hasDarpan': hasDarpan,
      'darpanNumber': darpanNumber,
      'darpanCertificate': darpanCertificate,
      'hasCSR1': hasCSR1,
      'csr1Number': csr1Number,
      'csr1Certificate': csr1Certificate,
      'hasFCRA': hasFCRA,
      'fcraNumber': fcraNumber,
      'fcraCertificate': fcraCertificate,
      'hasOtherRegistration': hasOtherRegistration,
      'otherRegistrationName': otherRegistrationName,
      'otherRegistrationCertificate': otherRegistrationCertificate,
      'bankAccountHolder': bankAccountHolder,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'bankAccountNumber': bankAccountNumber,
      'bankIFSC': bankIFSC,
      'otp': otp,
      'otpExpiry': otpExpiry,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'email': email,
      'couponsClaimed': couponsClaimed,
      'followers': followers,
      'followingNgos': followingNgos,
      'followingUsers': followingUsers,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'searchHistory': searchHistory,
    };
  }
}
