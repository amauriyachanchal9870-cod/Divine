import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/daan_controller.dart';
import '../../Routes/my_routes.dart';


class DaanDetailsScreen extends StatelessWidget {
  const DaanDetailsScreen({super.key});

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
          "Saints & Brahmins Seva",
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
                  _buildDetailItem(
                    title: "Ration Kit For Needy Family - 30days",
                    description: "Description - The Ration kit for needy family is designed to provide nutritious food and basic...",
                    price: controller.rationKitPrice,
                    qty: controller.rationKitQty.value,
                    imagePath: 'assets/images/campaign_image.png',
                    onIncrement: () => controller.rationKitQty.value++,
                    onDecrement: () {
                      if (controller.rationKitQty.value > 0) {
                        controller.rationKitQty.value--;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    title: "Feed Brahmins And Saints",
                    description: "Description - Different varieties of healthy cooked food are offered to poor/needy, poor, vidva, etc.",
                    price: controller.feedBrahminsPrice,
                    qty: controller.feedBrahminsQty.value,
                    imagePath: 'assets/images/campaign_image.png',
                    onIncrement: () => controller.feedBrahminsQty.value++,
                    onDecrement: () {
                      if (controller.feedBrahminsQty.value > 0) {
                        controller.feedBrahminsQty.value--;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    title: "Ration Kit For Needy Family - 30days",
                    description: "Description - The Ration kit for needy family is designed to provide nutritious food and basic...",
                    price: controller.rationKitPrice,
                    qty: controller.rationKitQty.value,
                    imagePath: 'assets/images/campaign_image.png',
                    onIncrement: () => controller.rationKitQty.value++,
                    onDecrement: () {
                      if (controller.rationKitQty.value > 0) {
                        controller.rationKitQty.value--;
                      }
                    },
                    isDuplicateDemo: true,
                  ),
                ],
              ),
            ),
            _buildBottomBar(controller),
          ],
        );
      }),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String description,
    required int price,
    required int qty,
    required String imagePath,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    bool isDuplicateDemo = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹ $price",
                          style: AppFonts.semiBoldText.copyWith(
                            fontSize: 16,
                            color: AppTheme.primaryDeepBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "1 Ration Kit",
                          style: AppFonts.regularText.copyWith(
                            fontSize: 10,
                            color: AppTheme.textGrey500,
                          ),
                        ),
                      ],
                    ),
                    // Quantity counter selector
                    Container(
                      height: 32,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.fieldBorderColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: onDecrement,
                            child: Container(
                              width: 32,
                              height: 32,
                              color: const Color(0xFFF5F5F5),
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove, size: 14, color: Colors.black54),
                            ),
                          ),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              isDuplicateDemo ? "0" : "$qty",
                              style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: onIncrement,
                            child: Container(
                              width: 32,
                              height: 32,
                              color: AppTheme.primaryDeepBlue,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
                    backgroundColor: const Color(0xFFF5F5F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("Back", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Proceed",
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
          ],
        ),
      ),
    );
  }
}
