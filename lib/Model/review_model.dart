class ReviewModel {
  bool? status;
  List<ReviewItem>? data;

  ReviewModel({this.status, this.data});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      status: json['status'],
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List).map((x) => ReviewItem.fromJson(x)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    if (data != null) {
      map['data'] = data!.map((x) => x.toJson()).toList();
    }
    return map;
  }
}

class ReviewItem {
  String? id;
  String? reviewId;
  String? userName;
  String? userRole;
  String? type;
  String? targetName;
  double? rating;
  String? comment;
  String? videoUrl;
  String? status;
  String? createdAt;
  String? updatedAt;
  bool isPinned;
  int helpfulCount;

  ReviewItem({
    this.id,
    this.reviewId,
    this.userName,
    this.userRole,
    this.type,
    this.targetName,
    this.rating,
    this.comment,
    this.videoUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.helpfulCount = 0,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: (json['_id'] ?? json['id'])?.toString(),
      reviewId: json['reviewId']?.toString(),
      userName: (json['userName'] ?? json['user']?['name'] ?? json['user']?['userName'] ?? json['donorName'])?.toString(),
      userRole: (json['userRole'] ?? json['role'])?.toString(),
      type: json['type']?.toString(),
      targetName: (json['targetName'] ?? json['ngoName'])?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: (json['comment'] ?? json['message'] ?? json['review'])?.toString(),
      videoUrl: (json['videoUrl'] ?? json['video'] ?? json['mediaUrl'] ?? json['media'] ?? json['video_url'])?.toString(),
      status: json['status']?.toString(),
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  bool get hasVideo {
    return videoUrl != null && videoUrl!.trim().isNotEmpty;
  }

  String get effectiveVideoUrl {
    return videoUrl?.trim() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['_id'] = id;
    map['reviewId'] = reviewId;
    map['userName'] = userName;
    map['userRole'] = userRole;
    map['type'] = type;
    map['targetName'] = targetName;
    map['rating'] = rating;
    map['comment'] = comment;
    map['videoUrl'] = videoUrl;
    map['status'] = status;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    return map;
  }
}
