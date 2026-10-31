import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Model/dan_subcategories_model.dart';
import '../../Model/dan_items_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/daan_controller.dart';
import '../../Routes/my_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DaanDetailsScreen extends StatefulWidget {
  const DaanDetailsScreen({super.key});

  @override
  State<DaanDetailsScreen> createState() => _DaanDetailsScreenState();
}

class _DaanDetailsScreenState extends State<DaanDetailsScreen> {
  late final DaanController controller;
  late final DanSubCategoryData? subCategory;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DaanController>();
    subCategory = Get.arguments as DanSubCategoryData?;

    // Fetch items for the selected subcategory
    if (subCategory?.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchDaanItems(subCategory!.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle = subCategory?.name ?? "Items";

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
          screenTitle,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: controller.itemsLoading.value
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppTheme.primaryDeepBlue,
                        size: 50,
                      ),
                    )
                  : controller.danItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_basket_outlined, size: 52, color: AppTheme.textGrey400),
                              const SizedBox(height: 12),
                              Text(
                                "No items available.",
                                style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => controller.fetchDaanItems(subCategory?.id ?? ''),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: controller.danItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = controller.danItems[index];
                              return Obx(() {
                                final qty = controller.itemQtyMap[item.id ?? ''] ?? 0;
                                final bool isSelected = qty > 0;
                                return _buildItemCard(
                                  item: item,
                                  qty: qty,
                                  isSelected: isSelected,
                                  onIncrement: () => controller.incrementItem(item.id ?? ''),
                                  onDecrement: () => controller.decrementItem(item.id ?? ''),
                                );
                              });
                            },
                          ),
                        ),
            ),
            _buildBottomBar(controller),
          ],
        );
      }),
    );
  }

  Widget _buildItemCard({
    required DanItemData item,
    required int qty,
    required bool isSelected,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
          width: isSelected ? 1.8 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFF8FAFC),
              alignment: Alignment.center,
              child: (item.imageUrl != null && item.imageUrl!.trim().isNotEmpty)
                  ? Image.network(
                      item.imageUrl!.trim(),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryDeepBlue.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (c, e, s) => Image.asset(
                        AppAssets.appLogo,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    )
                  : Image.asset(
                      AppAssets.appLogo,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.name ?? "",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Description
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Description : ",
                        style: AppFonts.semiBoldText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                      ),
                      TextSpan(
                        text: item.description ?? "",
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Price row + counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price + unit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹ ${item.price?.toInt() ?? 0}",
                          style: AppFonts.semiBoldText.copyWith(
                            fontSize: 16,
                            color: AppTheme.primaryDeepBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.unit ?? "",
                          style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
                        ),
                      ],
                    ),
                    // Qty counter
                    Container(
                      height: 34,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.fieldBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Decrement
                          GestureDetector(
                            onTap: onDecrement,
                            child: Container(
                              width: 34,
                              height: 34,
                              color: const Color(0xFFF5F5F5),
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove, size: 15, color: Colors.black54),
                            ),
                          ),
                          // Qty value
                          Container(
                            width: 38,
                            alignment: Alignment.center,
                            child: Text(
                              "$qty",
                              style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Increment
                          GestureDetector(
                            onTap: onIncrement,
                            child: Container(
                              width: 34,
                              height: 34,
                              color: AppTheme.primaryDeepBlue,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add, size: 15, color: Colors.white),
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
            // Back button
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
                  child: const Text(
                    "Back",
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Proceed button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: Obx(() {
                  final total = controller.itemsTotal;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (total > 0) {
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
                              Container(height: 20, width: 1, color: Colors.white30),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Total",
                                    style: TextStyle(color: Colors.white70, fontSize: 9),
                                  ),
                                  Text(
                                    "₹ $total",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
