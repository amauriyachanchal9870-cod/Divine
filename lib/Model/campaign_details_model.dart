import '../Utilities/helper.dart';

class CampaignDetailsModel {
  bool? status;
  CampaignDetailsData? data;

  CampaignDetailsModel({this.status, this.data});

  factory CampaignDetailsModel.fromJson(Map<String, dynamic> json) {
    return CampaignDetailsModel(
      status: json['status'],
      data: json['data'] != null ? CampaignDetailsData.fromJson(json['data']) : null,
    );
  }
}

class CampaignDetailsData {
  String? sId;
  String? campaignId;
  String? title;
  String? user;
  String? category;
  String? imageUrl;
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

  CampaignDetailsData({
    this.sId,
    this.campaignId,
    this.title,
    this.user,
    this.category,
    this.imageUrl,
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
  });

  factory CampaignDetailsData.fromJson(Map<String, dynamic> json) {
    return CampaignDetailsData(
      sId: json['_id'],
      campaignId: json['campaignId'],
      title: json['title'],
      user: json['user'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      donorsCount: json['donorsCount'] is int ? json['donorsCount'] : int.tryParse(json['donorsCount']?.toString() ?? '0') ?? 0,
      daysLeft: json['daysLeft'] is int ? json['daysLeft'] : int.tryParse(json['daysLeft']?.toString() ?? '0') ?? 0,
      description: json['description'],
      goal: json['goal']?.toString(),
      raised: json['raised']?.toString(),
      oneTimeOrMonthly: json['oneTimeOrMonthly'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      recentDonors: json['recentDonors'] != null
          ? (json['recentDonors'] as List).map((e) => RecentDonor.fromJson(e)).toList()
          : [],
    );
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

  bool get isCompleted => goalAmount > 0 && raisedAmount >= goalAmount;
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

  RecentDonor({this.name, this.amount, this.date});

  factory RecentDonor.fromJson(Map<String, dynamic> json) {
    return RecentDonor(
      name: json['name'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}
