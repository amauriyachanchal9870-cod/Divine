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

class LeadershipMember {
  String? name;
  String? designation;
  String? email;
  String? pan;
  String? aadharId;
  String? linkedInUrl;
  String? photo;

  LeadershipMember({
    this.name,
    this.designation,
    this.email,
    this.pan,
    this.aadharId,
    this.linkedInUrl,
    this.photo,
  });

  factory LeadershipMember.fromJson(Map<String, dynamic> json) {
    return LeadershipMember(
      name: json['name']?.toString() ?? json['fullName']?.toString(),
      designation: json['designation']?.toString() ?? json['designationRole']?.toString() ?? json['role']?.toString(),
      email: json['email']?.toString(),
      pan: json['pan']?.toString(),
      aadharId: json['aadharId']?.toString() ?? json['aadhar']?.toString(),
      linkedInUrl: json['linkedInUrl']?.toString() ?? json['linkedIn']?.toString() ?? json['linkedin']?.toString(),
      photo: json['photo']?.toString() ?? json['image']?.toString() ?? json['profilePhoto']?.toString(),
    );
  }
}

class AwardItem {
  String? name;
  String? awardedBy;
  String? year;
  String? description;
  String? supportingDocument;

  AwardItem({
    this.name,
    this.awardedBy,
    this.year,
    this.description,
    this.supportingDocument,
  });

  factory AwardItem.fromJson(Map<String, dynamic> json) {
    return AwardItem(
      name: json['name']?.toString() ?? json['title']?.toString(),
      awardedBy: json['awardedBy']?.toString(),
      year: json['year']?.toString(),
      description: json['description']?.toString(),
      supportingDocument: json['supportingDocument']?.toString() ?? json['document']?.toString() ?? json['certificate']?.toString(),
    );
  }
}

class NgoDetailsModel {
  bool? status;
  NgoDetailsData? data;

  NgoDetailsModel({this.status, this.data});

  factory NgoDetailsModel.fromJson(Map<String, dynamic> json) {
    dynamic dataJson = json['data'] ?? json['ngo'] ?? json['user'] ?? json['profile'];
    if (dataJson == null && (json.containsKey('name') || json.containsKey('organizationName') || json.containsKey('_id'))) {
      dataJson = json;
    }

    NgoDetailsData? parsedData = dataJson != null && dataJson is Map<String, dynamic>
        ? NgoDetailsData.fromJson(dataJson)
        : null;

    if (parsedData != null) {
      if ((parsedData.reviews == null || parsedData.reviews!.isEmpty) && json['reviews'] != null && json['reviews'] is List) {
        parsedData.reviews = (json['reviews'] as List).map((e) => ReviewItem.fromJson(e)).toList();
      }
      if (json['reviewCount'] != null) {
        parsedData.reviewCount = int.tryParse(json['reviewCount'].toString()) ?? parsedData.reviewCount;
      }
    }

    return NgoDetailsModel(
      status: json['status'] ?? true,
      data: parsedData,
    );
  }
}

class NgoDetailsData {
  String? id;
  String? ngoId;
  String? name;
  String? logo;
  double? rating;
  int? reviewCount;
  List<ReviewItem>? reviews;
  String? impactStats;
  String? registrationNumber;
  String? contactPerson;
  String? email;
  String? phone;
  String? about;
  String? years;
  String? ourMission;
  String? briefProfile;
  String? role;
  String? registeredAddress;
  String? status;
  List<String>? activityProof;
  int? verifiedCampaignsCount;
  List<PayoutItem>? payoutHistory;
  List<String>? kycDocs;
  List<CampaignItem>? campaigns;
  List<String>? activityGallery;

  // Registration & profile fields
  String? organizationType;
  String? legalName;
  String? isRegisteredNonProfit;
  String? websiteUrl;
  String? bannerImage;
  String? registrationCertificate;
  String? addressCertificate;
  String? panNumber;
  String? panDocument;
  String? tanNumber;
  String? tanDocument;
  String? gstNumber;
  String? gstDocument;
  String? registration12A;
  String? certificate12A;
  bool? has12A;
  String? registration80G;
  String? certificate80G;
  bool? has80G;
  String? darpanNumber;
  String? darpanCertificate;
  bool? hasDarpan;
  String? csr1Number;
  String? csr1Certificate;
  bool? hasCSR1;
  String? fcraNumber;
  String? fcraCertificate;
  bool? hasFCRA;
  List<LeadershipMember>? leadership;
  dynamic directorsKeyManagement;
  dynamic formFillerDetails;
  String? authorizedPerson;
  String? designation;
  List<AwardItem>? awards;
  List<String>? causesSupported;
  String? purposeOfFundraising;
  dynamic csrFocusAreas;
  String? lastFinancialYearBudget;
  String? donorDatabaseStrength;
  String? employeeStrength;
  String? bankAccountHolder;
  String? bankName;
  String? bankBranch;
  String? bankAccountNumber;
  String? bankIFSC;
  String? cancelledChequeDoc;

  // Additional profile & verification fields
  bool? isVerified;
  String? verificationStatus;
  String? rejectionReason;
  dynamic moaAoaDocuments;
  String? authorityLetter;
  dynamic hasCrowdfundedBefore;
  String? crowdfundingPlatformsUsed;
  String? campaignPlanningTimeframe;
  dynamic declarations;
  bool? hasOtherRegistration;
  String? otherRegistrationName;
  String? otherRegistrationCertificate;
  String? csrObligation;
  String? csrAmountSpentPreviousYear;
  dynamic fundingPreferences;
  dynamic csrOfficerDetails;

  NgoDetailsData({
    this.id,
    this.ngoId,
    this.name,
    this.logo,
    this.rating,
    this.reviewCount,
    this.reviews,
    this.impactStats,
    this.registrationNumber,
    this.contactPerson,
    this.email,
    this.phone,
    this.about,
    this.years,
    this.ourMission,
    this.briefProfile,
    this.role,
    this.registeredAddress,
    this.status,
    this.activityProof,
    this.verifiedCampaignsCount,
    this.payoutHistory,
    this.kycDocs,
    this.campaigns,
    this.activityGallery,
    this.organizationType,
    this.legalName,
    this.isRegisteredNonProfit,
    this.websiteUrl,
    this.bannerImage,
    this.registrationCertificate,
    this.addressCertificate,
    this.panNumber,
    this.panDocument,
    this.tanNumber,
    this.tanDocument,
    this.gstNumber,
    this.gstDocument,
    this.registration12A,
    this.certificate12A,
    this.has12A,
    this.registration80G,
    this.certificate80G,
    this.has80G,
    this.darpanNumber,
    this.darpanCertificate,
    this.hasDarpan,
    this.csr1Number,
    this.csr1Certificate,
    this.hasCSR1,
    this.fcraNumber,
    this.fcraCertificate,
    this.hasFCRA,
    this.leadership,
    this.directorsKeyManagement,
    this.formFillerDetails,
    this.authorizedPerson,
    this.designation,
    this.awards,
    this.causesSupported,
    this.purposeOfFundraising,
    this.csrFocusAreas,
    this.lastFinancialYearBudget,
    this.donorDatabaseStrength,
    this.employeeStrength,
    this.bankAccountHolder,
    this.bankName,
    this.bankBranch,
    this.bankAccountNumber,
    this.bankIFSC,
    this.cancelledChequeDoc,
    this.isVerified,
    this.verificationStatus,
    this.rejectionReason,
    this.moaAoaDocuments,
    this.authorityLetter,
    this.hasCrowdfundedBefore,
    this.crowdfundingPlatformsUsed,
    this.campaignPlanningTimeframe,
    this.declarations,
    this.hasOtherRegistration,
    this.otherRegistrationName,
    this.otherRegistrationCertificate,
    this.csrObligation,
    this.csrAmountSpentPreviousYear,
    this.fundingPreferences,
    this.csrOfficerDetails,
  });

  factory NgoDetailsData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? userMap = json['user'] is Map<String, dynamic> ? json['user'] : null;
    Map<String, dynamic>? ngoMap = json['ngo'] is Map<String, dynamic> ? json['ngo'] : null;
    Map<String, dynamic>? profileMap = json['profile'] is Map<String, dynamic> ? json['profile'] : null;
    Map<String, dynamic>? bankMap = json['bankDetails'] is Map<String, dynamic> ? json['bankDetails'] : null;
    Map<String, dynamic>? certMap = json['certifications'] is Map<String, dynamic> ? json['certifications'] : null;

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
      final maps = [userMap, ngoMap, profileMap, bankMap, certMap];
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
      final maps = [userMap, ngoMap, profileMap, certMap];
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

    // Leadership parsing
    List<LeadershipMember> leadershipList = [];
    dynamic rawLeadership = json['directorsKeyManagement'] ??
        json['officials'] ??
        json['trustees'] ??
        json['leadership'] ??
        userMap?['directorsKeyManagement'] ??
        ngoMap?['directorsKeyManagement'] ??
        profileMap?['directorsKeyManagement'];

    if (rawLeadership != null && rawLeadership is List) {
      for (var item in rawLeadership) {
        if (item is Map<String, dynamic>) {
          leadershipList.add(LeadershipMember.fromJson(item));
        }
      }
    }

    final authPerson = parseString('authorizedPerson', ['contactPerson', 'contact_person']);
    final authDesig = parseString('designation', ['designationRole', 'role']);
    if (leadershipList.isEmpty && authPerson != null && authPerson.isNotEmpty) {
      leadershipList.add(
        LeadershipMember(
          name: authPerson,
          designation: authDesig ?? 'Authorized Representative',
          email: parseString('email'),
          linkedInUrl: parseString('linkedInUrl', ['linkedIn', 'linkedin']),
        ),
      );
    }

    // Awards parsing
    List<AwardItem> awardsList = [];
    dynamic rawAwards = json['awardsRecognitions'] ??
        json['awards'] ??
        json['awardList'] ??
        userMap?['awardsRecognitions'] ??
        ngoMap?['awardsRecognitions'] ??
        profileMap?['awardsRecognitions'];

    if (rawAwards != null && rawAwards is List) {
      for (var item in rawAwards) {
        if (item is Map<String, dynamic>) {
          awardsList.add(AwardItem.fromJson(item));
        }
      }
    }

    // Causes supported parsing
    List<String> causesList = [];
    dynamic rawCauses = json['csrFocusAreas'] ??
        json['causes'] ??
        json['categories'] ??
        json['purposeOfFundraising'] ??
        userMap?['csrFocusAreas'] ??
        ngoMap?['csrFocusAreas'] ??
        profileMap?['csrFocusAreas'];

    if (rawCauses is List) {
      for (var c in rawCauses) {
        if (c != null) {
          if (c is Map && c['name'] != null) {
            causesList.add(c['name'].toString().trim());
          } else if (c.toString().trim().isNotEmpty) {
            causesList.add(c.toString().trim());
          }
        }
      }
    } else if (rawCauses is String && rawCauses.trim().isNotEmpty) {
      final parts = rawCauses.split(RegExp(r'[,|/]'));
      for (var p in parts) {
        if (p.trim().isNotEmpty) {
          causesList.add(p.trim());
        }
      }
    }

    return NgoDetailsData(
      id: json['_id'] ?? json['id'] ?? userMap?['_id'] ?? ngoMap?['_id'],
      ngoId: json['ngoId'] ?? userMap?['ngoId'] ?? ngoMap?['ngoId'],
      name: parseString('name', ['organizationName', 'legalName']),
      logo: parseString('logo', ['profilePhoto', 'image', 'avatar']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] is int
          ? json['reviewCount']
          : int.tryParse(json['reviewCount']?.toString() ?? '0') ??
            (json['totalReviews'] is int
                ? json['totalReviews']
                : int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0),
      reviews: json['reviews'] != null && json['reviews'] is List
          ? (json['reviews'] as List).map((e) => ReviewItem.fromJson(e)).toList()
          : (json['reviewList'] != null && json['reviewList'] is List
              ? (json['reviewList'] as List).map((e) => ReviewItem.fromJson(e)).toList()
              : (json['review'] != null && json['review'] is List
                  ? (json['review'] as List).map((e) => ReviewItem.fromJson(e)).toList()
                  : [])),
      impactStats: parseString('impactStats'),
      registrationNumber: parseString('registrationNumber', ['regNumber', 'regNo']),
      contactPerson: parseString('contactPerson', ['authorizedPerson']),
      email: parseString('email'),
      phone: parseString('phone', ['mobile', 'phoneNumber']),
      about: parseString('about', ['description', 'briefProfile']),
      years: parseString('years', ['impactStats']),
      ourMission: parseString('ourMission', ['mission']),
      briefProfile: parseString('briefProfile'),
      role: parseString('role'),
      registeredAddress: parseString('registeredAddress', ['address', 'location']),
      status: parseString('status'),
      activityProof: json['activityProof'] != null
          ? List<String>.from(json['activityProof'])
          : [],
      verifiedCampaignsCount: json['verifiedCampaignsCount'] is int
          ? json['verifiedCampaignsCount']
          : int.tryParse(json['verifiedCampaignsCount']?.toString() ?? '0') ?? 0,
      payoutHistory: json['payoutHistory'] != null
          ? (json['payoutHistory'] as List).map((e) => PayoutItem.fromJson(e)).toList()
          : [],
      kycDocs: json['kycDocs'] != null
          ? List<String>.from(json['kycDocs'])
          : [],
      campaigns: json['campaigns'] != null
          ? (json['campaigns'] as List).map((e) => CampaignItem.fromJson(e)).toList()
          : [],
      activityGallery: json['activityGallery'] != null
          ? List<String>.from(json['activityGallery'])
          : [],
      organizationType: parseString('organizationType'),
      legalName: parseString('legalName', ['organizationName']),
      isRegisteredNonProfit: parseString('isRegisteredNonProfit', ['registeredType', 'typeOfNgo', 'organizationType']),
      websiteUrl: parseString('websiteUrl', ['website', 'url', 'webUrl', 'organizationWebsite', 'website_url']),
      bannerImage: parseString('bannerImage', ['coverImage', 'banner', 'backgroundImage']),
      registrationCertificate: parseString('registrationCertificate', ['addressCertificate', 'certificate']),
      addressCertificate: parseString('addressCertificate'),
      panNumber: parseString('panNumber', ['pan', 'panNo']),
      panDocument: parseString('panDocument', ['panImage', 'panDoc']),
      tanNumber: parseString('tanNumber', ['tan', 'tanNo']),
      tanDocument: parseString('tanDocument', ['tanImage', 'tanDoc']),
      gstNumber: parseString('gstNumber', ['gst', 'gstNo']),
      gstDocument: parseString('gstDocument', ['gstImage', 'gstDoc']),
      registration12A: parseString('registration12A', ['cert12aNumber', 'twelveANumber', 'reg12A']),
      certificate12A: parseString('certificate12A', ['cert12aImage', 'twelveADoc']),
      has12A: parseBoolVal('has12A', ['is12A']),
      registration80G: parseString('registration80G', ['cert80gNumber', 'eightyGNumber', 'reg80G']),
      certificate80G: parseString('certificate80G', ['cert80gImage', 'eightyGDoc']),
      has80G: parseBoolVal('has80G', ['is80G']),
      darpanNumber: parseString('darpanNumber', ['darpanId', 'darpanRegistration']),
      darpanCertificate: parseString('darpanCertificate', ['darpanImage', 'darpanDoc']),
      hasDarpan: parseBoolVal('hasDarpan'),
      csr1Number: parseString('csr1Number', ['csr1Registration']),
      csr1Certificate: parseString('csr1Certificate', ['csr1Image', 'csr1Doc']),
      hasCSR1: parseBoolVal('hasCSR1', ['hasCsr1']),
      fcraNumber: parseString('fcraNumber', ['fcraRegistration']),
      fcraCertificate: parseString('fcraCertificate', ['fcraImage', 'fcraDoc']),
      hasFCRA: parseBoolVal('hasFCRA', ['hasFcra']),
      leadership: leadershipList,
      directorsKeyManagement: rawLeadership,
      formFillerDetails: json['formFiller'] ?? json['formFillerDetails'],
      authorizedPerson: authPerson,
      designation: authDesig,
      awards: awardsList,
      causesSupported: causesList,
      purposeOfFundraising: parseString('purposeOfFundraising', ['purpose', 'fundraisingPurpose', 'purpose_of_fundraising']),
      csrFocusAreas: rawCauses,
      lastFinancialYearBudget: parseString('lastFinancialYearBudget', ['budget']),
      donorDatabaseStrength: parseString('donorDatabaseStrength'),
      employeeStrength: parseString('employeeStrength'),
      bankAccountHolder: parseString('bankAccountHolder', ['accountHolder', 'accountName']),
      bankName: parseString('bankName'),
      bankBranch: parseString('bankBranch', ['branchAddress']),
      bankAccountNumber: parseString('bankAccountNumber', ['accountNumber']),
      bankIFSC: parseString('bankIFSC', ['ifscCode', 'ifsc']),
      cancelledChequeDoc: parseString('cancelledChequeDoc', ['cancelledCheque']),
      isVerified: _parseBool(json['isVerified']) ??
          _parseBool(json['verified']) ??
          parseBoolVal('isVerified', ['verified']) ??
          (parseString('status')?.toLowerCase() == 'verified' || parseString('status')?.toLowerCase() == 'active'),
      verificationStatus: parseString('verificationStatus', ['verification_status']) ?? parseString('status'),
      rejectionReason: parseString('rejectionReason', ['rejection_reason']),
      moaAoaDocuments: json['moaAoaDocuments'] ??
          userMap?['moaAoaDocuments'] ??
          ngoMap?['moaAoaDocuments'] ??
          profileMap?['moaAoaDocuments'],
      authorityLetter: parseString('authorityLetter'),
      hasCrowdfundedBefore: json['hasCrowdfundedBefore'] ??
          userMap?['hasCrowdfundedBefore'] ??
          ngoMap?['hasCrowdfundedBefore'] ??
          profileMap?['hasCrowdfundedBefore'] ??
          bankMap?['hasCrowdfundedBefore'],
      crowdfundingPlatformsUsed: parseString('crowdfundingPlatformsUsed', ['crowdfundingPlatforms']),
      campaignPlanningTimeframe: parseString('campaignPlanningTimeframe'),
      declarations: json['declarations'] ??
          userMap?['declarations'] ??
          ngoMap?['declarations'] ??
          profileMap?['declarations'],
      hasOtherRegistration: parseBoolVal('hasOtherRegistration'),
      otherRegistrationName: parseString('otherRegistrationName'),
      otherRegistrationCertificate: parseString('otherRegistrationCertificate'),
      csrObligation: parseString('csrObligation'),
      csrAmountSpentPreviousYear: parseString('csrAmountSpentPreviousYear'),
      fundingPreferences: json['fundingPreferences'] ??
          userMap?['fundingPreferences'] ??
          ngoMap?['fundingPreferences'] ??
          profileMap?['fundingPreferences'],
      csrOfficerDetails: json['csrOfficerDetails'] ??
          userMap?['csrOfficerDetails'] ??
          ngoMap?['csrOfficerDetails'] ??
          profileMap?['csrOfficerDetails'],
    );
  }
}

class PayoutItem {
  String? payoutId;
  int? amount;
  String? status;
  String? requestedDate;
  String? id;

  PayoutItem({this.payoutId, this.amount, this.status, this.requestedDate, this.id});

  factory PayoutItem.fromJson(Map<String, dynamic> json) {
    return PayoutItem(
      payoutId: json['payoutId'],
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'],
      requestedDate: json['requestedDate'],
      id: json['_id'] ?? json['id'],
    );
  }
}

class CampaignItem {
  String? campaignId;
  String? title;
  String? goal;
  String? raised;
  String? status;
  String? id;

  CampaignItem({this.campaignId, this.title, this.goal, this.raised, this.status, this.id});

  factory CampaignItem.fromJson(Map<String, dynamic> json) {
    return CampaignItem(
      campaignId: json['campaignId'],
      title: json['title'],
      goal: json['goal'],
      raised: json['raised'],
      status: json['status'],
      id: json['_id'] ?? json['id'],
    );
  }
}
