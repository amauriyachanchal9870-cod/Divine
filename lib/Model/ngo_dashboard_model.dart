import '../Utilities/helper.dart';

class NgoDashboardModel {
  bool? status;
  NgoProfileInfo? ngo;
  NgoSummary? summary;
  List<NgoDashboardCampaign>? campaigns;
  List<NgoRecentDonation>? recentDonations;

  NgoDashboardModel({
    this.status,
    this.ngo,
    this.summary,
    this.campaigns,
    this.recentDonations,
  });

  factory NgoDashboardModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? dataMap = json['data'] is Map<String, dynamic> ? json['data'] : null;

    final rawNgo = json['ngo'] ?? dataMap?['ngo'];
    final rawSummary = json['summary'] ?? dataMap?['summary'];
    final rawCampaigns = json['campaigns'] ?? dataMap?['campaigns'];
    final rawRecentDonations = json['recentDonations'] ??
        json['donations'] ??
        dataMap?['recentDonations'] ??
        dataMap?['donations'];

    return NgoDashboardModel(
      status: json['status'] == true,
      ngo: rawNgo != null ? NgoProfileInfo.fromJson(rawNgo) : null,
      summary: rawSummary != null ? NgoSummary.fromJson(rawSummary) : null,
      campaigns: rawCampaigns != null && rawCampaigns is List
          ? rawCampaigns.map((e) => NgoDashboardCampaign.fromJson(e)).toList()
          : [],
      recentDonations: rawRecentDonations != null && rawRecentDonations is List
          ? rawRecentDonations.map((e) => NgoRecentDonation.fromJson(e)).toList()
          : [],
    );
  }
}

class NgoProfileInfo {
  String? id;
  String? sId;
  String? name;
  String? organizationName;
  String? logo;
  num? rating;
  String? email;
  String? phone;
  String? status;

  NgoProfileInfo({
    this.id,
    this.sId,
    this.name,
    this.organizationName,
    this.logo,
    this.rating,
    this.email,
    this.phone,
    this.status,
  });

  factory NgoProfileInfo.fromJson(Map<String, dynamic> json) {
    return NgoProfileInfo(
      id: (json['id'] ?? json['_id'])?.toString(),
      sId: json['_id']?.toString(),
      name: json['name']?.toString(),
      organizationName: json['organizationName']?.toString() ?? json['name']?.toString(),
      logo: json['logo']?.toString(),
      rating: json['rating'] is num ? json['rating'] : num.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class NgoSummary {
  num? totalDonationsReceived;
  String? formattedTotalDonations;
  int? totalDonationCount;
  int? totalDonorsCount;
  num? campaignDonationsTotal;
  num? danDonationsTotal;
  int? activeCampaignsCount;
  int? totalCampaignsCount;

  NgoSummary({
    this.totalDonationsReceived,
    this.formattedTotalDonations,
    this.totalDonationCount,
    this.totalDonorsCount,
    this.campaignDonationsTotal,
    this.danDonationsTotal,
    this.activeCampaignsCount,
    this.totalCampaignsCount,
  });

  factory NgoSummary.fromJson(Map<String, dynamic> json) {
    final received = json['totalDonationsReceived'] is num
        ? json['totalDonationsReceived']
        : num.tryParse(json['totalDonationsReceived']?.toString() ?? '0') ?? 0;

    return NgoSummary(
      totalDonationsReceived: received,
      formattedTotalDonations: json['formattedTotalDonations']?.toString() ?? '₹${formatPrice(received)}',
      totalDonationCount: json['totalDonationCount'] is int
          ? json['totalDonationCount']
          : int.tryParse(json['totalDonationCount']?.toString() ?? '0') ?? 0,
      totalDonorsCount: json['totalDonorsCount'] is int
          ? json['totalDonorsCount']
          : int.tryParse(json['totalDonorsCount']?.toString() ?? '0') ?? 0,
      campaignDonationsTotal: json['campaignDonationsTotal'] is num
          ? json['campaignDonationsTotal']
          : num.tryParse(json['campaignDonationsTotal']?.toString() ?? '0') ?? 0,
      danDonationsTotal: json['danDonationsTotal'] is num
          ? json['danDonationsTotal']
          : num.tryParse(json['danDonationsTotal']?.toString() ?? '0') ?? 0,
      activeCampaignsCount: json['activeCampaignsCount'] is int
          ? json['activeCampaignsCount']
          : int.tryParse(json['activeCampaignsCount']?.toString() ?? '0') ?? 0,
      totalCampaignsCount: json['totalCampaignsCount'] is int
          ? json['totalCampaignsCount']
          : int.tryParse(json['totalCampaignsCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class NgoDashboardCampaign {
  String? sId;
  String? campaignId;
  String? title;
  String? category;
  String? goal;
  num? goalAmount;
  String? raised;
  num? raisedAmount;
  num? percentage;
  int? donorsCount;
  String? status;
  String? imageUrl;

  NgoDashboardCampaign({
    this.sId,
    this.campaignId,
    this.title,
    this.category,
    this.goal,
    this.goalAmount,
    this.raised,
    this.raisedAmount,
    this.percentage,
    this.donorsCount,
    this.status,
    this.imageUrl,
  });

  factory NgoDashboardCampaign.fromJson(Map<String, dynamic> json) {
    return NgoDashboardCampaign(
      sId: json['_id']?.toString(),
      campaignId: json['campaignId']?.toString(),
      title: json['title']?.toString(),
      category: json['category']?.toString(),
      goal: json['goal']?.toString(),
      goalAmount: json['goalAmount'] is num ? json['goalAmount'] : num.tryParse(json['goalAmount']?.toString() ?? '0'),
      raised: json['raised']?.toString(),
      raisedAmount: json['raisedAmount'] is num ? json['raisedAmount'] : num.tryParse(json['raisedAmount']?.toString() ?? '0'),
      percentage: json['percentage'] is num ? json['percentage'] : num.tryParse(json['percentage']?.toString() ?? '0'),
      donorsCount: json['donorsCount'] is int ? json['donorsCount'] : int.tryParse(json['donorsCount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class NgoRecentDonation {
  String? sId;
  String? donationId;
  String? donorName;
  String? donorPhone;
  num? amount;
  String? formattedAmount;
  String? type;
  String? item;
  String? campaignTitle;
  String? status;
  String? date;
  String? createdAt;

  NgoRecentDonation({
    this.sId,
    this.donationId,
    this.donorName,
    this.donorPhone,
    this.amount,
    this.formattedAmount,
    this.type,
    this.item,
    this.campaignTitle,
    this.status,
    this.date,
    this.createdAt,
  });

  factory NgoRecentDonation.fromJson(Map<String, dynamic> json) {
    final amt = json['amount'] is num ? json['amount'] : num.tryParse(json['amount']?.toString() ?? '0') ?? 0;
    return NgoRecentDonation(
      sId: json['_id']?.toString(),
      donationId: json['donationId']?.toString(),
      donorName: json['donorName']?.toString(),
      donorPhone: json['donorPhone']?.toString(),
      amount: amt,
      formattedAmount: json['formattedAmount']?.toString() ?? '₹${formatPrice(amt)}',
      type: json['type']?.toString(),
      item: json['item']?.toString(),
      campaignTitle: json['campaignTitle']?.toString() ?? json['item']?.toString(),
      status: json['status']?.toString(),
      date: json['date']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}
