import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class CampaignDetailsScreen extends StatelessWidget {
  const CampaignDetailsScreen({super.key});

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
        title: Text(AppString.campaignDetails.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black54, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.black54, size: 20), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrganizerRow(),
                _buildHeaderImage(),
                _buildCampaignInfo(),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDescription(),
                const SizedBox(height: 16),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildRecentDonors(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildOrganizerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/ngo_logo.png'),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Arjun Singh", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              Text("Organizer", style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Image.asset(
      'assets/images/campaign_image.png',
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
    );
  }

  Widget _buildCampaignInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rural education Initiative", style: AppFonts.titleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Providing supplies for 50 students", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹ 54,000 raised", style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
              Text("of 75k", style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 54000 / 75000,
            backgroundColor: AppTheme.fieldBorderColor,
            color: AppTheme.progressGreen,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(Icons.people_outline, "1.3K Donors"),
              const SizedBox(width: 16),
              _buildStatChip(Icons.timelapse_rounded, "12 days left"),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.campaignDescription.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            "Technology is one of the most powerful equalizers of our time. This campaign is dedicated to bringing advanced coding labs to underserved rural communities, where potential is high but opportunities are limited. Our mission is to bridge the digital divide by providing modern hardware, reliable high-speed internet, and a well-structured STEM curriculum.\n\nOver the past three months, we've identified five key locations where talent is abundant but access to resources is scarce. Your support goes far beyond funding a laptop—it creates opportunities, builds skills, and connects students to the global economy. For many, this is not just access to technology; it's a chance to shape a brighter future.",
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(AppString.recentDonors.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/ngo_logo.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jameson D.", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text("Donated ₹70", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                        ],
                      ),
                    ),
                    Text("12 min ago", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                Get.toNamed(MyRouters.donateAmountScreen);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
