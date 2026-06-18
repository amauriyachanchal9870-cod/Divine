import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

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
        title: Text(AppString.donationHistory.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTotalDonationSummary(),
              const SizedBox(height: 24),
              _buildHistoryItem("Gau Seva Trust", "20 Feb 2024", "₹50", "Donated NGO"),
              _buildHistoryItem("Gau Seva Trust", "20 Feb 2024", "₹50", "Donated NGO"),
              _buildHistoryItem("Gau Seva Trust", "20 Feb 2024", "₹50", "Donated NGO"),
              _buildHistoryItem("Gau Seva Trust", "19 Feb 2024", "₹50", "Donated NGO"),
              _buildHistoryItem("Gau Seva Trust", "18 Feb 2024", "₹50", "Donated NGO"),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalDonationSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("15", style: AppFonts.titleStyle.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text("Campaigns Supported", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
            ],
          ),
          Container(height: 40, width: 1, color: AppTheme.fieldBorderColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹1200", style: AppFonts.titleStyle.copyWith(fontSize: 20, color: AppTheme.primaryDeepBlue)),
              const SizedBox(height: 4),
              Text(AppString.totalDonations.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String amount, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/ngo_logo.png'), 
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.mediumText.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
              const SizedBox(height: 4),
              Text(
                amount,
                style: AppFonts.semiBoldText.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
