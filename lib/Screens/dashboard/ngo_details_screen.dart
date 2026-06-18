import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class NgoDetailsScreen extends StatelessWidget {
  const NgoDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isOwnProfile = Get.arguments?['isOwnProfile'] ?? false;

    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.ngoDetails.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: isOwnProfile ? 40 : 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(isOwnProfile),
                const SizedBox(height: 24),
                _buildStatsRow(isOwnProfile),
                if (isOwnProfile) ...[
                  const SizedBox(height: 16),
                  _buildEditProfileButton(),
                ],
                const SizedBox(height: 32),
                _buildMissionSection(),
                const SizedBox(height: 24),
                _buildCategoriesRow(),
                const SizedBox(height: 32),
                _buildReviewsSection(),
                const SizedBox(height: 32),
                _buildVerificationSection(),
              ],
            ),
          ),
          if (!isOwnProfile) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isOwnProfile) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/ngo_logo.png'),
        ),
        const SizedBox(height: 16),
        Text("Green Earth Foundation", style: AppFonts.titleStyle.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            isOwnProfile 
                ? "405, Meghmalhar CHS, CRYSTAL ARMUS, Narayan, Mumbai"
                : AppString.globalHumanitarianOrgDesc.tr,
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.ratingGreenBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppTheme.whiteColor, size: 12),
                  const SizedBox(width: 4),
                  Text("4.8", style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.verifiedBlueBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: AppTheme.primaryDeepBlue, size: 14),
                  const SizedBox(width: 4),
                  Text(AppString.verifiedNgo.tr, style: AppFonts.semiBoldText.copyWith(color: AppTheme.primaryDeepBlue, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isOwnProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatPill("4.8M", AppString.impact.tr, AppTheme.primaryDeepBlue),
          _buildStatPill("120+", isOwnProfile ? AppString.followers.tr : AppString.countries.tr, AppTheme.primaryDeepBlue),
          _buildStatPill("100", AppString.years.tr, AppTheme.primaryDeepBlue),
        ],
      ),
    );
  }

  Widget _buildStatPill(String value, String label, Color valueColor) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackColor.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: AppFonts.titleStyle.copyWith(color: valueColor, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: () => Get.toNamed('/editProfileScreen'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.greyBorderCc),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_outlined, color: Colors.black87, size: 18),
              const SizedBox(width: 8),
              Text(
                AppString.editProfile.tr, 
                style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.ourMission.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Text(
            AppString.ngoMissionText.tr,
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final categories = [
      AppString.emergencyResponse.tr,
      AppString.education.tr,
      AppString.nutrition.tr,
      AppString.protection.tr,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.categoryGreyBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: AppFonts.semiBoldText.copyWith(color: AppTheme.textGrey500, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.ratingsAndReviewsUpper.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("4.4", style: AppFonts.titleStyle.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black87)),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: AppTheme.amberStars, size: 24),
                    ],
                  ),
                  Text(AppString.ratingsCount.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBarRow("5", 0.8),
                    _buildRatingBarRow("4", 0.65),
                    _buildRatingBarRow("3", 0.2),
                    _buildRatingBarRow("2", 0.05),
                    _buildRatingBarRow("1", 0.08),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hydrating Coconut Infusion Shamp...", style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4 ? Icons.star : Icons.star_border,
                      color: index < 4 ? AppTheme.amberStars : Colors.grey,
                      size: 14,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  "This shampoo delivers intense moisture, leaving hair soft and man...",
                  style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  "Avalon • ${AppString.yesterday.tr}",
                  style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey400),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryDeepBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      AppString.rateUs.tr,
                      style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.primaryDeepBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.fieldBorderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      AppString.viewAll.tr,
                      style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBarRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: AppFonts.mediumText.copyWith(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppTheme.borderGreyLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.verificationAndTransparency.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          _buildVerificationTile(Icons.receipt_long, AppString.taxBenefit.tr, AppString.taxDeductible.tr),
          const SizedBox(height: 12),
          _buildVerificationTile(Icons.description, AppString.annualReport.tr, AppString.financialTransparency.tr),
          const SizedBox(height: 12),
          _buildVerificationTile(Icons.gavel, AppString.fcraCompliant.tr, AppString.internationalFunds.tr),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVerificationTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.greyBg50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.ratingGreenBg, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
          color: AppTheme.whiteColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.blackColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryDeepBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: Text(
                      Get.arguments?['isFollowing'] == true ? AppString.unfollow.tr : AppString.follow.tr, 
                      style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volunteer_activism, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
