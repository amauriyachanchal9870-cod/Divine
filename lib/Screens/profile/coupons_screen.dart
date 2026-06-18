import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  // Simple state to track active/inactive coupons
  final List<Map<String, dynamic>> coupons = [
    {
      "code": "BHGG4571GV",
      "title": AppString.carnival.tr,
      "subtitle": AppString.carnivalCouponDesc.tr,
      "isActive": true,
    },
    {
      "code": "BHGG4571GV",
      "title": AppString.carnival.tr,
      "subtitle": AppString.carnivalCouponDesc.tr,
      "isActive": false,
    },
    {
      "code": "BHGG4571GV",
      "title": AppString.carnival.tr,
      "subtitle": AppString.carnivalCouponDesc.tr,
      "isActive": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppString.coupons.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, color: Colors.black87),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: coupons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _buildCouponCard(coupon);
            },
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final bool isActive = coupon['isActive'];

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackColor.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left rotated "FLAT OFF" column
          Container(
            width: 54,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryDeepBlue : AppTheme.textGrey500,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                AppString.flatOff.tr,
                style: AppFonts.semiBoldText.copyWith(
                  color: AppTheme.whiteColor,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          // Right details section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon['title'],
                        style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon['subtitle'],
                        style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // Dotted Divider line
                  Row(
                    children: List.generate(40, (index) {
                      return Expanded(
                        child: Container(
                          height: 1,
                          color: index % 2 == 0 ? AppTheme.greyBg300 : Colors.transparent,
                        ),
                      );
                    }),
                  ),
                  // Code
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: coupon['code']));
                      Get.snackbar(
                        AppString.codeCopied.tr, 
                        AppString.couponCopiedToClipboard.tr,
                        backgroundColor: Colors.black87,
                        colorText: AppTheme.whiteColor,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    child: Text(
                      coupon['code'],
                      style: AppFonts.semiBoldText.copyWith(
                        fontSize: 12,
                        color: AppTheme.primaryDeepBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: AppTheme.whiteColor,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDeepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              Get.snackbar(
                AppString.redeemed.tr, 
                AppString.couponsRedeemedSuccess.tr,
                backgroundColor: AppTheme.greenColor,
                colorText: AppTheme.whiteColor,
              );
            },
            child: Text(
              AppString.redeemNow.tr,
              style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
