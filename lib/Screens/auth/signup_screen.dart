import 'package:divine_foundation/Utilities/app_assets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import '../../Utilities/helper.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = CountryParser.parseCountryCode('IN');
  final AuthController authController = Get.put(AuthController());

  int get phoneMaxLength {
    if (selectedCountry.countryCode == 'IN') return 10;
    String cleanExample = selectedCountry.example.replaceAll(RegExp(r'\D'), '');
    return cleanExample.isNotEmpty ? cleanExample.length : 15;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.screenBackground, // Light grey background
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/appLogo.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppString.appNameMultiline.tr.replaceAll('\n', ' '),
                      textAlign: TextAlign.center,
                      style: AppFonts.appNameStyle.copyWith(
                        color: AppTheme.primaryDeepBlue,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                decoration: BoxDecoration(
                  color: AppTheme.whiteColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppTheme.blackColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        AppString.createYourAccount.tr,
                        style: AppFonts.titleStyle.copyWith(
                          color: AppTheme.blackColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        AppString.pleaseEnterDetailsToGetStarted.tr,
                        style: AppFonts.smallText.copyWith(
                          color: AppTheme.textGrey500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.whiteColor,
                              border: Border.all(color: AppTheme.fieldBorderColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(selectedCountry.flagEmoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, color: AppTheme.textGrey400),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.whiteColor,
                              border: Border.all(color: AppTheme.fieldBorderColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    "+${selectedCountry.phoneCode}",
                                    style: AppFonts.semiBoldText.copyWith(
                                      color: AppTheme.blackColor,fontSize: 12
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(phoneMaxLength),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: AppString.mobileNumber.tr,
                                      hintStyle: AppFonts.hintStyle.copyWith(color: AppTheme.textGrey400, fontSize: 12),
                                      border: InputBorder.none,
                                      isDense: true,
                                      // contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                      counterText: "",
                                    ),
                                    keyboardType: TextInputType.phone,
                                    style: AppFonts.regularText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.primaryDeepBlue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppString.weWillSendVerificationCode.tr,
                              style: AppFonts.smallText.copyWith(
                                color: AppTheme.primaryDeepBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 90),
                    CustomButton(
                      height: 50,
                      width: double.infinity,
                      title: AppString.continueText.tr,
                      onTap: () {
                        if (phoneController.text.trim().isEmpty) {
                          showSnackBar(AppString.enterMobileNumberError.tr, false);
                          return;
                        }
                        if (phoneController.text.length < phoneMaxLength) {
                          showSnackBar(AppString.enterValidMobileNumberError.tr, false);
                          return;
                        }
                        String formattedPhone = "+${selectedCountry.phoneCode} ${phoneController.text.trim()}";
                        authController.loginUser(context, formattedPhone);
                      },
                      color: AppTheme.primaryDeepBlue,
                      borderRadius: BorderRadius.circular(10),
                      showCenter: true,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: AppString.alreadyHaveAccount.tr,
                          style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
                          children: [
                            TextSpan(
                              text: AppString.login.tr,
                              style: AppFonts.boldLink.copyWith(
                                color: AppTheme.primaryDeepBlue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed(MyRouters.loginScreen);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.textGrey200, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppString.orContinueWith.tr,
                            style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.textGrey200, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _socialButton(AppAssets.apple,)),
                       // const SizedBox(width: 16),
                        // Expanded(child: _socialButton("assets/images/facebook.png", Icons.facebook, AppTheme.fbColor)),
                        const SizedBox(width: 16),
                        Expanded(child: _socialButton(AppAssets.google,)),
                      ],
                    ),
                    // const SizedBox(height: 16),
                    // Center(
                    //   child: Text.rich(
                    //     TextSpan(
                    //       text: AppString.byContinuingText.tr,
                    //       style: AppFonts.verySmallText.copyWith(color: AppTheme.textGrey500),
                    //       children: [
                    //         TextSpan(
                    //           text: AppString.termsOfService.tr,
                    //           style: AppFonts.verySmallText.copyWith(color: const Color(0xFF2C3995,),),
                    //         ),
                    //         TextSpan(text: AppString.and.tr),
                    //         TextSpan(
                    //           text: AppString.privacyPolicy.tr,
                    //           style: AppFonts.verySmallText.copyWith(color: AppTheme.primaryDeepBlue, ),
                    //         ),
                    //       ],
                    //     ),
                    //     textAlign: TextAlign.center,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String asset,) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: AppTheme.blackColor.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, width: 24, height: 24,),
          SizedBox(width: 10,),
          Text(
            asset.contains("apple") ? "Apple" : "Google",
            style: AppFonts.semiBoldText.copyWith(
              color: AppTheme.blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
