class WalletModel {
  bool? status;
  WalletData? data;

  WalletModel({this.status, this.data});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    dynamic dataJson = json['data'] ?? json;
    return WalletModel(
      status: json['status'] ?? true,
      data: dataJson != null && dataJson is Map<String, dynamic>
          ? WalletData.fromJson(dataJson)
          : null,
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
  double? cashbackBalance;
  int? totalCoins;
  double? coinsValueInRupees;
  List<WalletTransaction>? transactions;
  List<RechargeTier>? predefinedRechargeTiers;
  List<RechargeTier>? rechargeOffers;

  WalletData({
    this.walletBalance,
    this.cashbackBalance,
    this.totalCoins,
    this.coinsValueInRupees,
    this.transactions,
    this.predefinedRechargeTiers,
    this.rechargeOffers,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    dynamic raw = json['walletBalance'] ??
        json['wallet_balance'] ??
        json['balance'] ??
        json['credits'] ??
        json['creditBalance'] ??
        json['totalBalance'] ??
        json['availableBalance'] ??
        (json['user'] is Map ? (json['user']['walletBalance'] ?? json['user']['balance']) : null);

    double parsedVal = 0.0;
    if (raw is num) {
      parsedVal = raw.toDouble();
    } else if (raw != null) {
      parsedVal = double.tryParse(raw.toString()) ?? 0.0;
    }

    dynamic rawCashback = json['cashbackBalance'] ?? json['cashback_balance'] ?? json['cashback'];
    double parsedCashback = 0.0;
    if (rawCashback is num) {
      parsedCashback = rawCashback.toDouble();
    } else if (rawCashback != null) {
      parsedCashback = double.tryParse(rawCashback.toString()) ?? 0.0;
    }

    dynamic rawCoins = json['totalCoins'] ?? json['total_coins'] ?? json['coins'];
    int parsedCoins = 0;
    if (rawCoins is num) {
      parsedCoins = rawCoins.toInt();
    } else if (rawCoins != null) {
      parsedCoins = int.tryParse(rawCoins.toString()) ?? 0;
    }

    dynamic rawCoinsValue = json['coinsValueInRupees'] ?? json['coins_value_in_rupees'] ?? json['coinsValue'] ?? json['coins_value'];
    double parsedCoinsValue = 0.0;
    if (rawCoinsValue is num) {
      parsedCoinsValue = rawCoinsValue.toDouble();
    } else if (rawCoinsValue != null) {
      parsedCoinsValue = double.tryParse(rawCoinsValue.toString()) ?? 0.0;
    }

    return WalletData(
      walletBalance: parsedVal,
      cashbackBalance: parsedCashback,
      totalCoins: parsedCoins,
      coinsValueInRupees: parsedCoinsValue,
      transactions: json['transactions'] != null
          ? List<WalletTransaction>.from(
              json['transactions'].map((x) => WalletTransaction.fromJson(x)))
          : null,
      predefinedRechargeTiers: json['predefinedRechargeTiers'] != null
          ? List<RechargeTier>.from(
              (json['predefinedRechargeTiers'] as List)
                  .map((x) => RechargeTier.fromJson(x)))
          : null,
      rechargeOffers: json['rechargeOffers'] != null
          ? List<RechargeTier>.from(
              (json['rechargeOffers'] as List)
                  .map((x) => RechargeTier.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['walletBalance'] = walletBalance;
    map['cashbackBalance'] = cashbackBalance;
    map['totalCoins'] = totalCoins;
    map['coinsValueInRupees'] = coinsValueInRupees;
    if (transactions != null) {
      map['transactions'] = transactions!.map((x) => x.toJson()).toList();
    }
    if (predefinedRechargeTiers != null) {
      map['predefinedRechargeTiers'] =
          predefinedRechargeTiers!.map((x) => x.toJson()).toList();
    }
    if (rechargeOffers != null) {
      map['rechargeOffers'] = rechargeOffers!.map((x) => x.toJson()).toList();
    }
    return map;
  }
}

class RechargeTier {
  String? id;
  String? tierId;
  int? amount;
  int? cashback;
  int? bonusCoins;
  String? badgeText;
  String? description;
  bool? isActive;

  RechargeTier({
    this.id,
    this.tierId,
    this.amount,
    this.cashback,
    this.bonusCoins,
    this.badgeText,
    this.description,
    this.isActive,
  });

  factory RechargeTier.fromJson(Map<String, dynamic> json) {
    return RechargeTier(
      id: json['_id'],
      tierId: json['tierId'],
      amount: (json['amount'] as num?)?.toInt(),
      cashback: (json['cashback'] as num?)?.toInt(),
      bonusCoins: (json['bonusCoins'] as num?)?.toInt(),
      badgeText: json['badgeText']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['_id'] = id;
    map['tierId'] = tierId;
    map['amount'] = amount;
    map['cashback'] = cashback;
    map['bonusCoins'] = bonusCoins;
    map['badgeText'] = badgeText;
    map['description'] = description;
    map['isActive'] = isActive;
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
    final Map<String, dynamic> map = <String, dynamic>{};
    map['_id'] = id;
    map['transactionId'] = transactionId;
    map['type'] = type;
    map['user'] = user;
    map['item'] = item;
    map['amount'] = amount;
    map['paymentPlan'] = paymentPlan;
    map['status'] = status;
    map['date'] = date;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    return map;
  }
}
