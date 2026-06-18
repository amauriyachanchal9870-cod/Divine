import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppString.howWouldYouLikeToDonate.tr,
                  style: AppFonts.titleStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              // Join badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.fieldBorderColor),
                  ),
                  child: Text(
                    AppString.joinTransparentDonors.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Two cards: Daan & Fundraisers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDonateCard(
                        title: AppString.daan.tr,
                        imagePath: 'assets/images/donateAndFund.png',
                        onTap: () {
                          Get.toNamed(MyRouters.chooseDaanTypeScreen);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDonateCard(
                        title: AppString.fundraisers.tr,
                        imagePath: 'assets/images/campaign_image.png',
                        onTap: () {
                          Get.toNamed(MyRouters.fundraisersScreen);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Banner: Every Contribution Creates an Impact
              _buildImpactBanner(),
              const SizedBox(height: 32),
              // Trusted section
              _buildTrustedSection(),
              const SizedBox(height: 16),
              // Security footer
              _buildSecurityFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Get.toNamed(MyRouters.searchScreen),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.fieldBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              AppString.searchForCampaigns.tr,
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonateCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.titleStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.progressGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppString.donateNow.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bannerBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.everyContributionCreatesImpact.tr,
                  style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bannerButtonGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppString.startDonating.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppString.tcApply.tr,
                  style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/donateAndFund.png',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const SizedBox(width: 90, height: 90),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Overlapping avatars
          SizedBox(
            width: 80,
            height: 36,
            child: Stack(
              children: [
                Positioned(left: 0, child: _buildAvatar()),
                Positioned(left: 20, child: _buildAvatar()),
                Positioned(
                  left: 40,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDeepBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text("+2k", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.trustedByThousands.tr,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                ),
                Text(
                  AppString.realTimeVerification.tr,
                  style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/images/ngo_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppTheme.progressGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            AppString.endToEndEncrypted.tr,
            style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
          ),
        ],
      ),
    );
  }
}
