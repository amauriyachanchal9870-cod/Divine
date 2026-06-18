import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/custom_appbar.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: AppString.loginSignYourAccount.tr,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              AppString.chooseYourRole.tr,
              style: AppFonts.titleStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              AppString.chooseRoleMatches.tr,
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
            ),
            const SizedBox(height: 40),
            _buildRoleOption(
              title: AppString.donateAndFundraise.tr,
              subtitle: AppString.supportThroughDonations.tr,
              imagePath: 'assets/images/donateAndFund.png',
              value: 'DONOR',
            ),
            const SizedBox(height: 20),
            _buildRoleOption(
              title: AppString.ngoOrOrganization.tr,
              subtitle: AppString.createImpactInspireChange.tr,
              imagePath: 'assets/images/ngo.png',
              value: 'NGO',
            ),
            const Spacer(),
            CustomButton(
              height: 50,
              width: double.infinity,
              title: AppString.continueText.tr,
              onTap: () {
                if (selectedRole == 'DONOR') {
                  Get.toNamed(MyRouters.profileSetupScreen);
                } else if (selectedRole == 'NGO') {
                  Get.toNamed(MyRouters.ngoProfileSetupScreen);
                } else {
                  Get.snackbar('Select Role', 'Please choose a role to continue',
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              color: AppTheme.primaryDeepBlue,
              borderRadius: BorderRadius.circular(10),
              showCenter: true,
            ),
            const SizedBox(height: 40),
          ],
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
