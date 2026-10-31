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
  String? role;

  SocialDonor({
    this.id,
    this.phone,
    this.profilePhoto,
    this.walletBalance,
    this.name,
    this.email,
    this.role,
  });

  factory SocialDonor.fromJson(Map<String, dynamic> json) {
    return SocialDonor(
      id: json['_id'] ?? json['id'],
      phone: json['phone'],
      profilePhoto: json['profilePhoto'] ?? json['logo'],
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      name: json['name'] ?? json['organizationName'],
      email: json['email'],
      role: (json['role'] ?? json['userRole'] ?? json['type'] ?? json['userType'])?.toString(),
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
  String? role;

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
    this.role,
  });

  factory SocialNgo.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('ngo') && json['ngo'] is Map<String, dynamic>) {
      data = json['ngo'];
    } else if (json.containsKey('follower') && json['follower'] is Map<String, dynamic>) {
      data = json['follower'];
    } else if (json.containsKey('followerId') && json['followerId'] is Map<String, dynamic>) {
      data = json['followerId'];
    }

    final String? resolvedNgoId = (data['ngoId'] ??
        json['ngoId'] ??
        data['ngo_id'] ??
        json['ngo_id'] ??
        data['organizationId'] ??
        json['organizationId'] ??
        (data['ngo'] is Map ? data['ngo']['_id'] : null) ??
        (json['ngo'] is Map ? json['ngo']['_id'] : null) ??
        data['_id'] ??
        data['id'] ??
        json['_id'] ??
        json['id'])?.toString();

    final String? directId = (data['_id'] ?? data['id'] ?? json['_id'] ?? json['id'])?.toString();

    return SocialNgo(
      id: resolvedNgoId ?? directId,
      ngoId: resolvedNgoId ?? directId,
      name: data['name'] ?? json['name'] ?? data['organizationName'] ?? json['organizationName'],
      logo: data['logo'] ?? json['logo'] ?? data['profilePhoto'] ?? json['profilePhoto'],
      rating: ((data['rating'] ?? json['rating']) as num?)?.toDouble(),
      registrationNumber: data['registrationNumber'] ?? json['registrationNumber'],
      contactPerson: data['contactPerson'] ?? json['contactPerson'],
      email: data['email'] ?? json['email'],
      phone: data['phone'] ?? json['phone'],
      about: data['about'] ?? json['about'] ?? data['description'] ?? json['description'],
      status: data['status'] ?? json['status'],
      activityProof: (data['activityProof'] ?? json['activityProof']) != null
          ? List<String>.from(data['activityProof'] ?? json['activityProof'])
          : [],
      verifiedCampaignsCount: (data['verifiedCampaignsCount'] ?? json['verifiedCampaignsCount']) is int
          ? (data['verifiedCampaignsCount'] ?? json['verifiedCampaignsCount'])
          : int.tryParse((data['verifiedCampaignsCount'] ?? json['verifiedCampaignsCount'])?.toString() ?? '0') ?? 0,
      kycDocs: (data['kycDocs'] ?? json['kycDocs']) != null
          ? List<String>.from(data['kycDocs'] ?? json['kycDocs'])
          : [],
      campaigns: (data['campaigns'] ?? json['campaigns']) != null
          ? ((data['campaigns'] ?? json['campaigns']) as List).map((e) => SocialCampaign.fromJson(e)).toList()
          : [],
      activityGallery: (data['activityGallery'] ?? json['activityGallery']) != null
          ? ((data['activityGallery'] ?? json['activityGallery']) as List).map((e) => SocialActivityGallery.fromJson(e)).toList()
          : [],
      role: (data['role'] ?? json['role'] ?? data['userRole'] ?? json['userRole'] ?? data['type'] ?? json['type'] ?? data['userType'] ?? json['userType'])?.toString(),
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
