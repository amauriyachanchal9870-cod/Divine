class HomeModel {
  bool? status;
  HomeData? data;

  HomeModel({this.status, this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      status: json['status'],
      data: json['data'] != null ? HomeData.fromJson(json['data']) : null,
    );
  }
}

class HomeData {
  HomeUser? user;
  List<HomeBanner>? banners;
  List<HomeCategory>? categories;
  List<HomeCampaign>? campaigns;
  List<HomeNgo>? ngos;
  List<HomeDonationHistory>? donationHistory;

  HomeData({this.user, this.banners, this.categories, this.campaigns, this.ngos, this.donationHistory});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      user: json['user'] != null ? HomeUser.fromJson(json['user']) : null,
      banners: json['banners'] != null
          ? (json['banners'] as List).map((e) => HomeBanner.fromJson(e)).toList()
          : [],
      categories: json['categories'] != null
          ? (json['categories'] as List).map((e) => HomeCategory.fromJson(e)).toList()
          : [],
      campaigns: json['campaigns'] != null
          ? (json['campaigns'] as List).map((e) => HomeCampaign.fromJson(e)).toList()
          : [],
      ngos: json['ngos'] != null
          ? (json['ngos'] as List).map((e) => HomeNgo.fromJson(e)).toList()
          : [],
      donationHistory: json['donationHistory'] != null
          ? (json['donationHistory'] as List).map((e) => HomeDonationHistory.fromJson(e)).toList()
          : [],
    );
  }
}

class HomeUser {
  String? id;
  String? phone;
  String? name;
  String? role;
  int? walletBalance;

  HomeUser({this.id, this.phone, this.name, this.role, this.walletBalance});

  factory HomeUser.fromJson(Map<String, dynamic> json) {
    return HomeUser(
      id: json['id'],
      phone: json['phone'],
      name: json['name'],
      role: json['role'],
      walletBalance: json['walletBalance'] is int
          ? json['walletBalance']
          : int.tryParse(json['walletBalance']?.toString() ?? '0') ?? 0,
    );
  }
}

class HomeBanner {
  String? bannerId;
  String? title;
  String? imageUrl;
  String? linkUrl;

  HomeBanner({this.bannerId, this.title, this.imageUrl, this.linkUrl});

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      bannerId: json['bannerId'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      linkUrl: json['linkUrl'],
    );
  }
}

class HomeCategory {
  String? categoryId;
  String? name;
  String? icon;
  String? description;

  HomeCategory({this.categoryId, this.name, this.icon, this.description});

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      categoryId: json['categoryId'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
    );
  }
}

class HomeCampaign {
  String? campaignId;
  String? title;
  String? user;
  String? category;
  String? imageUrl;
  String? goal;
  String? raised;
  int? donorsCount;
  int? daysLeft;
  String? description;

  HomeCampaign({
    this.campaignId,
    this.title,
    this.user,
    this.category,
    this.imageUrl,
    this.goal,
    this.raised,
    this.donorsCount,
    this.daysLeft,
    this.description,
  });

  factory HomeCampaign.fromJson(Map<String, dynamic> json) {
    return HomeCampaign(
      campaignId: json['campaignId'],
      title: json['title'],
      user: json['user'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      goal: json['goal']?.toString(),
      raised: json['raised']?.toString(),
      donorsCount: json['donorsCount'] is int ? json['donorsCount'] : int.tryParse(json['donorsCount']?.toString() ?? '0') ?? 0,
      daysLeft: json['daysLeft'] is int ? json['daysLeft'] : int.tryParse(json['daysLeft']?.toString() ?? '0') ?? 0,
      description: json['description'],
    );
  }

  double get raisedAmount {
    final cleaned = raised?.replaceAll(',', '').replaceAll(' ', '') ?? '0';
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get goalAmount {
    final cleaned = goal?.replaceAll(',', '').replaceAll(' ', '') ?? '1';
    return double.tryParse(cleaned) ?? 1.0;
  }

  double get progress {
    if (goalAmount == 0) return 0;
    final ratio = raisedAmount / goalAmount;
    return ratio.clamp(0.0, 1.0);
  }

  String get formattedDonors {
    if ((donorsCount ?? 0) >= 1000) {
      return '${(donorsCount! / 1000).toStringAsFixed(1)}K';
    }
    return donorsCount?.toString() ?? '0';
  }
}

class HomeNgo {
  String? id;
  String? name;
  String? logo;
  double? rating;
  String? impactStats;
  String? description;

  HomeNgo({this.id, this.name, this.logo, this.rating, this.impactStats, this.description});

  factory HomeNgo.fromJson(Map<String, dynamic> json) {
    return HomeNgo(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      rating: (json['rating'] as num?)?.toDouble(),
      impactStats: json['impactStats'],
      description: json['description'],
    );
  }
}

class HomeDonationHistory {
  String? transactionId;
  String? user;
  String? donor;
  String? item;
  int? amount;
  String? status;
  String? date;
  String? createdAt;

  HomeDonationHistory({
    this.transactionId,
    this.user,
    this.donor,
    this.item,
    this.amount,
    this.status,
    this.date,
    this.createdAt,
  });

  factory HomeDonationHistory.fromJson(Map<String, dynamic> json) {
    return HomeDonationHistory(
      transactionId: json['transactionId'],
      user: json['user'],
      donor: json['donor'],
      item: json['item'],
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'],
      date: json['date'],
      createdAt: json['createdAt'],
    );
  }

  String get timeAgo {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date!);
      final diff = DateTime.now().difference(d);
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}
