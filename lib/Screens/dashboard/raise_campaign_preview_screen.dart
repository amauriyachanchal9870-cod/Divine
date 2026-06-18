import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class RaiseCampaignPreviewScreen extends StatelessWidget {
  const RaiseCampaignPreviewScreen({super.key});

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
        title: Text(AppString.campaignPreview.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(context),
                _buildCampaignInfo(),
                _buildDescription(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Image.asset(
      'assets/images/campaign_image.png',
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
    );
  }

  Widget _buildCampaignInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rural education Initiative", style: AppFonts.titleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            "Providing supplies for 50 students",
            style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹ 0 raised", style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
              Text("of 75k", style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.0,
            backgroundColor: AppTheme.fieldBorderColor,
            color: AppTheme.progressGreen,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text("0 Donors", style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87)),
              const SizedBox(width: 24),
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text("30 days left", style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Campaign Description", style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            "Technology is one of the most powerful equalizers of our time. This campaign is dedicated to bringing advanced coding labs to underserved rural communities, where potential is high but opportunities are limited. Our mission is to bridge the digital divide by providing modern hardware, reliable high-speed internet, and a well-structured STEM curriculum.\n\nOver the past three months, we've identified five key locations where talent is abundant but access to resources is scarce. Your support goes far beyond funding a laptop - it creates opportunities, builds skills, and connects students to the global economy. For many, this is not just access to technology; it's a chance to shape a brighter future.",
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDeepBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                // Submit final campaign logic
              },
              child: Text(AppString.raiseCampaign.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
