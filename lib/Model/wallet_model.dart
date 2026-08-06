class WalletModel {
  bool? status;
  WalletData? data;

  WalletModel({this.status, this.data});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      status: json['status'],
      data: json['data'] != null ? WalletData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class WalletData {
  double? walletBalance;
  List<WalletTransaction>? transactions;

  WalletData({this.walletBalance, this.transactions});

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      transactions: json['transactions'] != null
          ? List<WalletTransaction>.from(
              json['transactions'].map((x) => WalletTransaction.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['walletBalance'] = walletBalance;
    if (transactions != null) {
      map['transactions'] = transactions!.map((x) => x.toJson()).toList();
    }
    return map;
  }
}

class WalletTransaction {
  String? id;
  String? transactionId;
  String? type;
  String? user;
  String? item;
  double? amount;
  String? paymentPlan;
  String? status;
  String? date;
  String? createdAt;
  String? updatedAt;

  WalletTransaction({
    this.id,
    this.transactionId,
    this.type,
    this.user,
    this.item,
    this.amount,
    this.paymentPlan,
    this.status,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'],
      transactionId: json['transactionId'],
      type: json['type'],
      user: json['user'],
      item: json['item'],
      amount: (json['amount'] as num?)?.toDouble(),
      paymentPlan: json['paymentPlan'],
      status: json['status'],
      date: json['date'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'transactionId': transactionId,
      'type': type,
      'user': user,
      'item': item,
      'amount': amount,
      'paymentPlan': paymentPlan,
      'status': status,
      'date': date,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
