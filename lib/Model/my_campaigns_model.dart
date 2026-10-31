import 'campaign_details_model.dart';
import '../Utilities/helper.dart';

class MyCampaignsModel {
  bool? status;
  int? count;
  String? totalRaised;
  num? totalRaisedAmount;
  num? totalGetAmount;
  num? totalReceivedAmount;
  String? totalGoal;
  num? totalGoalAmount;
  num? totalTargetAmount;
  int? totalDonorsCount;
  List<CampaignDetailsData>? myCampaigns;

  MyCampaignsModel({
    this.status,
    this.count,
    this.totalRaised,
    this.totalRaisedAmount,
    this.totalGetAmount,
    this.totalReceivedAmount,
    this.totalGoal,
    this.totalGoalAmount,
    this.totalTargetAmount,
    this.totalDonorsCount,
    this.myCampaigns,
  });

  factory MyCampaignsModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['myCampaigns'] ?? json['campaigns'] ?? json['data'];
    List<CampaignDetailsData> campaigns = [];
    if (rawList != null && rawList is List) {
      campaigns = rawList.map((e) => CampaignDetailsData.fromJson(e)).toList();
    }

    num? raisedAmt = json['totalRaisedAmount'] ?? json['totalGetAmount'] ?? json['totalReceivedAmount'];
    num? goalAmt = json['totalGoalAmount'] ?? json['totalTargetAmount'];

    return MyCampaignsModel(
      status: json['status'],
      count: json['count'] is int
          ? json['count']
          : int.tryParse(json['count']?.toString() ?? '0'),
      totalRaised: json['totalRaised']?.toString(),
      totalRaisedAmount: raisedAmt,
      totalGetAmount: json['totalGetAmount'],
      totalReceivedAmount: json['totalReceivedAmount'],
      totalGoal: json['totalGoal']?.toString(),
      totalGoalAmount: goalAmt,
      totalTargetAmount: json['totalTargetAmount'],
      totalDonorsCount: json['totalDonorsCount'] is int
          ? json['totalDonorsCount']
          : int.tryParse(json['totalDonorsCount']?.toString() ?? '0'),
      myCampaigns: campaigns,
    );
  }

  static double _parseAmount(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    String str = val.toString().replaceAll('₹', '').replaceAll(',', '').replaceAll(' ', '').trim();
    return double.tryParse(str) ?? 0.0;
  }

  String get formattedTotalRaised {
    num amt = totalRaisedAmount ?? totalGetAmount ?? totalReceivedAmount ?? _parseAmount(totalRaised);
    if (amt > 0) {
      return '₹${formatPrice(amt)}';
    }
    if (totalRaised != null && totalRaised!.isNotEmpty) {
      return totalRaised!;
    }
    return '₹0';
  }

  String get formattedTotalGoal {
    num amt = totalGoalAmount ?? totalTargetAmount ?? _parseAmount(totalGoal);
    if (amt > 0) {
      return '₹${formatPrice(amt)}';
    }
    if (totalGoal != null && totalGoal!.isNotEmpty) {
      return totalGoal!;
    }
    return '₹0';
  }
}
