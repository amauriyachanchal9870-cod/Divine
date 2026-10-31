class ScreenBannerModel {
  bool? status;
  String? screen;
  String? page;
  String? topKey;
  String? bottomKey;
  BannerItem? topBanner;
  BannerItem? bottomBanner;
  List<BannerItem>? top;
  List<BannerItem>? bottom;

  ScreenBannerModel({
    this.status,
    this.screen,
    this.page,
    this.topKey,
    this.bottomKey,
    this.topBanner,
    this.bottomBanner,
    this.top,
    this.bottom,
  });

  factory ScreenBannerModel.fromJson(Map<String, dynamic> json) {
    List<BannerItem> parseBannerList(dynamic val) {
      if (val is List) {
        return val
            .where((e) => e != null)
            .map((e) => BannerItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    dynamic rawTop = json['top'];
    dynamic rawBottom = json['bottom'];
    if ((rawTop == null || (rawTop is List && rawTop.isEmpty)) && json['data'] is Map) {
      rawTop = json['data']['top'];
    }
    if ((rawBottom == null || (rawBottom is List && rawBottom.isEmpty)) && json['data'] is Map) {
      rawBottom = json['data']['bottom'];
    }

    final topList = parseBannerList(rawTop);
    final bottomList = parseBannerList(rawBottom);

    BannerItem? tBanner = json['topBanner'] != null && json['topBanner'] is Map
        ? BannerItem.fromJson(Map<String, dynamic>.from(json['topBanner']))
        : null;
    BannerItem? bBanner = json['bottomBanner'] != null && json['bottomBanner'] is Map
        ? BannerItem.fromJson(Map<String, dynamic>.from(json['bottomBanner']))
        : null;

    if (topList.isEmpty && tBanner != null) {
      topList.add(tBanner);
    }
    if (bottomList.isEmpty && bBanner != null) {
      bottomList.add(bBanner);
    }

    return ScreenBannerModel(
      status: json['status'] == true || json['status'] == 'true',
      screen: json['screen']?.toString(),
      page: json['page']?.toString(),
      topKey: json['topKey']?.toString(),
      bottomKey: json['bottomKey']?.toString(),
      topBanner: tBanner,
      bottomBanner: bBanner,
      top: topList,
      bottom: bottomList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'screen': screen,
      'page': page,
      'topKey': topKey,
      'bottomKey': bottomKey,
      'topBanner': topBanner?.toJson(),
      'bottomBanner': bottomBanner?.toJson(),
      'top': top?.map((e) => e.toJson()).toList(),
      'bottom': bottom?.map((e) => e.toJson()).toList(),
    };
  }
}

class BannerItem {
  String? id;
  String? bannerId;
  String? title;
  String? subtitle;
  String? location;
  String? position;
  String? mediaType;
  String? mediaUrl;
  String? imageUrl;
  String? videoUrl;
  String? targetRoute;
  String? linkUrl;
  String? status;
  String? subscriptionPlan;
  bool? isSubscriptionActive;
  String? placement;

  BannerItem({
    this.id,
    this.bannerId,
    this.title,
    this.subtitle,
    this.location,
    this.position,
    this.mediaType,
    this.mediaUrl,
    this.imageUrl,
    this.videoUrl,
    this.targetRoute,
    this.linkUrl,
    this.status,
    this.subscriptionPlan,
    this.isSubscriptionActive,
    this.placement,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: (json['_id'] ?? json['id'])?.toString(),
      bannerId: json['bannerId']?.toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      location: json['location']?.toString(),
      position: json['position']?.toString(),
      mediaType: json['mediaType']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      targetRoute: json['targetRoute']?.toString(),
      linkUrl: json['linkUrl']?.toString(),
      status: json['status']?.toString(),
      subscriptionPlan: json['subscriptionPlan']?.toString(),
      isSubscriptionActive: json['isSubscriptionActive'] == true || json['isSubscriptionActive'] == 'true',
      placement: json['placement']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bannerId': bannerId,
      'title': title,
      'subtitle': subtitle,
      'location': location,
      'position': position,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'targetRoute': targetRoute,
      'linkUrl': linkUrl,
      'status': status,
      'subscriptionPlan': subscriptionPlan,
      'isSubscriptionActive': isSubscriptionActive,
      'placement': placement,
    };
  }

  String get effectiveMediaUrl {
    if (mediaUrl != null && mediaUrl!.trim().isNotEmpty) return mediaUrl!.trim();
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) return imageUrl!.trim();
    if (videoUrl != null && videoUrl!.trim().isNotEmpty) return videoUrl!.trim();
    return '';
  }

  String get effectiveTarget {
    if (targetRoute != null && targetRoute!.trim().isNotEmpty) return targetRoute!.trim();
    if (linkUrl != null && linkUrl!.trim().isNotEmpty) return linkUrl!.trim();
    return '';
  }

  bool get isVideo {
    final type = (mediaType ?? '').toLowerCase().trim();
    if (type == 'video') return true;
    final url = effectiveMediaUrl.toLowerCase();
    if (url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.webm') || url.endsWith('.m3u8')) return true;
    if (videoUrl != null && videoUrl!.trim().isNotEmpty) return true;
    return false;
  }

  bool get isGif {
    final type = (mediaType ?? '').toLowerCase().trim();
    if (type == 'gif') return true;
    final url = effectiveMediaUrl.toLowerCase();
    if (url.endsWith('.gif')) return true;
    return false;
  }

  bool get isBase64 {
    final url = effectiveMediaUrl;
    return url.startsWith('data:image/') || url.startsWith('data:video/');
  }
}
