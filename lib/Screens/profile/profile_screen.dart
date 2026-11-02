import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_assets.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/auth_controller.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';
import '../../Controller/wallet_controller.dart';
import '../dashboard/main_navigation_screen.dart';
import '../../Utilities/helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await profileController.fetchProfile(context, forceRefresh: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  Obx(() {
                    final userRole = (profileController.profileData.value?.role ?? (Get.isRegistered<HomeController>() ? Get.find<HomeController>().user?.role : "") ?? "").toLowerCase();
                    final isDonor = userRole == "donor";
                    final isCorporate = userRole == "corporate";
                    final isNgo = userRole == "ngo";
                    return Container(
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
                        children: isDonor ? [
                          _buildMenuTile(
                            AppAssets.donationHistory, 
                            AppString.donationHistory.tr, 
                            () => Get.toNamed(MyRouters.donationHistoryScreen)
                          ),
                          if (!isCorporate)
                            _buildMenuTile(
                              AppAssets.createCampaign, 
                              "Raise Campaign".tr, 
                              () => mainNavKey.currentState?.changeTab(2)
                            ),
                          _buildMenuTile(
                            AppAssets.activeCampaign, 
                            AppString.activeCampaigns.tr, 
                            () => Get.toNamed(MyRouters.activeCampaignsScreen)
                          ),
                          _buildMenuTile(
                            AppAssets.activeCampaign, 
                            AppString.myCampaigns.tr, 
                            () => Get.toNamed(MyRouters.myCampaignsScreen)
                          ),
                          _buildMenuTile(
                              AppAssets.follows,
                              AppString.followingNgos.tr,
                                  () => Get.toNamed(MyRouters.followingNgosScreen)
                          ),
                          // _buildMenuTile(
                          //   AppAssets.coupon,
                          //   AppString.coupons.tr,
                          //   () => Get.toNamed(MyRouters.couponsScreen)
                          // ),
                          _buildMenuTile(
                            AppAssets.refer, 
                            AppString.referAndEarn.tr, 
                            // () => Get.toNamed(MyRouters.referralRewardsScreen),
                                  () => Get.toNamed(MyRouters.comingSoonScreen),
                            showDivider: false
                          ),
                        ] : [
                          if (isNgo)
                            _buildMenuTile(
                              AppAssets.homeFill, 
                              "NGO Dashboard", 
                              () => Get.toNamed(MyRouters.ngoDashboardScreen)
                            ),
                          _buildMenuTile(
                            AppAssets.donationHistory, 
                            AppString.donationHistory.tr, 
                            () => Get.toNamed(MyRouters.donationHistoryScreen)
                          ),
                          if (!isCorporate)
                            _buildMenuTile(
                              AppAssets.createCampaign, 
                              "Raise Campaign".tr, 
                              () => mainNavKey.currentState?.changeTab(2)
                            ),
                          _buildMenuTile(
                            AppAssets.activeCampaign, 
                            AppString.activeCampaigns.tr, 
                            () => Get.toNamed(MyRouters.activeCampaignsScreen)
                          ),
                          if (!isCorporate)
                          _buildMenuTile(
                            AppAssets.activeCampaign, 
                            AppString.myCampaigns.tr, 
                            () => Get.toNamed(MyRouters.myCampaignsScreen)
                          ),
                            _buildMenuTile(
                              AppAssets.follows,
                                isNgo ? AppString.socialNetwork.tr : AppString.followingNgos.tr,
                              () => Get.toNamed(MyRouters.followingNgosScreen)
                            ),
                          if (isNgo)
                          _buildMenuTile(
                            AppAssets.myReviews, 
                            AppString.myReviews.tr, 
                            () => Get.toNamed(MyRouters.myReviewsScreen)
                          ),
                          // _buildMenuTile(
                          //   AppAssets.coupon,
                          //   AppString.coupons.tr,
                          //   () => Get.toNamed(MyRouters.couponsScreen)
                          // ),
                          _buildMenuTile(
                            AppAssets.refer, 
                            AppString.referAndEarn.tr, 
                            // () => Get.toNamed(MyRouters.referralRewardsScreen),
                            () => Get.toNamed(MyRouters.comingSoonScreen),
                            showDivider: false
                          ),
                        ],
                      ),
                    );
                  }),
                  
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
                          AppAssets.setting, 
                          AppString.settings.tr, 
                          () => Get.toNamed(MyRouters.settingsScreen)
                        ),
                        _buildMenuTile(
                          AppAssets.helpSupport, 
                          AppString.helpSupport.tr, 
                          () => Get.toNamed(MyRouters.helpSupportScreen)
                        ),
                        _buildMenuTile(
                          AppAssets.termsCondition, 
                          AppString.termsConditions.tr, 
                          () => Get.toNamed(MyRouters.termsConditionScreen)
                        ),
                        _buildMenuTile(
                          AppAssets.privacyPolicy, 
                          AppString.privacyPolicy.tr, 
                          () => Get.toNamed(MyRouters.privacyPolicyScreen)
                        ),
                        _buildMenuTile(
                          AppAssets.aboutUs, 
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
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());
    
    return Obx(() {
      final p = profileController.profileData.value;
      if (profileController.isLoading.value && p == null) {
        return const ShimmerWidget(
          height: 140,
          width: double.infinity,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        );
      }

      final role = (p?.role ?? homeController.user?.role ?? '').toLowerCase();
      final bool isOrg = role == 'ngo' || role == 'corporate';

      final orgName = p?.organizationName ?? "";
      final personName = p?.name ?? homeController.user?.name ?? "";

      final displayName = isOrg
          ? (orgName.isNotEmpty ? orgName : (personName.isNotEmpty ? personName : AppString.divineUser.tr))
          : (personName.isNotEmpty ? personName : (orgName.isNotEmpty ? orgName : AppString.divineUser.tr));

      final displaySubName = isOrg && (orgName.isNotEmpty && personName.isNotEmpty && orgName != personName)
          ? personName
          : "";

      final displayEmail = (p?.email != null && p!.email!.isNotEmpty)
          ? p.email!
          : AppString.emailExample.tr;

      final displayPhone = (p?.phone != null && p!.phone!.isNotEmpty)
          ? p.phone!
          : (homeController.user?.phone ?? "");
      double walletBalance = p?.walletBalance ?? 0.0;
      if (walletBalance == 0.0) {
        if (Get.isRegistered<WalletController>() && Get.find<WalletController>().walletBalance.value > 0) {
          walletBalance = Get.find<WalletController>().walletBalance.value;
        } else if (homeController.homeData.value?.user?.walletBalance != null && (homeController.homeData.value!.user!.walletBalance ?? 0) > 0) {
          walletBalance = homeController.homeData.value!.user!.walletBalance!.toDouble();
        }
      }
      final String formattedWalletBalance = "₹ ${formatPrice(walletBalance)}";
      final profilePhoto = p?.profilePhoto ?? p?.logo ?? homeController.user?.profilePhoto ?? '';

      int totalDonate = homeController.homeData.value?.totalDonateAmount ?? 0;
      // if (totalDonate == 0 && homeController.donationHistory.isNotEmpty) {
      //   totalDonate = homeController.donationHistory.fold<int>(0, (sum, item) => sum + (item.amount ?? 0));
      // }
      final String formattedTotalDonate = "₹ ${formatPrice(totalDonate)}";
      print("Total donate amount ----: $totalDonate");

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
                ClipOval(
                  child: profilePhoto.isNotEmpty
                      ? CachedNetworkImage(
                          key: ValueKey(profilePhoto),
                          imageUrl: profilePhoto,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => const ShimmerWidget(width: 56, height: 56, borderRadius: BorderRadius.all(Radius.circular(28))),
                          errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, width: 56, height: 56, fit: BoxFit.cover),
                        )
                      : Image.asset(AppAssets.appLogo, width: 56, height: 56, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName, 
                        style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displaySubName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          displaySubName, 
                          style: AppFonts.mediumText.copyWith(fontSize: 12, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        displayEmail, 
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displayPhone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          formatPhoneWithCountryCode(displayPhone), 
                          style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (p?.role == "donor") {
                      await Get.toNamed(MyRouters.editProfileScreen);
                    } else {
                      await Get.toNamed(MyRouters.ngoProfileDetailScreen);
                    }
                    if (!mounted) return;
                    profileController.fetchProfile(context, forceRefresh: true);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      p?.role == "donor" ? Icons.edit_outlined : Icons.chevron_right, 
                      color: Colors.black87, 
                      size: 20
                    ),
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
                          formattedWalletBalance, 
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
                          formattedTotalDonate, 
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
    });
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
