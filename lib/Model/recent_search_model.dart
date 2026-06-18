class RecentSearchModel {
  bool? status;
  List<String>? data;

  RecentSearchModel({this.status, this.data});

  RecentSearchModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = List<String>.from(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }
}
