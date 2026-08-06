import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Routes/my_routes.dart';
import '../../Model/profile_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NgoProfileDetailScreen extends StatefulWidget {
  const NgoProfileDetailScreen({super.key});

  @override
  State<NgoProfileDetailScreen> createState() => _NgoProfileDetailScreenState();
}

class _NgoProfileDetailScreenState extends State<NgoProfileDetailScreen> {
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    } else {
      profileController = Get.put(ProfileController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.profile.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Obx(() {
        final p = profileController.profileData.value;
        final isLoading = profileController.isLoading.value;

        if (isLoading && p == null) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        if (p == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Failed to load profile details.",
                  style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => profileController.fetchProfile(context),
                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        // Map data from profile api
        final displayName = (p.organizationName != null && p.organizationName!.isNotEmpty)
            ? p.organizationName!
            : (p.name != null && p.name!.isNotEmpty ? p.name! : "");
        
        final displayAddress = (p.registeredAddress != null && p.registeredAddress!.isNotEmpty)
            ? p.registeredAddress!
            : "";

        final profilePhoto = p.profilePhoto ?? p.logo ?? '';
        final ratingValue = p.rating ?? 4.8;
        final impactValue = (p.impactStats != null && p.impactStats!.isNotEmpty)
            ? p.impactStats!.trim().split(RegExp(r'\s+')).first
            : "4.8M";
        
        // Use followers list length or default fallback
        final followersCount = p.followers != null ? "${p.followers!.length}+" : "120+";
        final yearsValue = "100"; // fallback

        final missionText = (p.impactStats != null && p.impactStats!.isNotEmpty)
            ? p.impactStats!
            : "No mission statement available.";

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header section
              Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: profilePhoto.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profilePhoto,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => const ShimmerWidget(
                                width: 100, 
                                height: 100, 
                                borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                              errorWidget: (c, u, e) => const Icon(Icons.person, size: 50, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(displayName, style: AppFonts.titleStyle.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      displayAddress,
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
                            Text("$ratingValue", style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 12)),
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
              ),

              const SizedBox(height: 24),

              // Stats Row section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatPill(impactValue, AppString.impact.tr, AppTheme.primaryDeepBlue),
                    _buildStatPill(followersCount, AppString.followers.tr, AppTheme.primaryDeepBlue),
                    _buildStatPill(yearsValue, AppString.years.tr, AppTheme.primaryDeepBlue),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Edit Profile Button section
              Padding(
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
              ),

              const SizedBox(height: 32),

              // Mission section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppString.ourMission.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    missionText == "No mission statement available."
                        ? Align(
                      alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Text(
                                missionText,
                                style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 12, height: 1.6),
                              ),
                          ),
                        )
                        : Text(
                      missionText,
                      style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category chips row
              _buildCategoriesRow(),

              const SizedBox(height: 32),

              // Reviews section
              _buildReviewsSection(p),

              const SizedBox(height: 32),

              // Verification section
              _buildVerificationSection(p),
            ],
          ),
        );
      }),
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
          Text(value, style: AppFonts.titleStyle.copyWith(color: valueColor, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 10)),
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

  Widget _buildReviewsSection(ProfileData p) {
    final double rating = p.rating ?? 0.0;
    final bool hasReviews = rating > 0;

    final double star5 = (rating >= 4.5) ? ((rating - 4.0) / 1.0).clamp(0.0, 1.0) : 0.0;
    final double star4 = (rating >= 3.5 && rating < 4.5) ? ((rating - 3.0) / 1.5).clamp(0.0, 1.0) : (rating >= 4.5 ? 0.3 : 0.0);
    final double star3 = (rating >= 2.5 && rating < 3.5) ? ((rating - 2.0) / 1.5).clamp(0.0, 1.0) : 0.0;
    final double star2 = (rating >= 1.5 && rating < 2.5) ? ((rating - 1.0) / 1.5).clamp(0.0, 1.0) : 0.0;
    final double star1 = (rating > 0 && rating < 1.5) ? (rating / 1.5).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppString.ratingsAndReviewsUpper.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87)),
              if (hasReviews)
                GestureDetector(
                  onTap: () => Get.toNamed(MyRouters.myReviewsScreen),
                  child: Text(
                    AppString.viewAll.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasReviews)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Text(
                  "No data available",
                  style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13),
                ),
              ),
            )
          else ...[
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
                        Text(rating.toStringAsFixed(1), style: AppFonts.titleStyle.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black87)),
                        const SizedBox(width: 4),
                        Icon(Icons.star, color: AppTheme.amberStars, size: 24),
                      ],
                    ),
                    Text(AppString.reviewsCount.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBarRow("5", star5),
                      _buildRatingBarRow("4", star4),
                      _buildRatingBarRow("3", star3),
                      _buildRatingBarRow("2", star2),
                      _buildRatingBarRow("1", star1),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildVerificationSection(ProfileData p) {
    final hasTaxBenefit = (p.registration12A != null && p.registration12A!.isNotEmpty) || (p.registration80G != null && p.registration80G!.isNotEmpty);
    final hasFcra = p.hasFCRA == true || (p.fcraNumber != null && p.fcraNumber!.isNotEmpty);
    final hasDarpan = p.hasDarpan == true || (p.darpanNumber != null && p.darpanNumber!.isNotEmpty);
    final hasCsr1 = p.hasCSR1 == true || (p.csr1Number != null && p.csr1Number!.isNotEmpty);
    final hasPanGst = (p.panNumber != null && p.panNumber!.isNotEmpty) || (p.gstNumber != null && p.gstNumber!.isNotEmpty);

    final bool hasVerificationData = hasTaxBenefit || hasFcra || hasDarpan || hasCsr1 || hasPanGst;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.verificationAndTransparency.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          if (!hasVerificationData)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Text(
                  "No data available",
                  style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13),
                ),
              ),
            )
          else ...[
            if (hasTaxBenefit)
              _buildVerificationTile(Icons.receipt_long, AppString.taxBenefit.tr, AppString.taxDeductible.tr),
            if (hasTaxBenefit) const SizedBox(height: 12),
            if (hasDarpan || hasCsr1)
              _buildVerificationTile(Icons.description, AppString.annualReport.tr, AppString.financialTransparency.tr),
            if (hasDarpan || hasCsr1) const SizedBox(height: 12),
            if (hasFcra)
              _buildVerificationTile(Icons.gavel, AppString.fcraCompliant.tr, AppString.internationalFunds.tr),
            if (hasPanGst && !hasTaxBenefit && !hasFcra)
              _buildVerificationTile(Icons.verified, "PAN / GST Registered", "Government Registered NGO"),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVerificationTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
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
            child: Icon(icon, color: const Color(0xFF00A669), size: 20),
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
        ],
      ),
    );
  }
}
