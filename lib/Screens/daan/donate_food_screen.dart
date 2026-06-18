import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/daan_controller.dart';
import '../../Routes/my_routes.dart';

class DonateFoodScreen extends StatelessWidget {
  const DonateFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DaanController controller = Get.find<DaanController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Donate Food",
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildFoodItemCard(
                    title: "Saints & Brahmins Seva",
                    subtitle: "Supports those who dedicate their lives to dharma and spiritual guidance through this.",
                    imagePath: 'assets/images/campaign_image.png',
                    itemCount: controller.saintsBrahminsItemCount,
                    totalPrice: controller.saintsBrahminsTotal,
                    onTapButton: () => Get.toNamed(MyRouters.daanDetailsScreen),
                  ),
                  const SizedBox(height: 16),
                  _buildFoodItemCard(
                    title: "Dry Rations",
                    subtitle: "Supports those who dedicate their lives to dharma and spiritual guidance. Through this",
                    imagePath: 'assets/images/campaign_image.png',
                    itemCount: controller.dryRationsItemCount,
                    totalPrice: controller.dryRationsTotal,
                    onTapButton: () {
                      if (controller.dryRationsQty.value == 0) {
                        controller.dryRationsQty.value = 1;
                      } else {
                        controller.dryRationsQty.value = 0;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFoodItemCard(
                    title: "Support Needy Children",
                    subtitle: "Supports those who dedicate their lives to dharma and spiritual guidance. Through this",
                    imagePath: 'assets/images/campaign_image.png',
                    itemCount: 0,
                    totalPrice: 0,
                    onTapButton: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildFoodItemCard(
                    title: "Support Disabled People",
                    subtitle: "Supports those who dedicate their lives to dharma and spiritual guidance. Through this",
                    imagePath: 'assets/images/campaign_image.png',
                    itemCount: 0,
                    totalPrice: 0,
                    onTapButton: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildFoodItemCard(
                    title: "Support Needy Family",
                    subtitle: "Supports those who dedicate their lives to dharma and spiritual guidance. Through this",
                    imagePath: 'assets/images/campaign_image.png',
                    itemCount: 0,
                    totalPrice: 0,
                    onTapButton: () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _buildBottomBar(controller),
          ],
        );
      }),
    );
  }

  Widget _buildFoodItemCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required int itemCount,
    required int totalPrice,
    required VoidCallback onTapButton,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: itemCount > 0
                ? GestureDetector(
                    onTap: onTapButton,
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryDeepBlue, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$itemCount Items",
                            style: AppFonts.semiBoldText.copyWith(
                              fontSize: 12.0,
                              color: AppTheme.primaryDeepBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              "|",
                              style: TextStyle(
                                color: AppTheme.primaryDeepBlue.withValues(alpha: 0.4),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          Text(
                            "₹ $totalPrice",
                            style: AppFonts.semiBoldText.copyWith(
                              fontSize: 12.0,
                              color: AppTheme.primaryDeepBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_outlined, size: 14, color: AppTheme.primaryDeepBlue),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.addItemsBg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onTapButton,
                      child: Text(
                        "Add Items",
                        style: TextStyle(
                          color: AppTheme.primaryDeepBlue,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DaanController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.backButtonBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Back",
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (controller.totalAmount > 0) {
                      Get.toNamed(MyRouters.chooseImpactScreen);
                    } else {
                      Get.snackbar(
                        "Empty Cart",
                        "Please add at least one item to proceed.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Proceed",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(color: Colors.white70, fontSize: 9),
                              ),
                              Text(
                                "₹ ${controller.totalAmount}",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
