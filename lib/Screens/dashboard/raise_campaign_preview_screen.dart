import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import '../../Utilities/helper.dart';

class RaiseCampaignPreviewScreen extends StatefulWidget {
  const RaiseCampaignPreviewScreen({super.key});

  @override
  State<RaiseCampaignPreviewScreen> createState() => _RaiseCampaignPreviewScreenState();
}

class _RaiseCampaignPreviewScreenState extends State<RaiseCampaignPreviewScreen> {
  int _activeImageIndex = 0;
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_profileController.profileData.value == null) {
        _profileController.fetchProfile(context);
      }
      final userRole = (_profileController.profileData.value?.role ?? '').toLowerCase();
      if (userRole == 'corporate') {
        showSnackBar("Corporate users cannot raise campaigns", false);
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: Text("No campaign data to preview.")),
      );
    }

    final String title = args["title"] ?? "";
    final String category = args["category"] ?? "";
    final String goal = args["goal"] ?? "0";
    final String description = args["description"] ?? "";
    final DateTime? endDate = args["endDate"] as DateTime?;
    final File? mainImage = args["mainImage"] as File?;
    final List<File> smallImages = (args["smallImages"] as List<File>?) ?? [];
    final VoidCallback onSubmit = args["onSubmit"] as VoidCallback;
    final bool isEdit = args["isEdit"] == true;
    final List<String> networkImages = (args["networkImages"] as List<String>?) ?? [];

    final List<File> allImages = [
      if (mainImage != null) mainImage,
      ...smallImages,
    ];

    final daysLeft = endDate != null ? endDate.difference(DateTime.now()).inDays : 30;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(isEdit ? "Campaign Preview" : AppString.campaignPreview.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                _buildHeaderImageSlider(allImages, networkImages),
                _buildCampaignInfo(title, category, goal, daysLeft),
                _buildDescription(description),
              ],
            ),
          ),
          _buildBottomBar(onSubmit, isEdit),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final profile = _profileController.profileData.value;
      final orgName = profile?.organizationName ?? "Save the Children";
      final orgAddress = profile?.registeredAddress ?? "405, Meghmalhar CHS, CRYSTAL ARMUS, Naraya...";
      final logoUrl = profile?.logo ?? profile?.profilePhoto;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            ClipOval(
              child: (logoUrl != null && logoUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: AppTheme.fieldBorderColor,
                        child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        color: AppTheme.fieldBorderColor,
                        child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: AppTheme.fieldBorderColor,
                      child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orgName,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    orgAddress,
                    style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderImageSlider(List<File> allImages, List<String> networkImages) {
    final totalCount = allImages.length + networkImages.length;
    if (totalCount == 0) {
      return Image.asset(
        AppAssets.campaignImage,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
    }

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: totalCount,
            onPageChanged: (index) {
              setState(() {
                _activeImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (index < allImages.length) {
                return Image.file(
                  allImages[index],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                );
              } else {
                final netIdx = index - allImages.length;
                return CachedNetworkImage(
                  imageUrl: networkImages[netIdx],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (ctx, url, err) => Image.asset(AppAssets.campaignImage, fit: BoxFit.cover),
                );
              }
            },
          ),
          if (totalCount > 1)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalCount,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _activeImageIndex == index
                          ? AppTheme.primaryDeepBlue
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCampaignInfo(String title, String category, String goalStr, int daysLeft) {
    final double goal = double.tryParse(goalStr) ?? 75000.0;
    final formattedGoal = formatPrice(goal);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.titleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            category,
            style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹ 0 raised", style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
              Text("of $formattedGoal", style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500)),
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
              Text("$daysLeft days left", style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87)),
              // const SizedBox(width: 24),
              // const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
              // const SizedBox(width: 6),
              // Text("0 Views", style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Campaign Description", style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(VoidCallback onSubmit, bool isEdit) {
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
                onSubmit();
              },
              child: Text(isEdit ? "Update" : AppString.raiseCampaign.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
