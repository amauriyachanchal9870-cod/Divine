bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
  }
  if (value is num) return value != 0;
  return null;
}

class ProfileModel {
  bool? status;
  ProfileData? data;

  ProfileModel({this.status, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      status: _parseBool(json['status']),
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
    Map<String, dynamic>? userMap = json['user'] is Map<String, dynamic> ? json['user'] : null;
    Map<String, dynamic>? ngoMap = json['ngo'] is Map<String, dynamic> ? json['ngo'] : null;
    Map<String, dynamic>? profileMap = json['profile'] is Map<String, dynamic> ? json['profile'] : null;
    Map<String, dynamic>? dataMap = json['data'] is Map<String, dynamic> ? json['data'] : null;

    String? parseString(String key, [List<String>? altKeys]) {
      if (json[key] != null && json[key].toString().trim().isNotEmpty) {
        return json[key].toString().trim();
      }
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json[k] != null && json[k].toString().trim().isNotEmpty) {
            return json[k].toString().trim();
          }
        }
      }
      final maps = [userMap, ngoMap, profileMap, dataMap];
      for (var m in maps) {
        if (m != null) {
          if (m[key] != null && m[key].toString().trim().isNotEmpty) {
            return m[key].toString().trim();
          }
          if (altKeys != null) {
            for (var k in altKeys) {
              if (m[k] != null && m[k].toString().trim().isNotEmpty) {
                return m[k].toString().trim();
              }
            }
          }
        }
      }
      return null;
    }

    double? parseDouble(String key, [List<String>? altKeys]) {
      if (json[key] != null && json[key] is num) {
        return (json[key] as num).toDouble();
      }
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json[k] != null && json[k] is num) {
            return (json[k] as num).toDouble();
          }
        }
      }
      final maps = [userMap, ngoMap, profileMap, dataMap];
      for (var m in maps) {
        if (m != null) {
          if (m[key] != null && m[key] is num) {
            return (m[key] as num).toDouble();
          }
          if (altKeys != null) {
            for (var k in altKeys) {
              if (m[k] != null && m[k] is num) {
                return (m[k] as num).toDouble();
              }
            }
          }
        }
      }
      return null;
    }

    bool? parseBoolVal(String key, [List<String>? altKeys]) {
      if (json[key] != null) {
        return _parseBool(json[key]);
      }
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json[k] != null) {
            return _parseBool(json[k]);
          }
        }
      }
      final maps = [userMap, ngoMap, profileMap, dataMap];
      for (var m in maps) {
        if (m != null) {
          if (m[key] != null) {
            return _parseBool(m[key]);
          }
          if (altKeys != null) {
            for (var k in altKeys) {
              if (m[k] != null) {
                return _parseBool(m[k]);
              }
            }
          }
        }
      }
      return null;
    }

    List<dynamic>? parseList(String key, [List<String>? altKeys]) {
      if (json[key] != null && json[key] is List) {
        return List<dynamic>.from(json[key]);
      }
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json[k] != null && json[k] is List) {
            return List<dynamic>.from(json[k]);
          }
        }
      }
      final maps = [userMap, ngoMap, profileMap, dataMap];
      for (var m in maps) {
        if (m != null) {
          if (m[key] != null && m[key] is List) {
            return List<dynamic>.from(m[key]);
          }
          if (altKeys != null) {
            for (var k in altKeys) {
              if (m[k] != null && m[k] is List) {
                return List<dynamic>.from(m[k]);
              }
            }
          }
        }
      }
      return null;
    }

    return ProfileData(
      id: parseString('_id', ['id']),
      phone: parseString('phone', ['mobile', 'phoneNumber', 'contactNumber', 'contact']),
      role: parseString('role', ['userRole', 'type', 'accountType']),
      gender: parseString('gender'),
      profilePhoto: parseString('profilePhoto', ['logo', 'avatar', 'photo', 'imageUrl']),
      walletBalance: parseDouble('walletBalance', ['balance']),
      name: parseString('name', ['fullName', 'userName', 'ownerName']),
      organizationName: parseString('organizationName', ['orgName', 'ngoName', 'companyName']),
      logo: parseString('logo', ['profilePhoto', 'avatar', 'photo', 'imageUrl']),
      rating: parseDouble('rating'),
      impactStats: parseString('impactStats', ['about', 'description']),
      registeredAddress: parseString('registeredAddress', ['address', 'location']),
      addressCertificate: parseString('addressCertificate'),
      authorizedPerson: parseString('authorizedPerson'),
      designation: parseString('designation'),
      panNumber: parseString('panNumber'),
      panImage: parseString('panImage'),
      tanNumber: parseString('tanNumber'),
      tanImage: parseString('tanImage'),
      gstNumber: parseString('gstNumber'),
      gstDocument: parseString('gstDocument'),
      registration12A: parseString('registration12A'),
      certificate12A: parseString('certificate12A'),
      registration80G: parseString('registration80G'),
      certificate80G: parseString('certificate80G'),
      hasDarpan: parseBoolVal('hasDarpan'),
      darpanNumber: parseString('darpanNumber'),
      darpanCertificate: parseString('darpanCertificate'),
      hasCSR1: parseBoolVal('hasCSR1'),
      csr1Number: parseString('csr1Number'),
      csr1Certificate: parseString('csr1Certificate'),
      hasFCRA: parseBoolVal('hasFCRA'),
      fcraNumber: parseString('fcraNumber'),
      fcraCertificate: parseString('fcraCertificate'),
      hasOtherRegistration: parseBoolVal('hasOtherRegistration'),
      otherRegistrationName: parseString('otherRegistrationName'),
      otherRegistrationCertificate: parseString('otherRegistrationCertificate'),
      bankAccountHolder: parseString('bankAccountHolder', ['holderName']),
      bankName: parseString('bankName'),
      bankBranch: parseString('bankBranch'),
      bankAccountNumber: parseString('bankAccountNumber', ['accountNumber']),
      bankIFSC: parseString('bankIFSC', ['ifscCode', 'ifsc']),
      otp: parseString('otp'),
      otpExpiry: parseString('otpExpiry'),
      isProfileComplete: parseBoolVal('isProfileComplete'),
      createdAt: parseString('createdAt'),
      updatedAt: parseString('updatedAt'),
      email: parseString('email', ['userEmail', 'contactEmail']),
      couponsClaimed: parseList('couponsClaimed'),
      followers: parseList('followers'),
      followingNgos: parseList('followingNgos'),
      followingUsers: parseList('followingUsers'),
      referralCode: parseString('referralCode'),
      referredBy: parseString('referredBy'),
      searchHistory: parseList('searchHistory'),
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
