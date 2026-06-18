import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Image.asset(
                'assets/icons/thankYouIcon.png',
                width: 110,
                height: 110,
              ),
              const SizedBox(height: 32),
              Text(
                AppString.accountCreatedSuccessfully.tr,
                style: AppFonts.titleStyle.copyWith(
                  color: AppTheme.blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                height: 50,
                width: double.infinity,
                title: AppString.home.tr,
                onTap: () {
                  // Navigate to home screen
                  Get.offAllNamed(MyRouters.mainNav);
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
