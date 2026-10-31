import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utilities/app_theme.dart';
import '../Utilities/app_assets.dart';
import '../Utilities/api_constant.dart';
import '../Routes/my_routes.dart';
import '../Token Manager/token_manager.dart';
import '../Services/notification_router.dart';
import '../Services/auth_navigation_helper.dart';
import '../Repo/common_repo.dart';
import '../Model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final headers = await ManageTokens.getTokenHeaders();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

      final bool hasToken = headers != null &&
          headers.containsKey('Authorization') &&
          (headers['Authorization']?.isNotEmpty ?? false);

      if (hasToken) {
        try {
          final String? cachedRole = prefs.getString('role');
          final String url = (cachedRole == 'donor') ? ApiUrls.profileUrl : ApiUrls.ngoProfileUrl;
          
          dynamic response = await Repositories().getApi(
            context: null,
            url: url,
          );

          // If primary request failed or was empty, attempt alternate endpoint
          if (response == null && url == ApiUrls.ngoProfileUrl) {
            response = await Repositories().getApi(
              context: null,
              url: ApiUrls.profileUrl,
            );
          }

          if (response != null) {
            final jsonResponse = jsonDecode(response);
            final profileModel = ProfileModel.fromJson(jsonResponse);

            final dynamic verificationStatus = profileModel.verificationStatus ??
                profileModel.data?.verificationStatus ??
                (profileModel.isVerified == true ? 'Verified' : 'Pending');

            final bool isProfileComplete = profileModel.data?.isProfileComplete ??
                prefs.getBool('isProfileComplete') ??
                false;

            final String? role = profileModel.data?.role ?? cachedRole;
            final String? rejectionReason = profileModel.rejectionReason ??
                profileModel.data?.rejectionReason ??
                jsonResponse['rejectionReason']?.toString() ??
                jsonResponse['rejection_reason']?.toString() ??
                prefs.getString('rejectionReason');

            await AuthNavigationHelper.navigateBasedOnStatus(
              verificationStatus: verificationStatus,
              isProfileComplete: isProfileComplete,
              role: role,
              rejectionReason: rejectionReason,
            );
          } else {
            // Unauthenticated / expired token
            await ManageTokens.clearAllAuthSession();
            Get.offAllNamed(MyRouters.loginScreen);
          }
        } catch (e) {
          debugPrint("Error fetching profile on splash screen: $e");
          // If network exception occurred, check onboarding expiry and cached status
          final isExpired = await ManageTokens.isOnboardingExpired();
          if (isExpired) {
            await ManageTokens.clearAllAuthSession();
            Get.offAllNamed(MyRouters.loginScreen);
          } else {
            final cachedStatus = prefs.getString('verificationStatus');
            final cachedVerified = prefs.getBool('verified');
            final cachedComplete = prefs.getBool('isProfileComplete') ?? false;
            final dynamic status = cachedStatus ?? (cachedVerified == true ? 'Verified' : 'Pending');
            final String? cachedReason = prefs.getString('rejectionReason');

            await AuthNavigationHelper.navigateBasedOnStatus(
              verificationStatus: status,
              isProfileComplete: cachedComplete,
              role: prefs.getString('role'),
              rejectionReason: cachedReason,
            );
          }
        }
      } else if (isFirstTime) {
        Get.offAllNamed(MyRouters.onboardingScreen);
      } else {
        Get.offAllNamed(MyRouters.loginScreen);
      }

      // Mark navigation ready so pending notifications from terminated launch can process
      NotificationRouter.setNavigationReady(true);
    });
  }

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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.appLogo,
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'Divine Foundation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDeepBlue,
                    ),
                  );
                },
              ),
              Text(
                'Divine',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDeepBlue,
                ),
              ),Text(
                'Foundation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.primaryDeepBlue,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
