class DanSubCategoriesModel {
  bool? status;
  List<DanSubCategoryData>? data;

  DanSubCategoriesModel({this.status, this.data});

  factory DanSubCategoriesModel.fromJson(Map<String, dynamic> json) {
    return DanSubCategoriesModel(
      status: json['status'],
      data: json['data'] != null
          ? List<DanSubCategoryData>.from(
              json['data'].map((x) => DanSubCategoryData.fromJson(x)))
          : null,
    );
  }
}

class DanSubCategoryCategory {
  String? id;
  String? name;

  DanSubCategoryCategory({this.id, this.name});

  factory DanSubCategoryCategory.fromJson(Map<String, dynamic> json) {
    return DanSubCategoryCategory(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class DanSubCategoryNgo {
  String? id;
  String? name;
  String? logo;

  DanSubCategoryNgo({this.id, this.name, this.logo});

  factory DanSubCategoryNgo.fromJson(Map<String, dynamic> json) {
    return DanSubCategoryNgo(
      id: json['_id'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class DanSubCategoryData {
  String? id;
  String? subcategoryId;
  DanSubCategoryCategory? categoryId;
  String? name;
  String? imageUrl;
  String? description;
  String? status;
  String? creatorType;
  DanSubCategoryNgo? ngoId;
  String? createdAt;
  String? updatedAt;

  DanSubCategoryData({
    this.id,
    this.subcategoryId,
    this.categoryId,
    this.name,
    this.imageUrl,
    this.description,
    this.status,
    this.creatorType,
    this.ngoId,
    this.createdAt,
    this.updatedAt,
  });

  factory DanSubCategoryData.fromJson(Map<String, dynamic> json) {
    return DanSubCategoryData(
      id: json['_id'],
      subcategoryId: json['subcategoryId'],
      categoryId: json['categoryId'] != null
          ? DanSubCategoryCategory.fromJson(json['categoryId'])
          : null,
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      status: json['status'],
      creatorType: json['creatorType'],
      ngoId: json['ngoId'] != null
          ? DanSubCategoryNgo.fromJson(json['ngoId'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
