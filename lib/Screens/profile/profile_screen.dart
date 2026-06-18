import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeaderCard(),
                const SizedBox(height: 24),
                
                // Activities Group
                Text(
                  AppString.activities.tr, 
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.hintTextColor)
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.blackColor.withValues(alpha: 0.015),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        "assets/icons/donationHistoryIcon.png", 
                        AppString.donationHistory.tr, 
                        () => Get.toNamed(MyRouters.donationHistoryScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/createCampaignIcon.png", 
                        AppString.createCampaign.tr, 
                        () => Get.toNamed(MyRouters.raiseCampaignWizardScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/activeCampaignIcon.png", 
                        AppString.activeCampaigns.tr, 
                        () => Get.toNamed(MyRouters.activeCampaignsScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/followsIcon.png", 
                        AppString.follows.tr, 
                        () => Get.toNamed(MyRouters.followingNgosScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/myReviewsIcon.png", 
                        AppString.myReviews.tr, 
                        () => Get.toNamed(MyRouters.myReviewsScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/couponIcon.png", 
                        AppString.coupons.tr, 
                        () => Get.toNamed(MyRouters.couponsScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/referIcon.png", 
                        AppString.referAndEarn.tr, 
                        () => Get.toNamed(MyRouters.referralRewardsScreen),
                        showDivider: false
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info & Support Group
                Text(
                  AppString.infoSupport.tr, 
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.hintTextColor)
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.blackColor.withValues(alpha: 0.015),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        "assets/icons/settingIcon.png", 
                        AppString.settings.tr, 
                        () => Get.toNamed(MyRouters.settingsScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/helpSupportIcon.png", 
                        AppString.helpSupport.tr, 
                        () => Get.toNamed(MyRouters.helpSupportScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/termsConditionIcon.png", 
                        AppString.termsConditions.tr, 
                        () => Get.toNamed(MyRouters.termsConditionScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/privacyPolicyIcon.png", 
                        AppString.privacyPolicy.tr, 
                        () => Get.toNamed(MyRouters.privacyPolicyScreen)
                      ),
                      _buildMenuTile(
                        "assets/icons/aboutUsIcon.png", 
                        AppString.aboutUs.tr, 
                        () => Get.toNamed(MyRouters.aboutUsScreen),
                        showDivider: false
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                _buildLogoutButton(context, authController),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/images/ngo_logo.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Green Earth Foundation", 
                      style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "aman@gmail.com", 
                      style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "+91 7845844848", 
                      style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(MyRouters.ngoDetailsScreen, arguments: {'isOwnProfile': true}),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.black87, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDottedLine(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: AppTheme.hintTextColor, size: 22),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹1,250", 
                        style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87)
                      ),
                      Text(
                        AppString.totalBalance.tr, 
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.volunteer_activism_outlined, color: AppTheme.hintTextColor, size: 22),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹500", 
                        style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87)
                      ),
                      Text(
                        AppString.totalDonated.tr, 
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDottedLine() {
    return Row(
      children: List.generate(40, (index) {
        return Expanded(
          child: Container(
            height: 1,
            color: index % 2 == 0 ? AppTheme.greyBg300.withValues(alpha: 0.6) : Colors.transparent,
          ),
        );
      }),
    );
  }

  Widget _buildMenuTile(String iconAsset, String title, VoidCallback onTap, {bool showDivider = true}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Image.asset(
                  iconAsset, 
                  width: 20, 
                  height: 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title, 
                    style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87)
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textGrey400, size: 20),
              ],
            ),
          ),
          if (showDivider)
            Divider(height: 1, thickness: 0.5, color: AppTheme.borderGreyLighter, indent: 16, endIndent: 16),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthController authController) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.whiteColor,
          side: BorderSide(color: AppTheme.fieldBorderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.greyDividerE0,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppString.logOut.tr,
                    style: AppFonts.titleStyle.copyWith(fontSize: 22, color: AppTheme.redColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppString.areYouSureLogout.tr,
                    style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey500, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.fieldBorderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Get.back(),
                          child: Text(AppString.cancel.tr, style: AppFonts.semiBoldText.copyWith(color: AppTheme.blackColor, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.redColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Get.back(); // close bottom sheet
                            authController.logout(context);
                          },
                          child: Text(AppString.logout.tr, style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            isScrollControlled: true,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_outlined, color: AppTheme.redColor, size: 20),
            const SizedBox(width: 8),
            Text(AppString.logOut.tr, style: AppFonts.semiBoldText.copyWith(color: AppTheme.redColor, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
