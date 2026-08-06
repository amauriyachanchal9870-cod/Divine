class CouponModel {
  bool? status;
  List<Coupon>? data;

  CouponModel({this.status, this.data});

  CouponModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Coupon>[];
      json['data'].forEach((v) {
        data!.add(Coupon.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Coupon {
  String? sId;
  String? code;
  String? description;
  String? discountType;
  double? value;
  double? minDonation;
  String? expiryDate;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Coupon({
    this.sId,
    this.code,
    this.description,
    this.discountType,
    this.value,
    this.minDonation,
    this.expiryDate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    description = json['description'];
    discountType = json['discountType'];
    value = json['value'] != null ? (json['value'] as num).toDouble() : null;
    minDonation = json['minDonation'] != null ? (json['minDonation'] as num).toDouble() : null;
    expiryDate = json['expiryDate'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['code'] = code;
    data['description'] = description;
    data['discountType'] = discountType;
    data['value'] = value;
    data['minDonation'] = minDonation;
    data['expiryDate'] = expiryDate;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
