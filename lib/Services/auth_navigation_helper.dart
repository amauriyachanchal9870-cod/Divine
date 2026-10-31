import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Routes/my_routes.dart';

class AuthNavigationHelper {
  static const String rejectionMessage =
      "Your profile has been rejected by admin. For more detail contact to admin.";

  /// Standardizes verification status string to:
  /// 'Verified', 'Pending', 'Rejected', or null.
  static String? normalizeStatus(dynamic rawStatus) {
    if (rawStatus == null) return null;
    final s = rawStatus.toString().trim().toLowerCase();
    if (s == 'verified' || s == 'approved') return 'Verified';
    if (s == 'pending' || s == 'under_verification' || s == 'under verification') return 'Pending';
    if (s == 'rejected') return 'Rejected';
    return rawStatus.toString().trim();
  }

  /// Central routing method for OTP Verification, Splash Screen, and Registration.
  ///
  /// Routing Rules:
  /// - Case 1: Verified + isProfileComplete == true  -> Home Screen (MyRouters.mainNav)
  /// - Case 2: Verified + isProfileComplete == false -> Choose Role Screen (MyRouters.roleSelectionScreen)
  /// - Case 3: Pending + isProfileComplete == true   -> Profile Under Verification Screen (MyRouters.ngoNotVerifiedScreen)
  /// - Case 4: Rejected                              -> Profile Under Verification Screen with exact rejection message
  static Future<void> navigateBasedOnStatus({
    required dynamic verificationStatus,
    required bool? isProfileComplete,
    String? role,
    String? rejectionReason,
    String? customMessage,
  }) async {
    final status = normalizeStatus(verificationStatus);
    final bool complete = isProfileComplete == true;

    // Cache updated status and profile completeness in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (status != null) {
        await prefs.setString('verificationStatus', status);
        await prefs.setBool('verified', status == 'Verified');
      }
      await prefs.setBool('isProfileComplete', complete);
      if (role != null && role.isNotEmpty) {
        await prefs.setString('role', role);
      }
      if (status == 'Rejected' && rejectionReason != null && rejectionReason.trim().isNotEmpty) {
        await prefs.setString('rejectionReason', rejectionReason.trim());
      } else if (status != 'Rejected') {
        await prefs.remove('rejectionReason');
      }
    } catch (e) {
      debugPrint("Error updating prefs in navigateBasedOnStatus: $e");
    }

    String? effectiveRole = role;
    if (effectiveRole == null || effectiveRole.trim().isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        effectiveRole = prefs.getString('role');
      } catch (_) {}
    }

    final String? normalizedRole = effectiveRole?.trim().toLowerCase();
    final bool isDonorOrIndividual =
        normalizedRole == 'donor' || normalizedRole == 'individual';

    debugPrint("AuthNavigationHelper -> status: $status, isProfileComplete: $complete, role: $role (normalized: $normalizedRole), rejectionReason: $rejectionReason");

    // Additional conditions for Donor and Individual roles:
    // If role == "donor" or role == "individual" and isProfileComplete == false -> Role Selection Screen
    // If role == "donor" or role == "individual" and isProfileComplete == true  -> Home Screen
    if (isDonorOrIndividual) {
      if (complete) {
        Get.offAllNamed(MyRouters.mainNav);
      } else {
        Get.offAllNamed(MyRouters.roleSelectionScreen);
      }
      return;
    }

    // Case 4: Profile Rejected by Admin
    if (status == 'Rejected') {
      final String reason = (rejectionReason != null && rejectionReason.trim().isNotEmpty)
          ? rejectionReason.trim()
          : (customMessage != null && customMessage.trim().isNotEmpty && customMessage != "OTP verified successfully"
              ? customMessage.trim()
              : rejectionMessage);

      Get.offAllNamed(
        MyRouters.ngoNotVerifiedScreen,
        arguments: {
          'isRejected': true,
          'verificationStatus': 'Rejected',
          'rejectionReason': rejectionReason ?? reason,
          'message': reason,
        },
      );
      return;
    }

    // Case 1: Profile Verified and Complete -> Home Screen
    if (status == 'Verified' && complete) {
      Get.offAllNamed(MyRouters.mainNav);
      return;
    }

    // Case 2: Profile Verified but Incomplete -> Choose Role Screen
    if (status == 'Verified' && !complete) {
      Get.offAllNamed(MyRouters.roleSelectionScreen);
      return;
    }

    // Case 3: Profile Pending Verification (profile is complete)
    if (status == 'Pending' && complete) {
      Get.offAllNamed(
        MyRouters.ngoNotVerifiedScreen,
        arguments: {
          'isRejected': false,
          'verificationStatus': 'Pending',
          if (customMessage != null && customMessage.isNotEmpty) 'message': customMessage,
        },
      );
      return;
    }

    // If profile is incomplete (and not rejected) -> Choose Role Screen
    if (!complete) {
      Get.offAllNamed(MyRouters.roleSelectionScreen);
      return;
    }

    // Edge case: Unknown verification status must NEVER navigate to Home.
    // Default to Profile Under Verification Screen.
    Get.offAllNamed(
      MyRouters.ngoNotVerifiedScreen,
      arguments: {
        'isRejected': false,
        'verificationStatus': status ?? 'Pending',
        if (customMessage != null && customMessage.isNotEmpty) 'message': customMessage,
      },
    );
  }
}
