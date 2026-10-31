class MasterSettingsModel {
  bool? status;
  MasterSettingsData? data;

  MasterSettingsModel({this.status, this.data});

  MasterSettingsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? MasterSettingsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class MasterSettingsData {
  String? sId;
  List<String>? csrFocusAreas;
  List<String>? fundingPreferences;
  List<String>? nonProfitTypes;
  List<String>? corporateCompanyTypes;
  String? createdAt;
  String? updatedAt;

  MasterSettingsData({
    this.sId,
    this.csrFocusAreas,
    this.fundingPreferences,
    this.nonProfitTypes,
    this.corporateCompanyTypes,
    this.createdAt,
    this.updatedAt,
  });

  MasterSettingsData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    csrFocusAreas = json['csrFocusAreas'] != null ? List<String>.from(json['csrFocusAreas']) : [];
    fundingPreferences = json['fundingPreferences'] != null ? List<String>.from(json['fundingPreferences']) : [];
    nonProfitTypes = json['nonProfitTypes'] != null ? List<String>.from(json['nonProfitTypes']) : [];
    corporateCompanyTypes = json['corporateCompanyTypes'] != null ? List<String>.from(json['corporateCompanyTypes']) : [];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['csrFocusAreas'] = csrFocusAreas;
    data['fundingPreferences'] = fundingPreferences;
    data['nonProfitTypes'] = nonProfitTypes;
    data['corporateCompanyTypes'] = corporateCompanyTypes;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
