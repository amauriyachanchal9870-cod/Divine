import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class ActiveCampaignsScreen extends StatelessWidget {
  const ActiveCampaignsScreen({super.key});

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
        title: Text(AppString.activeCampaigns.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCampaignCard("assets/images/campaign_image_1.png", "Fund education initiative", "Providing supplies for 50 students", "15,200", "25k", 0.6, "128", "15"),
              _buildCampaignCard("assets/images/campaign_image_2.png", "Fund education initiative", "Providing supplies for 50 students", "24,000", "25k", 0.96, "156", "3"),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(String imagePath, String title, String subtitle, String raised, String goal, double progress, String donors, String daysLeft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: Colors.grey[200], // Placeholder background
              // child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey, size: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text("₹$raised ${AppString.raised.tr}", style: AppFonts.semiBoldText.copyWith(color: AppTheme.progressGreen, fontSize: 13)),
                    const Spacer(),
                    Text("of $goal ${AppString.goal.tr}", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.fieldBorderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.progressGreen),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("$donors ${AppString.donors.tr}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("$daysLeft ${AppString.daysLeft.tr}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryDeepBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                    child: Text(AppString.viewDetails.tr, style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
