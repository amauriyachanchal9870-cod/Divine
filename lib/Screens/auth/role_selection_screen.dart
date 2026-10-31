import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/custom_appbar.dart';
import '../../Utilities/helper.dart';
import '../../Token Manager/token_manager.dart';
import '../../Controller/auth_controller.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = '';

  @override
  void initState() {
    super.initState();
    _checkOnboardingExpiry();
  }

  Future<void> _checkOnboardingExpiry() async {
    final isExpired = await ManageTokens.isOnboardingExpired();
    if (isExpired) {
      await ManageTokens.clearOnboardingState();
      showSnackBar("Onboarding session expired. Please verify your mobile number and OTP again to continue.", false);
      Get.offAllNamed(MyRouters.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: AppString.chooseYourRole.tr,
        showBackButton: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        AppString.chooseRoleMatches.tr,
                        style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      _buildRoleOption(
                        title: AppString.donateAndFundraise.tr,
                        subtitle: AppString.supportThroughDonations.tr,
                        imagePath: AppAssets.donateAndFund,
                        value: 'DONOR',
                      ),
                      const SizedBox(height: 16),
                      _buildRoleOption(
                        title: AppString.ngoOrOrganization.tr,
                        subtitle: AppString.createImpactInspireChange.tr,
                        imagePath: AppAssets.ngo,
                        value: 'NGO',
                      ),
                      const SizedBox(height: 16),
                      _buildRoleOption(
                        title: 'Corporate',
                        subtitle: 'Deploy CSR funds & build social impact',
                        imagePath: AppAssets.ngo,
                        value: 'CORPORATE',
                      ),
                      const SizedBox(height: 24),
                      const Spacer(),
                      CustomButton(
                        height: 50,
                        width: double.infinity,
                        title: AppString.continueText.tr,
                        onTap: () async {
                          final isExpired = await ManageTokens.isOnboardingExpired();
                          if (isExpired) {
                            await ManageTokens.clearOnboardingState();
                            showSnackBar("Onboarding session expired. Please verify your mobile number and OTP again to continue.", false);
                            Get.offAllNamed(MyRouters.loginScreen);
                            return;
                          }
                          final AuthController authController = Get.isRegistered<AuthController>()
                              ? Get.find<AuthController>()
                              : Get.put(AuthController());
                          final verifiedPhone = await authController.getVerifiedPhone();
                          final isGoogle = await authController.isGoogleUser();
                          final googleEmail = await authController.getGoogleEmail();

                          if (selectedRole == 'DONOR') {
                            Get.toNamed(MyRouters.profileSetupScreen, arguments: {
                              'isGoogleSignIn': isGoogle,
                              'googleEmail': googleEmail,
                            });
                          } else if (selectedRole == 'NGO') {
                            Get.toNamed(MyRouters.ngoProfileSetupScreen, arguments: {
                              'role': 'ngo',
                              'phone': verifiedPhone,
                              'isGoogleSignIn': isGoogle,
                              'googleEmail': googleEmail,
                            });
                          } else if (selectedRole == 'CORPORATE') {
                            Get.toNamed(MyRouters.ngoProfileSetupScreen, arguments: {
                              'role': 'corporate',
                              'phone': verifiedPhone,
                              'isGoogleSignIn': isGoogle,
                              'googleEmail': googleEmail,
                            });
                          } else {
                            Get.snackbar('Select Role', 'Please choose a role to continue',
                                snackPosition: SnackPosition.BOTTOM);
                          }
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleOption({required String title, required String subtitle, required String imagePath, required String value}) {
    bool isSelected = selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        value == 'DONOR' ? Icons.favorite : Icons.volunteer_activism,
                        color: AppTheme.primaryDeepBlue,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.textGrey400,
            ),
          ],
        ),
      ),
    );
  }
}
