import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/helper.dart';
import '../../Controller/auth_controller.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final AuthController authController = Get.put(AuthController());

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppString.verifyYourIdentity.tr,
                style: AppFonts.titleStyle.copyWith(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: AppString.weSentYouVerificationCode.tr,
                  style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
                  children: [
                    TextSpan(
                      text: Get.arguments?['phone'] ?? "+91 ********74",
                      style: AppFonts.smallText.copyWith(color: AppTheme.blackColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => _otpField(index)),
              ),
              const SizedBox(height: 60),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: '${AppString.didntReceiveOtpResend.tr.split('?')[0]}? ',
                    style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
                    children: [
                      TextSpan(
                        text: _canResend
                            ? (AppString.didntReceiveOtpResend.tr.split('?').length > 1
                                ? AppString.didntReceiveOtpResend.tr.split('?')[1].trim()
                                : 'Resend')
                            : 'Resend in ${_secondsRemaining}s',
                        style: AppFonts.smallText.copyWith(
                          color: _canResend ? AppTheme.primaryDeepBlue : AppTheme.textGrey500,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _canResend
                              ? () async {
                                  String phone = Get.arguments?['phone'] ?? "";
                                  if (phone.isNotEmpty) {
                                    bool success = await authController.resendOtp(context, phone);
                                    if (success) {
                                      for (var controller in controllers) {
                                        controller.clear();
                                      }
                                      focusNodes[0].requestFocus();
                                      _startTimer();
                                    }
                                  } else {
                                    showSnackBar("Phone number is missing", false);
                                  }
                                }
                              : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                        AppString.pleaseDoNotShareCode.tr,
                        style: AppFonts.smallText.copyWith(
                          color: AppTheme.primaryDeepBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                height: 50,
                width: double.infinity,
                title: AppString.verifyCode.tr,
                onTap: () {
                  bool isOtpIncomplete = controllers.any((controller) => controller.text.trim().isEmpty);
                  if (isOtpIncomplete) {
                    showSnackBar("Please enter the complete OTP", false);
                    return;
                  }
                  
                  String phone = Get.arguments?['phone'] ?? "";
                  String otp = controllers.map((c) => c.text).join("");
                  
                  authController.verifyOtp(context, phone, otp);
                },
                color: AppTheme.primaryDeepBlue,
                borderRadius: BorderRadius.circular(10),
                showCenter: true,
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: AppTheme.primaryDeepBlue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        AppString.editPhoneNumber.tr,
                        style: AppFonts.smallText.copyWith(
                          color: AppTheme.primaryDeepBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpField(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: AppFonts.titleStyle.copyWith(fontSize: 20),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.length == 1 && index < 3) {
              focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
