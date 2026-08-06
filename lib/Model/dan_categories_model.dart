class DanCategoriesModel {
  bool? status;
  DanBanners? banners;
  List<DanCategoryData>? data;

  DanCategoriesModel({this.status, this.banners, this.data});

  factory DanCategoriesModel.fromJson(Map<String, dynamic> json) {
    return DanCategoriesModel(
      status: json['status'],
      banners: json['banners'] != null ? DanBanners.fromJson(json['banners']) : null,
      data: json['data'] != null
          ? List<DanCategoryData>.from(json['data'].map((x) => DanCategoryData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'banners': banners?.toJson(),
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class DanBanners {
  List<DanBannerItem>? top;
  List<DanBannerItem>? bottom;

  DanBanners({this.top, this.bottom});

  factory DanBanners.fromJson(Map<String, dynamic> json) {
    return DanBanners(
      top: json['top'] != null
          ? List<DanBannerItem>.from(json['top'].map((x) => DanBannerItem.fromJson(x)))
          : null,
      bottom: json['bottom'] != null
          ? List<DanBannerItem>.from(json['bottom'].map((x) => DanBannerItem.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top?.map((x) => x.toJson()).toList(),
      'bottom': bottom?.map((x) => x.toJson()).toList(),
    };
  }
}

class DanBannerItem {
  String? id;
  String? bannerId;
  String? title;
  String? imageUrl;
  String? linkUrl;
  String? placement;
  String? status;

  DanBannerItem({
    this.id,
    this.bannerId,
    this.title,
    this.imageUrl,
    this.linkUrl,
    this.placement,
    this.status,
  });

  factory DanBannerItem.fromJson(Map<String, dynamic> json) {
    return DanBannerItem(
      id: json['_id'],
      bannerId: json['bannerId'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      linkUrl: json['linkUrl'],
      placement: json['placement'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bannerId': bannerId,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'placement': placement,
      'status': status,
    };
  }
}

class DanCategoryData {
  String? id;
  String? categoryId;
  String? name;
  String? icon;
  String? imageUrl;
  String? description;
  String? status;
  String? creatorType;
  String? ngoId;

  DanCategoryData({
    this.id,
    this.categoryId,
    this.name,
    this.icon,
    this.imageUrl,
    this.description,
    this.status,
    this.creatorType,
    this.ngoId,
  });

  factory DanCategoryData.fromJson(Map<String, dynamic> json) {
    return DanCategoryData(
      id: json['_id'],
      categoryId: json['categoryId'],
      name: json['name'],
      icon: json['icon'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      status: json['status'],
      creatorType: json['creatorType'],
      ngoId: json['ngoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'creatorType': creatorType,
      'ngoId': ngoId,
    };
  }
}
