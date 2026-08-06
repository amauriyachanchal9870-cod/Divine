import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Utilities/app_theme.dart';

class TermsConditionScreen extends StatefulWidget {
  const TermsConditionScreen({super.key});

  @override
  State<TermsConditionScreen> createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
  final ProfileController _profileController = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.fetchContent(context, 'terms-conditions');
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
        title: Obx(() {
          final title = _profileController.termsTitle.value;
          return Text(
            title.isNotEmpty ? title : AppString.termsConditions.tr,
            style: AppFonts.titleStyle.copyWith(fontSize: 18),
          );
        }),
        centerTitle: false,
      ),
      body: Obx(() {
        if (_profileController.isLoading.value && _profileController.termsContent.value.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final content = _profileController.termsContent.value;
        if (content.isEmpty) {
          return Center(
            child: Text(
              "No content available",
              style: AppFonts.regularText.copyWith(color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              content,
              style: AppFonts.regularText.copyWith(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        );
      }),
    );
  }
}
