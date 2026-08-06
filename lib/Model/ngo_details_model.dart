class NgoDetailsModel {
  bool? status;
  NgoDetailsData? data;

  NgoDetailsModel({this.status, this.data});

  factory NgoDetailsModel.fromJson(Map<String, dynamic> json) {
    return NgoDetailsModel(
      status: json['status'],
      data: json['data'] != null ? NgoDetailsData.fromJson(json['data']) : null,
    );
  }
}

class NgoDetailsData {
  String? id;
  String? ngoId;
  String? name;
  String? logo;
  double? rating;
  String? impactStats;
  String? registrationNumber;
  String? contactPerson;
  String? email;
  String? phone;
  String? about;
  String? years;
  String? ourMission;
  String? status;
  List<String>? activityProof;
  int? verifiedCampaignsCount;
  List<PayoutItem>? payoutHistory;
  List<String>? kycDocs;
  List<CampaignItem>? campaigns;
  List<String>? activityGallery;

  NgoDetailsData({
    this.id,
    this.ngoId,
    this.name,
    this.logo,
    this.rating,
    this.impactStats,
    this.registrationNumber,
    this.contactPerson,
    this.email,
    this.phone,
    this.about,
    this.years,
    this.ourMission,
    this.status,
    this.activityProof,
    this.verifiedCampaignsCount,
    this.payoutHistory,
    this.kycDocs,
    this.campaigns,
    this.activityGallery,
  });

  factory NgoDetailsData.fromJson(Map<String, dynamic> json) {
    return NgoDetailsData(
      id: json['_id'] ?? json['id'],
      ngoId: json['ngoId'],
      name: json['name'],
      logo: json['logo'],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      impactStats: json['impactStats'],
      registrationNumber: json['registrationNumber'],
      contactPerson: json['contactPerson'],
      email: json['email'],
      phone: json['phone'],
      about: json['about'],
      years: json['years']?.toString(),
      ourMission: json['ourMission'],
      status: json['status'],
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
