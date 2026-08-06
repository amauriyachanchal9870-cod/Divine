import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../Controller/profile_controller.dart';
import '../../Model/coupon_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  final RxString selectedCouponCode = "".obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.fetchCouponsList();
    });
  }

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
      body: Obx(() {
        if (_profileController.isCouponsLoading.value && _profileController.couponsList.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final coupons = _profileController.couponsList;
        if (coupons.isEmpty) {
          return Center(
            child: Text(
              "No coupons available",
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _profileController.fetchCouponsList,
          child: Stack(
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
      }),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final bool isActive = coupon.isActive ?? false;
    final String code = coupon.code ?? '';

    return Obx(() {
      final bool isSelected = selectedCouponCode.value == code;

      // Display OFF text based on coupon type and value
      String offText = AppString.flatOff.tr;
      if (coupon.discountType == 'Flat' && coupon.value != null) {
        offText = "FLAT ₹${coupon.value!.toInt()} OFF";
      } else if (coupon.discountType == 'Percentage' && coupon.value != null) {
        offText = "${coupon.value!.toInt()}% OFF";
      }

      return GestureDetector(
        onTap: () {
          if (isActive) {
            selectedCouponCode.value = code;
          } else {
            showSnackBar("This coupon is expired or inactive.", false);
          }
        },
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppTheme.whiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryDeepBlue
                  : AppTheme.fieldBorderColor.withValues(alpha: 0.8),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.primaryDeepBlue.withValues(alpha: 0.1)
                    : AppTheme.blackColor.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left rotated discount type column
              Container(
                width: 54,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryDeepBlue : AppTheme.textGrey500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    offText.toUpperCase(),
                    style: AppFonts.semiBoldText.copyWith(
                      color: AppTheme.whiteColor,
                      fontSize: 10,
                      letterSpacing: 1.0,
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
                            code,
                            style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coupon.description ?? '',
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
                      // Code / Tap to Copy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: code));
                              showSnackBar(AppString.couponCopiedToClipboard.tr, true);
                            },
                            child: Text(
                              code,
                              style: AppFonts.semiBoldText.copyWith(
                                fontSize: 12,
                                color: AppTheme.primaryDeepBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.primaryDeepBlue, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "Selected",
                                  style: AppFonts.semiBoldText.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.primaryDeepBlue,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
          child: Obx(() {
            final hasSelection = selectedCouponCode.value.isNotEmpty;

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelection ? AppTheme.primaryDeepBlue : AppTheme.textGrey400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: !hasSelection
                  ? null
                  : () async {
                      final success = await _profileController.claimCoupon(context, selectedCouponCode.value);
                      if (success) {
                        selectedCouponCode.value = "";
                      }
                    },
              child: Text(
                AppString.redeemNow.tr,
                style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 16),
              ),
            );
          }),
        ),
      ),
    );
  }
}
