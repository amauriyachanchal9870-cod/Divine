import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.fetchContent(context, 'about-us');
    });
  }

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
        title: Text(AppString.aboutUs.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Obx(() {
        if (_profileController.isLoading.value && _profileController.aboutContent.value.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final title = _profileController.aboutTitle.value;
        final content = _profileController.aboutContent.value;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  title.isNotEmpty ? title : AppString.empoweringChange.tr,
                  style: AppFonts.titleStyle.copyWith(fontSize: 24, height: 1.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  content.isNotEmpty ? content : AppString.aboutUsBody.tr,
                  style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              
              _buildStatCard(Icons.monetization_on_outlined, "\$10M+", AppString.raisedForCharity.tr, isWide: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(Icons.favorite_outline, "50K+", AppString.livesImpacted.tr)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(Icons.verified_outlined, "1.5K+", AppString.verifiedNgosText.tr)),
                ],
              ),
              
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey[200], // Placeholder for image
                  child: Image.asset(AppAssets.campaignImage1, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset(AppAssets.appLogo, fit: BoxFit.cover)),
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                AppString.builtOnTransparency.tr,
                style: AppFonts.titleStyle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppString.aboutUsBody.tr,
                style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500, height: 1.5),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              Text(
                AppString.appNameMultiline.replaceAll('\n', ' '), 
                style: AppFonts.titleStyle.copyWith(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                AppString.copyrightText.tr,
                style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }),
  );
}

  Widget _buildStatCard(IconData icon, String value, String label, {bool isWide = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: isWide ? 20 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF), // Very light blue
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryDeepBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: AppFonts.titleStyle.copyWith(fontSize: 20, color: AppTheme.primaryDeepBlue)),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: AppFonts.semiBoldText.copyWith(fontSize: 10, color: AppTheme.textGrey500, letterSpacing: 0.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
