class DanItemsModel {
  bool? status;
  List<DanItemData>? data;

  DanItemsModel({this.status, this.data});

  factory DanItemsModel.fromJson(Map<String, dynamic> json) {
    return DanItemsModel(
      status: json['status'],
      data: json['data'] != null
          ? List<DanItemData>.from(json['data'].map((x) => DanItemData.fromJson(x)))
          : null,
    );
  }
}

class DanItemSubcategoryRef {
  String? id;
  String? name;
  DanItemCategoryRef? categoryId;

  DanItemSubcategoryRef({this.id, this.name, this.categoryId});

  factory DanItemSubcategoryRef.fromJson(Map<String, dynamic> json) {
    return DanItemSubcategoryRef(
      id: json['_id'],
      name: json['name'],
      categoryId: json['categoryId'] != null
          ? DanItemCategoryRef.fromJson(json['categoryId'])
          : null,
    );
  }
}

class DanItemCategoryRef {
  String? id;
  String? name;

  DanItemCategoryRef({this.id, this.name});

  factory DanItemCategoryRef.fromJson(Map<String, dynamic> json) {
    return DanItemCategoryRef(id: json['_id'], name: json['name']);
  }
}

class DanItemNgoRef {
  String? id;
  String? name;
  String? logo;

  DanItemNgoRef({this.id, this.name, this.logo});

  factory DanItemNgoRef.fromJson(Map<String, dynamic> json) {
    return DanItemNgoRef(
      id: json['_id'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class DanItemData {
  String? id;
  String? itemId;
  DanItemSubcategoryRef? subcategoryId;
  String? name;
  String? description;
  double? price;
  String? unit;
  String? imageUrl;
  String? status;
  String? creatorType;
  DanItemNgoRef? ngoId;
  String? createdAt;
  String? updatedAt;

  DanItemData({
    this.id,
    this.itemId,
    this.subcategoryId,
    this.name,
    this.description,
    this.price,
    this.unit,
    this.imageUrl,
    this.status,
    this.creatorType,
    this.ngoId,
    this.createdAt,
    this.updatedAt,
  });

  factory DanItemData.fromJson(Map<String, dynamic> json) {
    return DanItemData(
      id: json['_id'],
      itemId: json['itemId'],
      subcategoryId: json['subcategoryId'] != null
          ? DanItemSubcategoryRef.fromJson(json['subcategoryId'])
          : null,
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      unit: json['unit'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      creatorType: json['creatorType'],
      ngoId: json['ngoId'] != null ? DanItemNgoRef.fromJson(json['ngoId']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
