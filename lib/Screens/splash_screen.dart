import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utilities/app_theme.dart';
import '../Routes/my_routes.dart';
import '../Token Manager/token_manager.dart';
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
    Future.delayed(const Duration(seconds: 3), () async {
      var headers = await ManageTokens.getTokenHeaders();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
      bool isProfileComplete = prefs.getBool('isProfileComplete') ?? true;
      String? role = prefs.getString('role');

      if (isFirstTime) {
        Get.offAllNamed(MyRouters.onboardingScreen);
      } else if (headers != null && headers.containsKey('Authorization')) {
        if (isProfileComplete) {
          Get.offAllNamed(MyRouters.mainNav);
        } else {
          Get.offAllNamed(MyRouters.roleSelectionScreen);
        }
      } else {
        Get.offAllNamed(MyRouters.loginScreen);
      }
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
                'assets/images/appLogo.png',
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
