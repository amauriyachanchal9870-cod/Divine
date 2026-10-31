class ReferralModel {
  bool? status;
  ReferralData? data;

  ReferralModel({this.status, this.data});

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      status: json['status'],
      data: json['data'] != null ? ReferralData.fromJson(json['data']) : null,
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

class ReferralData {
  String? referralCode;
  int? rewards;
  int? totalRewards;
  int? rewardAmount;
  int? coins;
  int? totalCoins;
  int? totalRewardCoins;
  int? totalEarnPoints;
  int? totalReferral;
  int? successfulReferral;
  int? referralThisMonth;
  List<ReferralItem>? referrals;

  ReferralData({
    this.referralCode,
    this.rewards,
    this.totalRewards,
    this.rewardAmount,
    this.coins,
    this.totalCoins,
    this.totalRewardCoins,
    this.totalEarnPoints,
    this.totalReferral,
    this.successfulReferral,
    this.referralThisMonth,
    this.referrals,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    List<ReferralItem> list = [];
    var rawList = json['transactionList'] ??
        json['transactionsList'] ??
        json['transactions'] ??
        json['transaction_list'] ??
        json['history'] ??
        json['referrals'];

    if (rawList != null && rawList is List) {
      list = rawList.map((v) => ReferralItem.fromJson(v)).toList();
    }

    return ReferralData(
      referralCode: json['referralCode']?.toString() ?? '----',
      rewards: parseNum(json['rewards']),
      totalRewards: parseNum(json['totalRewards'] ?? json['rewards'] ?? json['rewardAmount']),
      rewardAmount: parseNum(json['rewardAmount']),
      coins: parseNum(json['coins']),
      totalCoins: parseNum(json['totalCoins'] ?? json['coins'] ?? json['totalRewardCoins'] ?? json['totalEarnPoints'] ?? json['totalEarnings']),
      totalRewardCoins: parseNum(json['totalRewardCoins']),
      totalEarnPoints: parseNum(json['totalEarnPoints']),
      totalReferral: parseNum(json['totalReferral'] ?? json['referredCount']),
      successfulReferral: parseNum(json['successfulReferral']),
      referralThisMonth: parseNum(json['referralThisMonth']),
      referrals: list,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['referralCode'] = referralCode;
    map['rewards'] = rewards;
    map['totalRewards'] = totalRewards;
    map['rewardAmount'] = rewardAmount;
    map['coins'] = coins;
    map['totalCoins'] = totalCoins;
    map['totalRewardCoins'] = totalRewardCoins;
    map['totalEarnPoints'] = totalEarnPoints;
    map['totalReferral'] = totalReferral;
    map['successfulReferral'] = successfulReferral;
    map['referralThisMonth'] = referralThisMonth;
    if (referrals != null) {
      map['referrals'] = referrals!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ReferralItem {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? createdAt;
  int? amount;
  int? coins;
  String? title;
  String? description;

  ReferralItem({
    this.sId,
    this.name,
    this.email,
    this.phone,
    this.createdAt,
    this.amount,
    this.coins,
    this.title,
    this.description,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return ReferralItem(
      sId: json['_id'] ?? json['id'],
      name: json['name'] ?? json['user'] ?? json['userName'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['createdAt'] ?? json['date'] ?? json['timestamp'],
      amount: parseNum(json['amount'] ?? json['rewardAmount']),
      coins: parseNum(json['coins'] ?? json['rewardCoins'] ?? json['points']),
      title: json['title'] ?? json['description'] ?? json['remark'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['_id'] = sId;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['createdAt'] = createdAt;
    map['amount'] = amount;
    map['coins'] = coins;
    map['title'] = title;
    map['description'] = description;
    return map;
  }
}
