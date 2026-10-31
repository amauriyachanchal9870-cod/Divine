import 'review_model.dart';

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
  bool? isVerified;
  String? verificationStatus;
  String? rejectionReason;

  ProfileModel({
    this.status,
    this.data,
    this.isVerified,
    this.verificationStatus,
    this.rejectionReason,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    dynamic dataJson = json['data'] ?? json['ngo'] ?? json['user'] ?? json['profile'];
    if (dataJson == null && (json.containsKey('name') || json.containsKey('organizationName') || json.containsKey('_id'))) {
      dataJson = json;
    }
    ProfileData? parsedData = dataJson != null && dataJson is Map<String, dynamic> ? ProfileData.fromJson(dataJson) : null;
    bool? verified = _parseBool(json['verified']) ?? _parseBool(json['isVerified']) ?? parsedData?.isVerified;
    String? statusStr = json['verificationStatus']?.toString() ?? json['verification_status']?.toString() ?? parsedData?.verificationStatus;
    if (statusStr == null && verified != null) {
      statusStr = verified ? 'Verified' : 'Pending';
    }
    String? reasonStr = json['rejectionReason']?.toString() ?? json['rejection_reason']?.toString() ?? parsedData?.rejectionReason;

    return ProfileModel(
      status: _parseBool(json['status']) ?? true,
      data: parsedData,
      isVerified: verified,
      verificationStatus: statusStr,
      rejectionReason: reasonStr,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['verified'] = isVerified;
    map['verificationStatus'] = verificationStatus;
    map['rejectionReason'] = rejectionReason;
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
  int? reviewCount;
  List<ReviewItem>? reviews;
  String? impactStats;
  String? years;
  String? about;
  String? ourMission;
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
  
  // Newly introduced NGO & Corporate fields
  String? organizationType;
  String? legalName;
  String? websiteUrl;
  String? briefProfile;
  String? isRegisteredNonProfit;
  String? isRegisteredCompany;
  String? csrObligation;
  String? csrAmountSpentPreviousYear;
  dynamic csrFocusAreas;
  dynamic fundingPreferences;
  dynamic csrOfficerDetails;
  dynamic directorsKeyManagement;
  dynamic formFillerDetails;
  String? lastFinancialYearBudget;
  String? donorDatabaseStrength;
  String? employeeStrength;
  dynamic hasCrowdfundedBefore;
  String? crowdfundingPlatformsUsed;
  String? campaignPlanningTimeframe;
  String? purposeOfFundraising;
  dynamic awardsRecognitions;
  dynamic declarations;
  String? cancelledChequeDoc;
  bool? pushNotification;
  dynamic moaAoaDocuments;
  String? authorityLetter;
  bool? isVerified;
  String? verificationStatus;
  String? rejectionReason;

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
    this.reviewCount,
    this.reviews,
    this.impactStats,
    this.years,
    this.about,
    this.ourMission,
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
    this.organizationType,
    this.legalName,
    this.websiteUrl,
    this.briefProfile,
    this.isRegisteredNonProfit,
    this.isRegisteredCompany,
    this.csrObligation,
    this.csrAmountSpentPreviousYear,
    this.csrFocusAreas,
    this.fundingPreferences,
    this.csrOfficerDetails,
    this.directorsKeyManagement,
    this.formFillerDetails,
    this.lastFinancialYearBudget,
    this.donorDatabaseStrength,
    this.employeeStrength,
    this.hasCrowdfundedBefore,
    this.crowdfundingPlatformsUsed,
    this.campaignPlanningTimeframe,
    this.purposeOfFundraising,
    this.awardsRecognitions,
    this.declarations,
    this.cancelledChequeDoc,
    this.pushNotification,
    this.moaAoaDocuments,
    this.authorityLetter,
    this.isVerified,
    this.verificationStatus,
    this.rejectionReason,
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

    int? parseInt(String key, [List<String>? altKeys]) {
      if (json[key] != null && json[key] is num) {
        return (json[key] as num).toInt();
      }
      if (json[key] != null) {
        final parsed = int.tryParse(json[key].toString().trim());
        if (parsed != null) return parsed;
      }
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json[k] != null && json[k] is num) {
            return (json[k] as num).toInt();
          }
          if (json[k] != null) {
            final parsed = int.tryParse(json[k].toString().trim());
            if (parsed != null) return parsed;
          }
        }
      }
      final maps = [userMap, ngoMap, profileMap, dataMap];
      for (var m in maps) {
        if (m != null) {
          if (m[key] != null && m[key] is num) {
            return (m[key] as num).toInt();
          }
          if (m[key] != null) {
            final parsed = int.tryParse(m[key].toString().trim());
            if (parsed != null) return parsed;
          }
          if (altKeys != null) {
            for (var k in altKeys) {
              if (m[k] != null && m[k] is num) {
                return (m[k] as num).toInt();
              }
              if (m[k] != null) {
                final parsed = int.tryParse(m[k].toString().trim());
                if (parsed != null) return parsed;
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
      if (json[key] != null) {
        final parsed = double.tryParse(json[key].toString().trim());
        if (parsed != null) return parsed;
      }
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json[k] != null && json[k] is num) {
            return (json[k] as num).toDouble();
          }
          if (json[k] != null) {
            final parsed = double.tryParse(json[k].toString().trim());
            if (parsed != null) return parsed;
          }
        }
      }
      final maps = [userMap, ngoMap, profileMap, dataMap];
      for (var m in maps) {
        if (m != null) {
          if (m[key] != null && m[key] is num) {
            return (m[key] as num).toDouble();
          }
          if (m[key] != null) {
            final parsed = double.tryParse(m[key].toString().trim());
            if (parsed != null) return parsed;
          }
          if (altKeys != null) {
            for (var k in altKeys) {
              if (m[k] != null && m[k] is num) {
                return (m[k] as num).toDouble();
              }
              if (m[k] != null) {
                final parsed = double.tryParse(m[k].toString().trim());
                if (parsed != null) return parsed;
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

    List<ReviewItem>? parseReviews(String key, [List<String>? altKeys]) {
      final list = parseList(key, altKeys);
      if (list != null) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((x) => ReviewItem.fromJson(x))
            .toList();
      }
      return null;
    }

    final parsedPhoto = parseString('profilePhoto', ['profile_photo', 'logo', 'logoUrl', 'logo_url', 'photoUrl', 'photo_url', 'avatar', 'photo', 'imageUrl', 'image', 'userImage', 'profileImage', 'ngoLogo', 'user_image', 'userLogo']);
    final parsedLogo = parseString('logo', ['profilePhoto', 'profile_photo', 'logoUrl', 'logo_url', 'photoUrl', 'photo_url', 'avatar', 'photo', 'imageUrl', 'image', 'userImage', 'profileImage', 'ngoLogo', 'user_image', 'userLogo']);
    final resolvedPhoto = parsedPhoto ?? parsedLogo;
    final resolvedLogo = parsedLogo ?? parsedPhoto;

    return ProfileData(
      id: parseString('_id', ['id']),
      phone: parseString('phone', ['mobile', 'phoneNumber', 'contactNumber', 'contact']),
      role: parseString('role', ['userRole', 'type', 'accountType']),
      gender: parseString('gender'),
      profilePhoto: resolvedPhoto,
      walletBalance: parseDouble('walletBalance', ['balance', 'wallet_balance', 'walletAmount', 'availableBalance']),
      name: parseString('name', ['fullName', 'userName', 'ownerName']),
      organizationName: parseString('organizationName', ['orgName', 'ngoName', 'companyName']),
      logo: resolvedLogo,
      rating: parseDouble('rating'),
      reviewCount: parseInt('reviewCount', ['totalReviews', 'reviewsCount']),
      reviews: parseReviews('reviews'),
      impactStats: parseString('impactStats', ['impact']),
      years: parseString('years', ['yearsOfExperience', 'experience']),
      about: parseString('about', ['description']),
      ourMission: parseString('ourMission', ['mission']),
      registeredAddress: parseString('registeredAddress', ['address', 'location']),
      addressCertificate: parseString('addressCertificate', ['registrationCertificate', 'addressDoc', 'registrationDoc', 'certificate']),
      authorizedPerson: parseString('authorizedPerson', ['contactPerson', 'fillerName']),
      designation: parseString('designation', ['designationRole']),
      panNumber: parseString('panNumber'),
      panImage: parseString('panImage', ['panDocument', 'panDoc', 'panCertificate']),
      tanNumber: parseString('tanNumber', ['tan']),
      tanImage: parseString('tanImage', ['tanDocument', 'tanDoc', 'tanCertificate']),
      gstNumber: parseString('gstNumber', ['gst', 'gstin']),
      gstDocument: parseString('gstDocument', ['gstDoc', 'gstImage', 'gstCertificate']),
      registration12A: parseString('registration12A'),
      certificate12A: parseString('certificate12A', ['cert12aImage', 'cert12aDoc', 'certificate12aDoc', 'registration12ADocument']),
      registration80G: parseString('registration80G'),
      certificate80G: parseString('certificate80G', ['cert80gImage', 'cert80gDoc', 'certificate80gDoc', 'registration80GDocument']),
      hasDarpan: parseBoolVal('hasDarpan'),
      darpanNumber: parseString('darpanNumber'),
      darpanCertificate: parseString('darpanCertificate', ['darpanImage', 'darpanDoc', 'darpanDocFile']),
      hasCSR1: parseBoolVal('hasCSR1'),
      csr1Number: parseString('csr1Number'),
      csr1Certificate: parseString('csr1Certificate', ['csr1Image', 'csr1Doc', 'csr1DocFile']),
      hasFCRA: parseBoolVal('hasFCRA'),
      fcraNumber: parseString('fcraNumber'),
      fcraCertificate: parseString('fcraCertificate', ['fcraImage', 'fcraDoc', 'fcraDocFile']),
      hasOtherRegistration: parseBoolVal('hasOtherRegistration'),
      otherRegistrationName: parseString('otherRegistrationName'),
      otherRegistrationCertificate: parseString('otherRegistrationCertificate'),
      bankAccountHolder: parseString('bankAccountHolder', ['holderName', 'accountHolderName', 'accountName']),
      bankName: parseString('bankName'),
      bankBranch: parseString('bankBranch', ['branchAddress']),
      bankAccountNumber: parseString('bankAccountNumber', ['accountNumber', 'accountNo']),
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
      organizationType: parseString('organizationType'),
      legalName: parseString('legalName'),
      websiteUrl: parseString('websiteUrl', ['website']),
      briefProfile: parseString('briefProfile', ['description']),
      isRegisteredNonProfit: parseString('isRegisteredNonProfit'),
      isRegisteredCompany: parseString('isRegisteredCompany', ['companyRegistrationType', 'companyType']) ??
          (parseString('organizationType')?.toLowerCase() == 'corporate' ? parseString('isRegisteredNonProfit') : null),
      csrObligation: parseString('csrObligation'),
      csrAmountSpentPreviousYear: parseString('csrAmountSpentPreviousYear', ['csrAmountSpent']),
      csrFocusAreas: json['csrFocusAreas'] ?? userMap?['csrFocusAreas'] ?? ngoMap?['csrFocusAreas'] ?? dataMap?['csrFocusAreas'],
      fundingPreferences: json['fundingPreferences'] ?? json['fundingPreference'] ?? userMap?['fundingPreferences'] ?? userMap?['fundingPreference'] ?? ngoMap?['fundingPreferences'] ?? ngoMap?['fundingPreference'] ?? dataMap?['fundingPreferences'],
      csrOfficerDetails: json['csrOfficerDetails'] ?? json['csrOfficer'] ?? userMap?['csrOfficerDetails'] ?? userMap?['csrOfficer'] ?? ngoMap?['csrOfficerDetails'] ?? ngoMap?['csrOfficer'] ?? dataMap?['csrOfficerDetails'],
      directorsKeyManagement: json['directorsKeyManagement'] ?? json['leadership'] ?? json['officials'] ?? userMap?['directorsKeyManagement'] ?? userMap?['leadership'] ?? userMap?['officials'] ?? ngoMap?['directorsKeyManagement'] ?? ngoMap?['leadership'] ?? ngoMap?['officials'] ?? dataMap?['directorsKeyManagement'],
      formFillerDetails: json['formFillerDetails'] ?? json['formFiller'] ?? json['fillerDetails'] ?? userMap?['formFillerDetails'] ?? userMap?['formFiller'] ?? userMap?['fillerDetails'] ?? ngoMap?['formFillerDetails'] ?? ngoMap?['formFiller'] ?? ngoMap?['fillerDetails'] ?? dataMap?['formFillerDetails'],
      lastFinancialYearBudget: parseString('lastFinancialYearBudget', ['budget']),
      donorDatabaseStrength: parseString('donorDatabaseStrength', ['donorStrength']),
      employeeStrength: parseString('employeeStrength'),
      hasCrowdfundedBefore: json['hasCrowdfundedBefore'] ?? userMap?['hasCrowdfundedBefore'] ?? ngoMap?['hasCrowdfundedBefore'] ?? dataMap?['hasCrowdfundedBefore'],
      crowdfundingPlatformsUsed: parseString('crowdfundingPlatformsUsed', ['crowdfundingPlatform']),
      campaignPlanningTimeframe: parseString('campaignPlanningTimeframe', ['timeframe']),
      purposeOfFundraising: parseString('purposeOfFundraising', ['causesSupported']),
      awardsRecognitions: json['awardsRecognitions'] ?? json['awards'] ?? userMap?['awardsRecognitions'] ?? userMap?['awards'] ?? ngoMap?['awardsRecognitions'] ?? ngoMap?['awards'] ?? dataMap?['awardsRecognitions'],
      declarations: json['declarations'] ?? json['complianceDeclarations'] ?? userMap?['declarations'] ?? userMap?['complianceDeclarations'] ?? ngoMap?['declarations'] ?? dataMap?['declarations'],
      cancelledChequeDoc: parseString('cancelledChequeDoc', ['cancelledCheque', 'chequeDoc', 'passbookImage', 'passbookDoc']),
      pushNotification: parseBoolVal('pushNotification'),
      moaAoaDocuments: json['moaAoaDocuments'] ?? json['moaDocuments'] ?? json['trustDeedDocuments'],
      authorityLetter: parseString('authorityLetter', ['authorityLetterImage', 'authorityLetterDoc', 'boardResolution']) ??
          (json['formFillerDetails'] is Map ? json['formFillerDetails']['authorityLetter']?.toString() : null) ??
          (json['formFiller'] is Map ? json['formFiller']['authorityLetter']?.toString() : null),
      isVerified: parseBoolVal('verified', ['isVerified']),
      verificationStatus: parseString('verificationStatus', ['verification_status']),
      rejectionReason: parseString('rejectionReason', ['rejection_reason']),
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
      'reviewCount': reviewCount,
      'reviews': reviews?.map((x) => x.toJson()).toList(),
      'impactStats': impactStats,
      'years': years,
      'about': about,
      'ourMission': ourMission,
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
      'organizationType': organizationType,
      'legalName': legalName,
      'websiteUrl': websiteUrl,
      'briefProfile': briefProfile,
      'isRegisteredNonProfit': isRegisteredNonProfit,
      'isRegisteredCompany': isRegisteredCompany,
      'csrObligation': csrObligation,
      'csrAmountSpentPreviousYear': csrAmountSpentPreviousYear,
      'csrFocusAreas': csrFocusAreas,
      'fundingPreferences': fundingPreferences,
      'csrOfficerDetails': csrOfficerDetails,
      'directorsKeyManagement': directorsKeyManagement,
      'formFillerDetails': formFillerDetails,
      'lastFinancialYearBudget': lastFinancialYearBudget,
      'donorDatabaseStrength': donorDatabaseStrength,
      'employeeStrength': employeeStrength,
      'hasCrowdfundedBefore': hasCrowdfundedBefore,
      'crowdfundingPlatformsUsed': crowdfundingPlatformsUsed,
      'campaignPlanningTimeframe': campaignPlanningTimeframe,
      'purposeOfFundraising': purposeOfFundraising,
      'awardsRecognitions': awardsRecognitions,
      'declarations': declarations,
      'cancelledChequeDoc': cancelledChequeDoc,
      'pushNotification': pushNotification,
      'moaAoaDocuments': moaAoaDocuments,
      'authorityLetter': authorityLetter,
      'isVerified': isVerified,
      'verified': isVerified,
      'verificationStatus': verificationStatus,
      'rejectionReason': rejectionReason,
    };
  }
}
