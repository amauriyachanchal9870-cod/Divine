class NotificationModel {
  bool? status;
  List<NotificationData>? data;

  NotificationModel({this.status, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
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

class NotificationData {
  String? sId;
  String? user;
  String? title;
  String? message;
  bool? isRead;
  String? createdAt;
  String? updatedAt;

  NotificationData({
    this.sId,
    this.user,
    this.title,
    this.message,
    this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    title = json['title'];
    message = json['message'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user'] = user;
    data['title'] = title;
    data['message'] = message;
    data['isRead'] = isRead;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
