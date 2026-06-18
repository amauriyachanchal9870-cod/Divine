import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class ReferralRewardsScreen extends StatelessWidget {
  const ReferralRewardsScreen({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildCoinsHeader(),
              const SizedBox(height: 32),
              _buildReferralCodeBox(),
              const SizedBox(height: 24),
              _buildReferFriendButton(),
              const SizedBox(height: 32),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildTransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsHeader() {
    return Column(
      children: [
        Text(AppString.totalCoins.tr, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text("2,450", style: AppFonts.titleStyle.copyWith(fontSize: 32)),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralCodeBox() {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryDeepBlue),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Divine20", style: AppFonts.titleStyle.copyWith(fontSize: 18, color: AppTheme.primaryDeepBlue)),
                const SizedBox(width: 16),
                Icon(Icons.copy, color: AppTheme.primaryDeepBlue, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferFriendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryDeepBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: () {},
        child: Text(AppString.referFriend.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn("15", AppString.referrals.tr),
        Container(height: 40, width: 1, color: AppTheme.fieldBorderColor),
        _buildStatColumn("12", AppString.rewards.tr),
        Container(height: 40, width: 1, color: AppTheme.fieldBorderColor),
        _buildStatColumn("2450", AppString.totalCoins.tr),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppFonts.semiBoldText.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppString.transactions.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
            Text(AppString.viewAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue)),
          ],
        ),
        const SizedBox(height: 16),
        _buildCoinTransaction("Refer to Mukesh Sharma", "15 Oct 2023 • 10:30 AM", "+50 Coins"),
        _buildCoinTransaction("Refer to Rajesh Kumar", "12 Oct 2023 • 09:15 AM", "+50 Coins"),
        _buildCoinTransaction("Refer to Priya Singh", "10 Oct 2023 • 14:20 PM", "+50 Coins"),
        _buildCoinTransaction("Refer to Amit Patel", "08 Oct 2023 • 11:10 AM", "+50 Coins"),
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
