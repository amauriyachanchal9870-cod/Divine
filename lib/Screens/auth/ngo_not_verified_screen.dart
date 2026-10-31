import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';

import '../../Token Manager/token_manager.dart';

class NgoNotVerifiedScreen extends StatelessWidget {
  const NgoNotVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : null;
    final bool isRejected = args?['isRejected'] == true ||
        args?['verificationStatus']?.toString().toLowerCase() == 'rejected';
    final String? rejectionReason = args?['rejectionReason']?.toString().trim();
    final String? customMsg = args?['message']?.toString().trim();

    final String title = isRejected ? "Profile Rejected" : "Profile Not Verified";
    final String defaultPendingMessage =
        customMsg != null && customMsg.isNotEmpty && customMsg != "OTP verified successfully"
            ? customMsg
            : "Your profile is not verified please contact your admin";

    return Scaffold(
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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: (isRejected ? const Color(0xFFEF4444) : Colors.orange).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected ? Icons.highlight_off_rounded : Icons.admin_panel_settings_outlined,
                    size: 84,
                    color: isRejected ? const Color(0xFFDC2626) : Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: AppFonts.titleStyle.copyWith(
                    color: AppTheme.blackColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (isRejected) ...[
                  if (rejectionReason != null &&
                      rejectionReason.isNotEmpty &&
                      rejectionReason != "Your profile has been rejected by admin. For more detail contact to admin.") ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFCA5A5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Rejected Reason",
                                style: AppFonts.titleStyle.copyWith(
                                  color: const Color(0xFF991B1B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rejectionReason,
                            style: AppFonts.regularText.copyWith(
                              color: const Color(0xFF450A0A),
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    "Your profile has been rejected by admin. For more detail contact to admin.",
                    style: AppFonts.regularText.copyWith(
                      color: AppTheme.textGrey500,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    defaultPendingMessage,
                    style: AppFonts.regularText.copyWith(
                      color: AppTheme.textGrey500,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(),
                CustomButton(
                  height: 50,
                  width: double.infinity,
                  title: "Go to Login",
                  onTap: () async {
                    await ManageTokens.clearAllAuthSession();
                    Get.offAllNamed(MyRouters.loginScreen);
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
    );
  }
}
