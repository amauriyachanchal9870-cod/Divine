class CampaignCategoryModel {
  bool? status;
  List<CampaignCategoryData>? data;

  CampaignCategoryModel({this.status, this.data});

  factory CampaignCategoryModel.fromJson(Map<String, dynamic> json) {
    return CampaignCategoryModel(
      status: json['status'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => CampaignCategoryData.fromJson(e)).toList()
          : [],
    );
  }
}

class CampaignCategoryData {
  String? sId;
  String? categoryId;
  String? name;
  String? icon;
  String? description;
  String? imageUrl;

  CampaignCategoryData({
    this.sId,
    this.categoryId,
    this.name,
    this.icon,
    this.description,
    this.imageUrl,
  });

  factory CampaignCategoryData.fromJson(Map<String, dynamic> json) {
    return CampaignCategoryData(
      sId: json['_id'],
      categoryId: json['categoryId'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}
