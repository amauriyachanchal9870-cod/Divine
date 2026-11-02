import '../Utilities/helper.dart';

class CampaignDetailsModel {
  bool? status;
  CampaignDetailsData? data;

  CampaignDetailsModel({this.status, this.data});

  factory CampaignDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final bool isSuccess = rawStatus == true ||
        rawStatus == 'Live' ||
        rawStatus == 'true' ||
        rawStatus == 'success' ||
        (rawStatus != false && json['data'] != null);

    return CampaignDetailsModel(
      status: isSuccess,
      data: json['data'] != null
          ? CampaignDetailsData.fromJson(json['data'])
          : CampaignDetailsData.fromJson(json),
    );
  }
}

class BankDetails {
  String? holderName;
  String? accountNumber;
  String? bankName;
  String? ifscCode;

  BankDetails({
    this.holderName,
    this.accountNumber,
    this.bankName,
    this.ifscCode,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      holderName: json['holderName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      bankName: json['bankName']?.toString(),
      ifscCode: json['ifscCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holderName': holderName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'ifscCode': ifscCode,
    };
  }
}

class CampaignDetailsData {
  String? sId;
  String? campaignId;
  String? title;
  String? user;
  String? userId;
  String? category;
  String? imageUrl;
  String? fundraiserImage;
  List<String>? images;
  int? donorsCount;
  int? daysLeft;
  String? description;
  String? goal;
  String? raised;
  String? oneTimeOrMonthly;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<RecentDonor>? recentDonors;
  BankDetails? bankDetails;
  String? endDate;
  String? video;
  List<String>? documents;
  List<String>? verificationDocs;
  bool? isVerified;
  bool? isActive;
  String? verificationStatus;
  String? rejectionReason;
  String? mobile;
  String? email;

  CampaignDetailsData({
    this.sId,
    this.campaignId,
    this.title,
    this.user,
    this.userId,
    this.category,
    this.imageUrl,
    this.fundraiserImage,
    this.images,
    this.donorsCount,
    this.daysLeft,
    this.description,
    this.goal,
    this.raised,
    this.oneTimeOrMonthly,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.recentDonors,
    this.bankDetails,
    this.endDate,
    this.video,
    this.documents,
    this.verificationDocs,
    this.isVerified,
    this.isActive,
    this.verificationStatus,
    this.rejectionReason,
    this.mobile,
    this.email,
  });

  factory CampaignDetailsData.fromJson(Map<String, dynamic> json) {
    final dynamic verifiedVal = json['is_verified'] ?? json['isVerified'] ?? json['verify'] ?? json['verified'];
    final bool parsedVerified = verifiedVal == true ||
        verifiedVal?.toString().toLowerCase() == 'true' ||
        json['verificationStatus']?.toString().toLowerCase() == 'approved';

    final dynamic activeVal = json['isActive'] ?? json['is_active'] ?? json['active'] ?? json['activate'] ?? json['activated'];
    final bool parsedActive = activeVal != null
        ? (activeVal == true || activeVal.toString().toLowerCase() == 'true')
        : (json['status']?.toString().toLowerCase() != 'inactive');

    return CampaignDetailsData(
      sId: json['_id'],
      campaignId: json['campaignId'],
      title: json['title'],
      user: json['user'] is Map
          ? (json['user']['name'] ?? json['user']['userName'] ?? json['user']['_id']?.toString())
          : json['user']?.toString(),
      userId: (json['userId'] ??
          (json['user'] is Map
              ? json['user']['_id']
              : (json['user'] is String ? json['user'] : null)))?.toString(),
      category: json['category'],
      imageUrl: json['imageUrl'],
      fundraiserImage: json['fundraiserImage'] ?? json['fundraiser_image'] ?? json['fundraiserPhoto'] ?? json['userImage'] ?? json['userProfile']?['profilePhoto'],
      images: json['images'] != null && json['images'] is List
          ? List<String>.from((json['images'] as List).map((x) => x.toString()))
          : (json['imageUrls'] != null && json['imageUrls'] is List
              ? List<String>.from((json['imageUrls'] as List).map((x) => x.toString()))
              : []),
      donorsCount: json['donorsCount'] is int ? json['donorsCount'] : int.tryParse(json['donorsCount']?.toString() ?? '0') ?? 0,
      daysLeft: json['daysLeft'] is int ? json['daysLeft'] : int.tryParse(json['daysLeft']?.toString() ?? '0') ?? 0,
      description: json['description'],
      goal: json['goal']?.toString(),
      raised: json['raised']?.toString(),
      oneTimeOrMonthly: json['oneTimeOrMonthly'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      recentDonors: (json['recentDonors'] ?? json['recent_donors'] ?? json['donorsList']) != null
          ? ((json['recentDonors'] ?? json['recent_donors'] ?? json['donorsList']) as List)
              .map((e) => RecentDonor.fromJson(e))
              .toList()
          : [],
      bankDetails: json['bankDetails'] != null ? BankDetails.fromJson(json['bankDetails']) : null,
      endDate: json['endDate']?.toString(),
      video: json['video']?.toString(),
      documents: (json['documents'] ?? json['medicalDocs'] ?? json['medical_docs']) != null &&
              (json['documents'] ?? json['medicalDocs'] ?? json['medical_docs']) is List
          ? List<String>.from(((json['documents'] ?? json['medicalDocs'] ?? json['medical_docs']) as List).map((x) => x.toString()))
          : [],
      verificationDocs: (json['verificationDocs'] ?? json['identityDocs'] ?? json['verification_docs'] ?? json['identity_docs']) != null &&
              (json['verificationDocs'] ?? json['identityDocs'] ?? json['verification_docs'] ?? json['identity_docs']) is List
          ? List<String>.from(((json['verificationDocs'] ?? json['identityDocs'] ?? json['verification_docs'] ?? json['identity_docs']) as List).map((x) => x.toString()))
          : [],
      isVerified: parsedVerified,
      isActive: parsedActive,
      verificationStatus: (json['verificationStatus'] ?? json['verification_status'])?.toString(),
      rejectionReason: (json['rejection_reason'] ?? json['rejectionReason'])?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  bool get isCampaignVerified => isVerified == true;
  bool get isCampaignActive => isActive ?? (status?.toLowerCase() != 'inactive');
  bool get isRejected {
    final vStatus = verificationStatus?.toString().toLowerCase().trim() ?? '';
    final sStatus = status?.toString().toLowerCase().trim() ?? '';
    return vStatus == 'rejected' ||
        vStatus == 'reject' ||
        sStatus == 'rejected' ||
        sStatus == 'reject';
  }

  List<String> get allImages {
    final list = <String>[];
    if (images != null && images!.isNotEmpty) {
      for (var img in images!) {
        final trimmed = img.trim();
        if (trimmed.isNotEmpty && !list.contains(trimmed)) {
          list.add(trimmed);
        }
      }
    }
    if (list.isEmpty && imageUrl != null && imageUrl!.trim().isNotEmpty) {
      list.add(imageUrl!.trim());
    }
    return list;
  }

  List<String> get allDocuments {
    final list = <String>[];
    if (documents != null) {
      for (var doc in documents!) {
        final trimmed = doc.trim();
        if (trimmed.isNotEmpty && !list.contains(trimmed)) {
          list.add(trimmed);
        }
      }
    }
    if (verificationDocs != null) {
      for (var doc in verificationDocs!) {
        final trimmed = doc.trim();
        if (trimmed.isNotEmpty && !list.contains(trimmed)) {
          list.add(trimmed);
        }
      }
    }
    return list;
  }

  static double _parseAmount(String? val, {double defaultValue = 0.0}) {
    if (val == null || val.trim().isEmpty) return defaultValue;
    String cleaned = val.replaceAll('₹', '').replaceAll(',', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return defaultValue;
    if (cleaned.endsWith('B') || cleaned.endsWith('b')) {
      double numVal = double.tryParse(cleaned.substring(0, cleaned.length - 1)) ?? 0;
      return numVal * 100000000;
    } else if (cleaned.endsWith('M') || cleaned.endsWith('m')) {
      double numVal = double.tryParse(cleaned.substring(0, cleaned.length - 1)) ?? 0;
      return numVal * 1000000;
    } else if (cleaned.endsWith('K') || cleaned.endsWith('k')) {
      double numVal = double.tryParse(cleaned.substring(0, cleaned.length - 1)) ?? 0;
      return numVal * 1000;
    }
    return double.tryParse(cleaned) ?? defaultValue;
  }

  double get raisedAmount {
    return _parseAmount(raised, defaultValue: 0.0);
  }

  double get goalAmount {
    final parsed = _parseAmount(goal, defaultValue: 1.0);
    return parsed <= 0.0 ? 1.0 : parsed;
  }

  bool get isCompleted =>
      (status != null && status!.toLowerCase().trim() == 'completed') ||
      (goalAmount > 0 && raisedAmount >= goalAmount);
  bool get isOngoing => !isCompleted;

  double get progress {
    final ratio = raisedAmount / goalAmount;
    return ratio.clamp(0.0, 1.0);
  }

  String get formattedDonors {
    if ((donorsCount ?? 0) >= 1000) {
      return formatPrice(donorsCount!);
    }
    return donorsCount?.toString() ?? '0';
  }

  String get formattedRaised {
    return '₹${formatPrice(raisedAmount)}';
  }

  String get formattedGoal {
    return '₹${formatPrice(goalAmount)}';
  }
}

class CampaignsListModel {
  bool? status;
  List<CampaignDetailsData>? data;

  CampaignsListModel({this.status, this.data});

  factory CampaignsListModel.fromJson(Map<String, dynamic> json) {
    return CampaignsListModel(
      status: json['status'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => CampaignDetailsData.fromJson(e)).toList()
          : [],
    );
  }
}

class RecentDonor {
  String? name;
  num? amount;
  String? date;
  String? profilePhoto;

  RecentDonor({this.name, this.amount, this.date, this.profilePhoto});

  factory RecentDonor.fromJson(Map<String, dynamic> json) {
    String? photo = json['profilePhoto'] ??
        json['userImage'] ??
        json['donorImage'] ??
        json['image'] ??
        json['avatar'] ??
        json['photo'] ??
        json['profile_photo'] ??
        json['user_image'] ??
        json['logo'];
    return RecentDonor(
      name: json['name'],
      amount: json['amount'],
      date: json['date'],
      profilePhoto: (photo != null && photo.toString().trim().isNotEmpty) ? photo.toString().trim() : null,
    );
  }
}
