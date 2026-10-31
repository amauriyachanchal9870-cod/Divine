import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';
import '../../Token Manager/token_manager.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isNgo = Get.arguments?['isNgo'] ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightCyanBackground,
              AppTheme.whiteColor,
              AppTheme.whiteColor,
              AppTheme.lightCyanBackground,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              isNgo
                  ? Icon(
                      Icons.pending_actions_rounded,
                      size: 110,
                      color: AppTheme.primaryDeepBlue,
                    )
                  : Image.asset(
                      AppAssets.thankYou,
                      width: 110,
                      height: 110,
                    ),
              const SizedBox(height: 32),
              Text(
                isNgo
                    ? "Profile Under Verification"
                    : AppString.accountCreatedSuccessfully.tr,
                style: AppFonts.titleStyle.copyWith(
                  color: AppTheme.blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (isNgo) ...[
                const SizedBox(height: 16),
                Text(
                  "Thank you for registering. Our verification team is currently reviewing your documents. We will notify you once your profile is approved.",
                  style: AppFonts.regularText.copyWith(
                    color: AppTheme.textGrey500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              CustomButton(
                height: 50,
                width: double.infinity,
                title: isNgo ? "Go to Login" : AppString.home.tr,
                onTap: () async {
                  if (isNgo) {
                    await ManageTokens.clearAllAuthSession();
                    Get.offAllNamed(MyRouters.loginScreen);
                  } else {
                    Get.offAllNamed(MyRouters.mainNav);
                  }
                },
                color: AppTheme.primaryDeepBlue,
                borderRadius: BorderRadius.circular(10),
                showCenter: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
