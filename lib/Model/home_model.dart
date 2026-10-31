import '../Utilities/helper.dart';

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
  int? totalDonateAmount;
  List<HomePressMedia>? pressAndMedia;

  HomeData({this.user, this.banners, this.categories, this.campaigns, this.ngos, this.donationHistory, this.totalDonateAmount, this.pressAndMedia});

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
      totalDonateAmount: json['totalDonateAmount'] is int
          ? json['totalDonateAmount']
          : int.tryParse(json['totalDonateAmount']?.toString() ?? '0') ?? 0,
      pressAndMedia: (json['pressAndMedia'] ?? json['press_and_media']) != null
          ? ((json['pressAndMedia'] ?? json['press_and_media']) as List)
              .map((e) => HomePressMedia.fromJson(e))
              .toList()
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
  String? profilePhoto;

  HomeUser({this.id, this.phone, this.name, this.role, this.walletBalance, this.profilePhoto});

  factory HomeUser.fromJson(Map<String, dynamic> json) {
    return HomeUser(
      id: json['id'],
      phone: json['phone'],
      name: json['name'],
      role: json['role'],
      walletBalance: json['walletBalance'] is int
          ? json['walletBalance']
          : int.tryParse(json['walletBalance']?.toString() ?? '0') ?? 0,
      profilePhoto: json['profilePhoto'] ?? json['logo'],
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
  String? imageUrl;
  String? description;

  HomeCategory({this.categoryId, this.name, this.icon, this.imageUrl, this.description});

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      categoryId: json['categoryId'],
      name: json['name'],
      icon: json['icon'],
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}

class HomeCampaign {
  String? sId;
  String? campaignId;
  String? title;
  String? user;
  String? userId;
  String? category;
  String? imageUrl;
  String? goal;
  String? raised;
  int? donorsCount;
  int? daysLeft;
  String? description;
  String? status;

  HomeCampaign({
    this.sId,
    this.campaignId,
    this.title,
    this.user,
    this.userId,
    this.category,
    this.imageUrl,
    this.goal,
    this.raised,
    this.donorsCount,
    this.daysLeft,
    this.description,
    this.status,
  });

  factory HomeCampaign.fromJson(Map<String, dynamic> json) {
    return HomeCampaign(
      sId: json['_id'] ?? json['id'],
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
      goal: json['goal']?.toString(),
      raised: json['raised']?.toString(),
      donorsCount: json['donorsCount'] is int ? json['donorsCount'] : int.tryParse(json['donorsCount']?.toString() ?? '0') ?? 0,
      daysLeft: json['daysLeft'] is int ? json['daysLeft'] : int.tryParse(json['daysLeft']?.toString() ?? '0') ?? 0,
      description: json['description'],
      status: json['status']?.toString(),
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

  bool get isCompleted =>
      (status != null && status!.toLowerCase().trim() == 'completed') ||
      (goalAmount > 0 && raisedAmount >= goalAmount);
  bool get isOngoing => !isCompleted;

  double get progress {
    if (goalAmount == 0) return 0;
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

class HomeNgo {
  String? id;
  String? ngoId;
  String? name;
  String? logo;
  double? rating;
  String? impactStats;
  String? description;
  String? about;

  HomeNgo({
    this.id,
    this.ngoId,
    this.name,
    this.logo,
    this.rating,
    this.impactStats,
    this.description,
    this.about,
  });

  factory HomeNgo.fromJson(Map<String, dynamic> json) {
    return HomeNgo(
      id: json['_id'] ?? json['id'],
      ngoId: json['ngoId'],
      name: json['name'],
      logo: json['logo'],
      rating: (json['rating'] as num?)?.toDouble(),
      impactStats: json['impactStats'],
      description: json['description'] ?? json['about'],
      about: json['about'],
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
  String? type;
  String? fundCategory;

  HomeDonationHistory({
    this.transactionId,
    this.user,
    this.donor,
    this.item,
    this.amount,
    this.status,
    this.date,
    this.createdAt,
    this.type,
    this.fundCategory,
  });

  factory HomeDonationHistory.fromJson(Map<String, dynamic> json) {
    return HomeDonationHistory(
      transactionId: json['transactionId'] ?? json['donationId'],
      user: json['user'],
      donor: json['donor'],
      item: json['item'],
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'],
      date: json['date'],
      createdAt: json['createdAt'],
      type: json['type'] ?? json['donationType'],
      fundCategory: json['fundCategory'] ?? json['category'],
    );
  }

  bool get isDaan {
    final t = (type ?? '').toLowerCase();
    final c = (fundCategory ?? '').toLowerCase();
    final itm = (item ?? '').toLowerCase();
    return t.contains('dan') ||
           t.contains('daan') ||
           c.contains('dan') ||
           c.contains('daan') ||
           itm.contains('dan') ||
           itm.contains('daan') ||
           itm.contains('ration') ||
           itm.contains('brahmin') ||
           itm.contains('gau') ||
           itm.contains('seva') ||
           itm.contains('cow');
  }

  bool get isNgo {
    if (isDaan) return false;
    final t = (type ?? '').toLowerCase();
    final c = (fundCategory ?? '').toLowerCase();
    final itm = (item ?? '').toLowerCase();
    return t.contains('ngo') ||
           c.contains('ngo') ||
           itm.contains('ngo') ||
           itm.contains('trust') ||
           itm.contains('foundation') ||
           itm.contains('samiti');
  }

  bool get isCampaign {
    return !isDaan && !isNgo;
  }

  DateTime? get parsedDate {
    if (date != null && date!.isNotEmpty) {
      final parsed = DateTime.tryParse(date!);
      if (parsed != null) return parsed;
    }
    if (createdAt != null && createdAt!.isNotEmpty) {
      return DateTime.tryParse(createdAt!);
    }
    return null;
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

class HomePressMedia {
  String? id;
  String? newsId;
  String? title;
  String? source;
  String? content;
  String? imageUrl;
  String? publishedDate;
  String? date;
  String? time;
  String? createdAt;
  String? status;

  HomePressMedia({
    this.id,
    this.newsId,
    this.title,
    this.source,
    this.content,
    this.imageUrl,
    this.publishedDate,
    this.date,
    this.time,
    this.createdAt,
    this.status,
  });

  factory HomePressMedia.fromJson(Map<String, dynamic> json) {
    return HomePressMedia(
      id: json['_id'] ?? json['id'],
      newsId: json['newsId'],
      title: json['title'],
      source: json['source'],
      content: json['content'],
      imageUrl: json['imageUrl'] ?? json['image'],
      publishedDate: json['publishedDate'],
      date: json['date'],
      time: json['time'] ?? json['publishedTime'],
      createdAt: json['createdAt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'newsId': newsId,
      'title': title,
      'source': source,
      'content': content,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate,
      'date': date,
      'time': time,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
