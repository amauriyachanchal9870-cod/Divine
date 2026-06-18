import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/daan_controller.dart';
import '../../Routes/my_routes.dart';

class ChooseImpactScreen extends StatelessWidget {
  const ChooseImpactScreen({super.key});

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
          "Choose Your Impact",
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How often would you like to contribute to making a difference? Consistent support fuels sustainable change.",
                      style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500),
                    ),
                    const SizedBox(height: 28),
                    _buildOptionCard(
                      title: "One Time Donation",
                      description: "A simple gift to provide immediate relief and meet urgent needs today.",
                      isSelected: controller.impactType.value == 'one_time',
                      badgeText: "Instant relief post",
                      badgeIcon: Icons.bolt,
                      badgeColor: Colors.blue.shade50,
                      badgeTextColor: Colors.blue.shade700,
                      onTap: () => controller.impactType.value = 'one_time',
                    ),
                    const SizedBox(height: 24),
                    _buildOptionCard(
                      title: "Monthly Subscription",
                      description: "This regular support helps provide long-term stability and sustainable impact.",
                      isSelected: controller.impactType.value == 'monthly',
                      badgeText: "2x Higher long term impact",
                      badgeIcon: Icons.trending_up,
                      badgeColor: Colors.green.shade50,
                      badgeTextColor: Colors.green.shade700,
                      isRecommended: true,
                      onTap: () => controller.impactType.value = 'monthly',
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(controller),
          ],
        );
      }),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required bool isSelected,
    required String badgeText,
    required IconData badgeIcon,
    required Color badgeColor,
    required Color badgeTextColor,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryDeepBlue.withValues(alpha: 0.05) : Colors.white,
              border: Border.all(
                color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended) const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppFonts.semiBoldText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryDeepBlue : Colors.black,
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppTheme.primaryDeepBlue : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12, color: badgeTextColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -10,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Recommended",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDeepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Get.toNamed(MyRouters.reviewPayScreen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Proceed to payment",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
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
      ),
    );
  }
}
