import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utilities/app_theme.dart';
import '../Utilities/app_string.dart';
import '../Utilities/app_fonts.dart';
import '../Utilities/custom_button.dart';
import '../Routes/my_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": AppString.giveWithPurpose.tr,
      "subtitle": AppString.giveWithPurposeSub.tr,
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": AppString.raiseForACause.tr,
      "subtitle": AppString.raiseForACauseSub.tr,
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": AppString.trustedAndTransparent.tr,
      "subtitle": AppString.trustedAndTransparentSub.tr,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _onboardingData[index]["image"]!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
          
          // Gradient Overlay to ensure text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5, // Gradient covers bottom half
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Content Container at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppTheme.primaryDeepBlue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _onboardingData[_currentPage]["title"]!,
                    style: AppFonts.titleStyle.copyWith(
                      color: AppTheme.blackColor,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    _onboardingData[_currentPage]["subtitle"]!,
                    style: AppFonts.regularText.copyWith(
                      color: AppTheme.textGrey500,
                      height: 1.5,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Dynamic Button
                  CustomButton(
                    height: 50,
                    width: double.infinity,
                    title: _currentPage == _onboardingData.length - 1 
                        ? AppString.getStartedText.tr 
                        : AppString.continueText.tr,
                    onTap: () async {
                      if (_currentPage == _onboardingData.length - 1) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstTime', false);
                        Get.offAllNamed(MyRouters.loginScreen);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    color: AppTheme.primaryDeepBlue,
                    borderRadius: BorderRadius.circular(10),
                    showCenter: true,
                  ),
                ],
              ),
            ),
          ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Do not set isFirstTime to false so onboarding shows again on next launch
                Get.offAllNamed(MyRouters.loginScreen);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppString.skipText.tr,
                  style: AppFonts.mediumText.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
