class SocialModel {
  bool? status;
  SocialData? data;

  SocialModel({this.status, this.data});

  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      status: json['status'],
      data: json['data'] != null ? SocialData.fromJson(json['data']) : null,
    );
  }
}

class SocialData {
  List<SocialDonor>? topDonors;
  List<SocialNgo>? topNgos;
  List<SocialNgo>? followingNgos;
  List<SocialDonor>? followingUsers;
  List<SocialDonor>? followers;

  SocialData({
    this.topDonors,
    this.topNgos,
    this.followingNgos,
    this.followingUsers,
    this.followers,
  });

  factory SocialData.fromJson(Map<String, dynamic> json) {
    return SocialData(
      topDonors: json['topDonors'] != null
          ? (json['topDonors'] as List).map((e) => SocialDonor.fromJson(e)).toList()
          : [],
      topNgos: json['topNgos'] != null
          ? (json['topNgos'] as List).map((e) => SocialNgo.fromJson(e)).toList()
          : [],
      followingNgos: json['followingNgos'] != null
          ? (json['followingNgos'] as List).map((e) => SocialNgo.fromJson(e)).toList()
          : [],
      followingUsers: json['followingUsers'] != null
          ? (json['followingUsers'] as List).map((e) => SocialDonor.fromJson(e)).toList()
          : [],
      followers: json['followers'] != null
          ? (json['followers'] as List).map((e) => SocialDonor.fromJson(e)).toList()
          : [],
    );
  }
}

class SocialDonor {
  String? id;
  String? phone;
  String? profilePhoto;
  double? walletBalance;
  String? name;
  String? email;

  SocialDonor({
    this.id,
    this.phone,
    this.profilePhoto,
    this.walletBalance,
    this.name,
    this.email,
  });

  factory SocialDonor.fromJson(Map<String, dynamic> json) {
    return SocialDonor(
      id: json['_id'],
      phone: json['phone'],
      profilePhoto: json['profilePhoto'],
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      name: json['name'],
      email: json['email'],
    );
  }
}

class SocialNgo {
  String? id;
  String? ngoId;
  String? name;
  String? logo;
  double? rating;
  String? registrationNumber;
  String? contactPerson;
  String? email;
  String? phone;
  String? about;
  String? status;
  List<String>? activityProof;
  int? verifiedCampaignsCount;
  List<String>? kycDocs;
  List<SocialCampaign>? campaigns;
  List<SocialActivityGallery>? activityGallery;

  SocialNgo({
    this.id,
    this.ngoId,
    this.name,
    this.logo,
    this.rating,
    this.registrationNumber,
    this.contactPerson,
    this.email,
    this.phone,
    this.about,
    this.status,
    this.activityProof,
    this.verifiedCampaignsCount,
    this.kycDocs,
    this.campaigns,
    this.activityGallery,
  });

  factory SocialNgo.fromJson(Map<String, dynamic> json) {
    return SocialNgo(
      id: json['_id'],
      ngoId: json['ngoId'],
      name: json['name'],
      logo: json['logo'],
      rating: (json['rating'] as num?)?.toDouble(),
      registrationNumber: json['registrationNumber'],
      contactPerson: json['contactPerson'],
      email: json['email'],
      phone: json['phone'],
      about: json['about'],
      status: json['status'],
      activityProof: json['activityProof'] != null
          ? List<String>.from(json['activityProof'])
          : [],
      verifiedCampaignsCount: json['verifiedCampaignsCount'] is int
          ? json['verifiedCampaignsCount']
          : int.tryParse(json['verifiedCampaignsCount']?.toString() ?? '0') ?? 0,
      kycDocs: json['kycDocs'] != null
          ? List<String>.from(json['kycDocs'])
          : [],
      campaigns: json['campaigns'] != null
          ? (json['campaigns'] as List).map((e) => SocialCampaign.fromJson(e)).toList()
          : [],
      activityGallery: json['activityGallery'] != null
          ? (json['activityGallery'] as List).map((e) => SocialActivityGallery.fromJson(e)).toList()
          : [],
    );
  }
}

class SocialCampaign {
  String? campaignId;
  String? title;
  String? goal;
  String? raised;
  String? status;

  SocialCampaign({
    this.campaignId,
    this.title,
    this.goal,
    this.raised,
    this.status,
  });

  factory SocialCampaign.fromJson(Map<String, dynamic> json) {
    return SocialCampaign(
      campaignId: json['campaignId'],
      title: json['title'],
      goal: json['goal'],
      raised: json['raised'],
      status: json['status'],
    );
  }
}

class SocialActivityGallery {
  String? title;
  String? description;
  String? imageUrl;
  String? uploadedAt;

  SocialActivityGallery({
    this.title,
    this.description,
    this.imageUrl,
    this.uploadedAt,
  });

  factory SocialActivityGallery.fromJson(Map<String, dynamic> json) {
    return SocialActivityGallery(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      uploadedAt: json['uploadedAt'],
    );
  }
}
