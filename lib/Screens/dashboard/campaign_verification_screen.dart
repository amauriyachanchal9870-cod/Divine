import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';

class CampaignVerificationScreen extends StatelessWidget {
  const CampaignVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAllNamed(MyRouters.mainNav);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pending_actions_outlined,
                      size: 80,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Campaign is under verification",
                    style: AppFonts.titleStyle.copyWith(
                      color: AppTheme.blackColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "For more information contact admin",
                    style: AppFonts.regularText.copyWith(
                      color: AppTheme.textGrey500,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  CustomButton(
                    height: 50,
                    width: double.infinity,
                    title: "Go to Home",
                    onTap: () {
                      Get.offAllNamed(MyRouters.mainNav);
                    },
                    color: AppTheme.primaryDeepBlue,
                    borderRadius: BorderRadius.circular(10),
                    showCenter: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
