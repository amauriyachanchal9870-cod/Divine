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
  final String? phone;
  final String? otp;
  final bool? isLogin;

  const OTPVerificationScreen({
    super.key,
    this.phone,
    this.otp,
    this.isLogin,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final AuthController authController = Get.put(AuthController());

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  String get effectivePhone => widget.phone ?? Get.arguments?['phone'] ?? "";

  @override
  void initState() {
    super.initState();
    _startTimer();

    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });

      final int index = i;
      focusNodes[index].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controllers[index].text.isEmpty &&
            index > 0) {
          focusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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

  String _getMaskedPhone(String rawPhone) {
    if (rawPhone.isEmpty) return "********78";
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 2) {
      String last2 = digits.substring(digits.length - 2);
      return "********$last2";
    }
    return rawPhone;
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute? currentRoute = ModalRoute.of(context);
    final bool isPageRoute = currentRoute is PageRoute;

    final sheetContent = _buildSheet(context, isPageRoute: isPageRoute);

    // If opened as a page route (via Get.toNamed), wrap in a transparent Scaffold
    // with a dark barrier so it visually behaves identically to a modal bottom sheet.
    if (isPageRoute) {
      return Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back(),
                  child: const SizedBox.expand(),
                ),
              ),
              sheetContent,
            ],
          ),
        ),
      );
    }

    return sheetContent;
  }

  Widget _buildSheet(BuildContext context, {bool isPageRoute = false}) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    String subtitleText = AppString.weSentYouVerificationCode.tr.trim();
    if (subtitleText.contains("your phone number")) {
      subtitleText = subtitleText.replaceFirst("your phone number", "\nyour phone number");
    } else if (subtitleText.contains("on your phone number")) {
      subtitleText = subtitleText.replaceFirst("on your phone number", "on\nyour phone number");
    }

    final Widget sheet = Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: bottomPadding > 0 ? bottomPadding : 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20.0,
            24.0,
            20.0,
            20.0,
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppString.verifyYourIdentity.tr,
                  textAlign: TextAlign.center,
                  style: AppFonts.titleStyle.copyWith(
                    color: AppTheme.blackColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$subtitleText ${_getMaskedPhone(effectivePhone)}",
                  textAlign: TextAlign.center,
                  style: AppFonts.smallText.copyWith(
                    color: AppTheme.textGrey500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _otpField(0),
                    const SizedBox(width: 12),
                    _otpField(1),
                    const SizedBox(width: 12),
                    _otpField(2),
                    const SizedBox(width: 12),
                    _otpField(3),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: '${AppString.didntReceiveOtpResend.tr.split('?')[0]}? ',
                      style: AppFonts.smallText.copyWith(
                        color: AppTheme.textGrey500,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: _canResend
                              ? (AppString.didntReceiveOtpResend.tr.split('?').length > 1
                                  ? AppString.didntReceiveOtpResend.tr.split('?')[1].trim()
                                  : AppString.resend.tr)
                              : AppString.resendInSeconds
                                  .trParams({'seconds': _secondsRemaining.toString()}),
                          style: AppFonts.smallText.copyWith(
                            color: _canResend
                                ? AppTheme.primaryDeepBlue
                                : AppTheme.textGrey500,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _canResend
                                ? () async {
                                    if (effectivePhone.isNotEmpty) {
                                      bool success = await authController.resendOtp(
                                        context,
                                        effectivePhone,
                                      );
                                      if (success) {
                                        for (var controller in controllers) {
                                          controller.clear();
                                        }
                                        focusNodes[0].requestFocus();
                                        _startTimer();
                                      }
                                    } else {
                                      showSnackBar(
                                        AppString.phoneMissingError.tr,
                                        false,
                                      );
                                    }
                                  }
                                : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryDeepBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppString.pleaseDoNotShareCode.tr,
                          style: AppFonts.smallText.copyWith(
                            color: AppTheme.primaryDeepBlue,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                GetBuilder<AuthController>(
                  builder: (controller) {
                    return CustomButton(
                      height: 50,
                      width: double.infinity,
                      title: AppString.verifyCode.tr,
                      showLoader: controller.isLoading,
                      onTap: () {
                        bool isOtpIncomplete = controllers.any(
                          (c) => c.text.trim().isEmpty,
                        );
                        if (isOtpIncomplete) {
                          showSnackBar(AppString.enterCompleteOtpError.tr, false);
                          return;
                        }

                        String otp = controllers.map((c) => c.text).join("");
                        controller.verifyOtp(context, effectivePhone, otp);
                      },
                      color: AppTheme.primaryDeepBlue,
                      borderRadius: BorderRadius.circular(10),
                      showCenter: true,
                    );
                  },
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryDeepBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppString.editPhoneNumber.tr,
                        style: AppFonts.smallText.copyWith(
                          color: AppTheme.primaryDeepBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );

    if (isPageRoute) {
      return AnimatedPadding(
        padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: sheet,
      );
    }

    return sheet;
  }

  Widget _otpField(int index) {
    bool hasFocus = focusNodes[index].hasFocus;
    bool hasValue = controllers[index].text.isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(
          color: (hasFocus || hasValue)
              ? AppTheme.primaryDeepBlue
              : const Color(0xFFD0D5DD),
          width: (hasFocus || hasValue) ? 1.5 : 1.0,
        ),
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
          style: AppFonts.titleStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.blackColor,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            setState(() {});
            if (controllers.every((c) => c.text.trim().isNotEmpty)) {
              for (var node in focusNodes) {
                node.unfocus();
              }
              FocusScope.of(context).unfocus();
            } else if (value.length == 1 && index < 3) {
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
