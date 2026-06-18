import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import '../../Utilities/helper.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/custom_textfield.dart';
import '../../Routes/my_routes.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = CountryParser.parseCountryCode('IN');

  int get phoneMaxLength {
    if (selectedCountry.countryCode == 'IN') return 10;
    String cleanExample = selectedCountry.example.replaceAll(RegExp(r'\D'), '');
    return cleanExample.isNotEmpty ? cleanExample.length : 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.blackColor, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              AppString.enterYourPhone.tr, 
              style: AppFonts.titleStyle.copyWith(
                color: AppTheme.blackColor,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          selectedCountry = country;
                          phoneController.clear();
                        });
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.fieldBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(selectedCountry.flagEmoji, style: const TextStyle(fontSize: 20)),
                        const Icon(Icons.arrow_drop_down),
                        const SizedBox(width: 4),
                        Text(
                          "+${selectedCountry.phoneCode}",
                          style: AppFonts.semiBoldText.copyWith(
                            color: AppTheme.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CommonTextField(
                    controller: phoneController,
                    hintText: AppString.mobileNumber.tr,
                    keyboardType: TextInputType.phone,
                    borderColor: AppTheme.fieldBorderColor,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(phoneMaxLength),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              height: 50,
              width: double.infinity,
              title: AppString.verify.tr,
              onTap: () {
                if (phoneController.text.trim().isEmpty) {
                  showSnackBar(AppString.enterMobileNumberError.tr, false);
                  return;
                }
                if (phoneController.text.length < phoneMaxLength) {
                  showSnackBar(AppString.enterValidMobileNumberError.tr, false);
                  return;
                }
                Get.toNamed(MyRouters.otpVerificationScreen);
              },
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
              showCenter: true,
            ),
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  text: AppString.dontReceivedCode.tr,
                  style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
                  children: [
                    TextSpan(
                      text: AppString.resend.tr,
                      style: AppFonts.smallText.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
