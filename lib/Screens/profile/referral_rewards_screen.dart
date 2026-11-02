import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Controller/profile_controller.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/helper.dart';

class ReferralRewardsScreen extends StatefulWidget {
  const ReferralRewardsScreen({super.key});

  @override
  State<ReferralRewardsScreen> createState() => _ReferralRewardsScreenState();
}

class _ReferralRewardsScreenState extends State<ReferralRewardsScreen> {
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _profileController.fetchReferralData();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.referralsRewards.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Obx(() {
        if (_profileController.isReferralLoading.value) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final data = _profileController.referralData.value;
        final referralCode = data?.referralCode ?? "----";
        final totalCoins = data?.totalCoins ?? 0;
        final totalRewards = data?.totalRewards ?? 0;
        final totalReferral = data?.totalReferral ?? 0;
        final successfulReferral = data?.successfulReferral ?? 0;
        final referralThisMonth = data?.referralThisMonth ?? 0;
        final referralsList = data?.referrals ?? [];

        return RefreshIndicator(
          onRefresh: () => _profileController.fetchReferralData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  _buildCoinsHeader(totalCoins),
                  const SizedBox(height: 32),
                  _buildReferralCodeBox(referralCode),
                  const SizedBox(height: 24),
                  _buildReferFriendButton(referralCode),
                  const SizedBox(height: 32),
                  _buildStatsGrid(
                    totalReferral: totalReferral,
                    successfulReferral: successfulReferral,
                    referralThisMonth: referralThisMonth,
                    totalRewards: totalRewards,
                  ),
                  const SizedBox(height: 32),
                  _buildTransactionsSection(referralsList),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCoinsHeader(int totalCoins) {
    return Column(
      children: [
        Text(AppString.totalCoins.tr, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.currency_rupee, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(totalCoins.toString(), style: AppFonts.titleStyle.copyWith(fontSize: 32)),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralCodeBox(String referralCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Column(
        children: [
          Text(AppString.yourReferralCode.tr, style: AppFonts.mediumText.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              showSnackBar("Referral code copied!", true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryDeepBlue),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(referralCode, style: AppFonts.titleStyle.copyWith(fontSize: 18, color: AppTheme.primaryDeepBlue)),
                  const SizedBox(width: 16),
                  Icon(Icons.copy, color: AppTheme.primaryDeepBlue, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferFriendButton(String referralCode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryDeepBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: "Join Divine Foundation using my referral code: $referralCode"));
          showSnackBar("Referral message copied!", true);
        },
        child: Text(AppString.referFriend.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatsGrid({
    required int totalReferral,
    required int successfulReferral,
    required int referralThisMonth,
    required int totalRewards,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(totalReferral.toString(), AppString.referrals.tr),
          Container(height: 36, width: 1, color: AppTheme.fieldBorderColor),
          _buildStatColumn(successfulReferral.toString(), "Successful"),
          Container(height: 36, width: 1, color: AppTheme.fieldBorderColor),
          _buildStatColumn(referralThisMonth.toString(), "This Month"),
          Container(height: 36, width: 1, color: AppTheme.fieldBorderColor),
          _buildStatColumn(totalRewards.toString(), AppString.rewards.tr),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
      ],
    );
  }

  Widget _buildTransactionsSection(List<dynamic> referralsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppString.transactions.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        referralsList.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    "No referrals yet.\nInvite friends to earn coins!",
                    textAlign: TextAlign.center,
                    style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, height: 1.5),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: referralsList.length,
                itemBuilder: (context, index) {
                  final item = referralsList[index];
                  final name = item.name ?? (item.phone != null && item.phone!.isNotEmpty ? formatPhoneWithCountryCode(item.phone) : (item.email ?? item.title ?? "Friend"));
                  final date = _formatDate(item.createdAt);
                  final coinsEarned = item.coins != null && item.coins > 0 
                      ? "+${item.coins} Coins" 
                      : (item.amount != null && item.amount > 0 ? "+${item.amount} Coins" : "+0 Coins");
                  return _buildCoinTransaction("Referral: $name", date, coinsEarned);
                },
              ),
      ],
    );
  }

  Widget _buildCoinTransaction(String title, String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.mediumText.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                amount,
                style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.amber[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
