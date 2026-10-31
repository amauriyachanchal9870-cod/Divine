import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/home_controller.dart';
import '../Controller/profile_controller.dart';
import '../Controller/auth_controller.dart';
import '../Controller/wallet_controller.dart';
import '../Controller/notification_controller.dart';
import '../Controller/my_campaigns_controller.dart';

class ManageTokens {
  static setUserTokens({
    required String bToken,
    required String cookie,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("bToken", bToken);
    await sharedPreferences.setString("cookie", cookie);
    log("Tokens Saved Successfully");
    log("btokenee::::::::$bToken");
    log("cokieee::::::::$cookie");
  }

  static const String keyOnboardingStartTime = "onboardingStartTime";

  static Future<void> setOnboardingStartTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(keyOnboardingStartTime, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> clearOnboardingStartTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(keyOnboardingStartTime);
  }

  static Future<void> clearOnboardingState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await clearUserTokens();
    await sharedPreferences.remove("isProfileComplete");
    await sharedPreferences.remove(keyOnboardingStartTime);
    await sharedPreferences.remove("role");
    await sharedPreferences.remove("isGoogleSignIn");
    await sharedPreferences.remove("googleEmail");
  }

  static Future<bool> isOnboardingExpired() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? startTime = sharedPreferences.getInt(keyOnboardingStartTime);
    if (startTime == null) {
      await setOnboardingStartTime();
      return false;
    }
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(startTime));
    return diff.inHours >= 48;
  }

  static Future<void> clearUserTokens() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("bToken");
    await sharedPreferences.remove("cookie");
    await sharedPreferences.remove("isUserExist");
    await sharedPreferences.remove("verified");
    await sharedPreferences.remove("verificationStatus");
    await sharedPreferences.remove("rejectionReason");
    await sharedPreferences.remove(keyOnboardingStartTime);
    await sharedPreferences.remove("isGoogleSignIn");
    await sharedPreferences.remove("googleEmail");
    log("Tokens Cleared Successfully");
  }

  /// Clears all local auth tokens, cookies, auth preferences,
  /// social sign-in sessions, and in-memory controllers.
  static Future<void> clearAllAuthSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("bToken");
      await prefs.remove("cookie");
      await prefs.remove("isUserExist");
      await prefs.remove("verified");
      await prefs.remove("verificationStatus");
      await prefs.remove("rejectionReason");
      await prefs.remove("isProfileComplete");
      await prefs.remove(keyOnboardingStartTime);
      await prefs.remove("role");
      await prefs.remove("userPhone");
      await prefs.remove("verifiedMobile");
      await prefs.remove("userEmail");
      await prefs.remove("loginUserID");
      await prefs.remove("isGoogleSignIn");
      await prefs.remove("googleEmail");
    } catch (e) {
      log("Error clearing SharedPreferences in clearAllAuthSession: $e");
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log("Error signing out FirebaseAuth: $e");
    }

    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      log("Error signing out GoogleSignIn: $e");
    }

    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().clearData();
        Get.delete<HomeController>(force: true);
      }
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }
      if (Get.isRegistered<WalletController>()) {
        Get.delete<WalletController>(force: true);
      }
      if (Get.isRegistered<NotificationController>()) {
        Get.delete<NotificationController>(force: true);
      }
      if (Get.isRegistered<MyCampaignsController>()) {
        Get.delete<MyCampaignsController>(force: true);
      }
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        auth.verifiedPhone = null;
        auth.activeSocialProvider = '';
        auth.googleEmail = null;
        auth.isGoogleSignIn = false;
      }
    } catch (e) {
      log("Error resetting controllers in clearAllAuthSession: $e");
    }

    log("All Auth Session Cleared Successfully");
  }

  static Future<Map<String, String>?> getTokenHeaders() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? bToken = sharedPreferences.getString("bToken");
    if (bToken != null && bToken.isNotEmpty) {
      String cookie = sharedPreferences.getString("cookie") ?? "";
      return {
        'Authorization': 'Bearer ${bToken.replaceAll('"', '')}',
        'Cookie': cookie.replaceAll('"', '')
      };
    }
    return null;
  }

  static Future<Map<String, String>> getHttpHeadersWithToken({bool? isXAuthClient}) async {
    final item = await getTokenHeaders();
    final kk = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
      if(isXAuthClient==true)
      // "X-AUTH-CLIENT": "15e3deef-217f-4bad-9ee7-248c74136ef2",
        "X-AUTH-CLIENT": "cf896ad7-67ac-41fd-81f6-cffccc2a5bd3",
      // "X-AUTH-CLIENT": "ee852136-0e3f-418e-a78c-56dac958845a",
    };
    kk.addAll(item ?? {});
    return kk;
  }
}
