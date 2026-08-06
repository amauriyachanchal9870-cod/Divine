import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/follows_controller.dart';
import '../../Controller/ngo_details_controller.dart';
import '../../Model/ngo_details_model.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NgoDetailsScreen extends StatelessWidget {
  const NgoDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isOwnProfile = Get.arguments?['isOwnProfile'] ?? false;
    final String ngoId = Get.arguments?['id'] ?? Get.arguments?['ngoId'] ?? '';

    final NgoDetailsController? detailsController = ngoId.isNotEmpty
        ? Get.put(NgoDetailsController(ngoId: ngoId), tag: ngoId)
        : null;

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
      body: detailsController == null
          ? Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: isOwnProfile ? 40 : 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeaderFallback(isOwnProfile),
                      const SizedBox(height: 24),
                      _buildStatsRowFallback(isOwnProfile),
                      if (isOwnProfile) ...[
                        const SizedBox(height: 16),
                        _buildEditProfileButton(),
                      ],
                      const SizedBox(height: 32),
                      _buildMissionSectionFallback(),
                      const SizedBox(height: 24),
                      _buildCategoriesRow(),
                      const SizedBox(height: 32),
                      _buildReviewsSection(context, detailsController),
                      const SizedBox(height: 32),
                      _buildVerificationSection(NgoDetailsData()),
                    ],
                  ),
                ),
                if (!isOwnProfile) _buildBottomBar(),
              ],
            )
          : Obx(() {
              if (detailsController.isLoading.value) {
                return Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                    color: AppTheme.primaryDeepBlue,
                    size: 50,
                  ),
                );
              }
              if (detailsController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    detailsController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final data = detailsController.ngoDetails.value;
              if (data == null) {
                return const Center(child: Text("NGO details not found."));
              }
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeader(data, isOwnProfile),
                        const SizedBox(height: 24),
                        _buildStatsRow(data, isOwnProfile),
                        const SizedBox(height: 32),
                        _buildMissionSection(data),
                        const SizedBox(height: 24),
                        _buildCategoriesRow(),
                        const SizedBox(height: 32),
                        _buildReviewsSection(context, detailsController),
                        const SizedBox(height: 32),
                        _buildVerificationSection(data),
                      ],
                    ),
                  ),
                  _buildBottomBar(),
                ],
              );
            }),
    );
  }

  Widget _buildHeaderFallback(bool isOwnProfile) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(AppAssets.ngoLogo),
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

  Widget _buildHeader(NgoDetailsData data, bool isOwnProfile) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade200,
          child: data.logo != null && data.logo!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: data.logo!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppTheme.primaryDeepBlue,
                        size: 24,
                      ),
                    ),
                    errorWidget: (c, u, e) => Image.asset(AppAssets.ngoLogo, fit: BoxFit.cover),
                  ),
                )
              : ClipOval(child: Image.asset(AppAssets.ngoLogo, fit: BoxFit.cover)),
        ),
        const SizedBox(height: 16),
        Text(data.name ?? '', style: AppFonts.titleStyle.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            data.about != null && data.about!.isNotEmpty ? data.about! : AppString.globalHumanitarianOrgDesc.tr,
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
                  Text("${data.rating ?? 4.5}", style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 12)),
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
                  Text(data.status ?? AppString.verifiedNgo.tr, style: AppFonts.semiBoldText.copyWith(color: AppTheme.primaryDeepBlue, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRowFallback(bool isOwnProfile) {
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

  Widget _buildStatsRow(NgoDetailsData data, bool isOwnProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatPill(
            (data.impactStats != null && data.impactStats!.isNotEmpty) ? data.impactStats! : "4.8M",
            AppString.impact.tr,
            AppTheme.primaryDeepBlue
          ),
          _buildStatPill(
            data.verifiedCampaignsCount?.toString() ?? "0",
            "Campaigns",
            AppTheme.primaryDeepBlue
          ),
          _buildStatPill(
            (data.years != null && data.years!.isNotEmpty) ? data.years! : "5+",
            AppString.years.tr,
            AppTheme.primaryDeepBlue
          ),
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

  Widget _buildMissionSectionFallback() {
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

  Widget _buildMissionSection(NgoDetailsData data) {
    String missionText = data.ourMission ?? '';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.ourMission.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          missionText.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor,
                    border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined, color: AppTheme.textGrey400, size: 40),
                      const SizedBox(height: 12),
                      Text("No data available", style: AppFonts.semiBoldText.copyWith(color: AppTheme.textGrey500)),
                    ],
                  ),
                )
              : Text(
                  missionText,
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

  Widget _buildReviewsSection(BuildContext context, NgoDetailsController? controller) {
    final double rating = controller?.ngoDetails.value?.rating ?? 0.0;
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
                      Text(rating.toStringAsFixed(1), style: AppFonts.titleStyle.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black87)),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: AppTheme.amberStars, size: 24),
                    ],
                  ),
                  Text("${rating > 0 ? '1' : '0'} ratings", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
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
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, color: AppTheme.textGrey400, size: 40),
                const SizedBox(height: 12),
                Text("No review available", style: AppFonts.semiBoldText.copyWith(color: AppTheme.textGrey500)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      _showRateUsBottomSheet(context, controller);
                    },
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
                    onPressed: () {
                      Get.toNamed(MyRouters.myReviewsScreen);
                    },
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

  Widget _buildVerificationSection(NgoDetailsData data) {
    // Assuming no mapped verification objects yet from backend API
    bool hasData = data.kycDocs != null && data.kycDocs!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.verificationAndTransparency.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          hasData
              ? Column(
                  children: [
                    _buildVerificationTile(Icons.receipt_long, AppString.taxBenefit.tr, AppString.taxDeductible.tr),
                    const SizedBox(height: 12),
                    _buildVerificationTile(Icons.description, AppString.annualReport.tr, AppString.financialTransparency.tr),
                    const SizedBox(height: 12),
                    _buildVerificationTile(Icons.gavel, AppString.fcraCompliant.tr, AppString.internationalFunds.tr),
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor,
                    border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.verified_user_outlined, color: AppTheme.textGrey400, size: 40),
                      const SizedBox(height: 12),
                      Text("No data available", style: AppFonts.semiBoldText.copyWith(color: AppTheme.textGrey500)),
                    ],
                  ),
                ),
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
    final String ngoId = Get.arguments?['id'] ?? '';
    final FollowsController followsController = Get.put(FollowsController());
    final NgoDetailsController? detailsController = Get.isRegistered<NgoDetailsController>(tag: ngoId) 
        ? Get.find<NgoDetailsController>(tag: ngoId) 
        : null;

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
                  child: Obx(() {
                    final bool isFollowing = followsController.isNgoFollowed(ngoId);
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryDeepBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (ngoId.isNotEmpty) {
                          followsController.toggleFollowNgoApi(ngoId);
                        }
                      },
                      child: Text(
                        isFollowing ? AppString.unfollow.tr : AppString.follow.tr, 
                        style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    );
                  }),
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
                    onPressed: () {
                      final String? logoUrl = detailsController?.ngoDetails.value?.logo;
                      final String ngoName = detailsController?.ngoDetails.value?.name ?? Get.arguments?['name'] ?? 'NGO';
                      
                      Get.toNamed(
                        MyRouters.donateAmountScreen,
                        arguments: {
                          'isNgo': true,
                          'id': ngoId,
                          'name': ngoName,
                          'logoUrl': logoUrl ?? "",
                        },
                      );
                    },
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

  void _showRateUsBottomSheet(BuildContext context, NgoDetailsController? controller) {
    int selectedStars = 0;
    final TextEditingController feedbackController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text("Rate Us", style: AppFonts.titleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.greyBg50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 18, color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Tell us your experience", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedStars = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star,
                              color: index < selectedStars ? AppTheme.amberStars : Colors.grey.shade300,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        maxLength: 180,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Write your Feedback...",
                          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          counterText: "", 
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("${feedbackController.text.length}/180", style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFEAEAEA),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("May be later", style: AppFonts.semiBoldText.copyWith(color: Colors.black87, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: controller != null ? Obx(() {
                            bool isLoading = controller.isSubmittingReview.value;
                            return ElevatedButton(
                              onPressed: isLoading ? null : () async {
                                if (feedbackController.text.trim().isEmpty) {
                                  showSnackBar("Please enter feedback", false);
                                  return;
                                }
                                if (selectedStars > 0) {
                                  String targetName = controller.ngoDetails.value?.name ?? Get.arguments?['name'] ?? 'NGO';
                                  bool success = await controller.submitReview(targetName, selectedStars, feedbackController.text);
                                  if (success) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showThanksBottomSheet(context, selectedStars);
                                    }
                                  }
                                } else {
                                  showSnackBar("Please select a rating", false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryDeepBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            );
                          }) : ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryDeepBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }

  void _showThanksBottomSheet(BuildContext context, int rating) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text("😍", style: TextStyle(fontSize: 48)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.greyBg50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Thanks!", style: AppFonts.titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Tell us your experience", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      color: index < rating ? AppTheme.amberStars : Colors.grey.shade300,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
