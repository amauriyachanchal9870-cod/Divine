import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Model/dan_categories_model.dart';
import '../../Model/dan_subcategories_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/daan_controller.dart';
import '../../Routes/my_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DonateFoodScreen extends StatefulWidget {
  const DonateFoodScreen({super.key});

  @override
  State<DonateFoodScreen> createState() => _DonateFoodScreenState();
}

class _DonateFoodScreenState extends State<DonateFoodScreen> {
  late final DaanController controller;
  late final DanCategoryData? category;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DaanController>();
    category = Get.arguments as DanCategoryData?;

    // Fetch subcategories using the category's MongoDB _id
    if (category?.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchDaanSubCategories(category!.id!);
      });
    }
  }

  String getFallbackAsset(String? subcategoryId) {
    switch (subcategoryId) {
      case 'SUB-SAINTS':
        return AppAssets.campaignImage;
      case 'SUB-DRY-RATION':
        return AppAssets.campaignImage;
      case 'SUB-CHILDREN':
        return AppAssets.campaignImage;
      default:
        return AppAssets.campaignImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle = category?.name ?? "Donate";

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
              child: controller.subCategoryLoading.value
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppTheme.primaryDeepBlue,
                        size: 50,
                      ),
                    )
                  : controller.subCategories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textGrey400),
                              const SizedBox(height: 12),
                              Text(
                                "No subcategories available.",
                                style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => controller.fetchDaanSubCategories(category?.id ?? ''),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: controller.subCategories.length,
                            itemBuilder: (context, index) {
                              final sub = controller.subCategories[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildSubCategoryCard(sub),
                              );
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

  Widget _buildSubCategoryCard(DanSubCategoryData sub) {
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
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: sub.imageUrl != null
                      ? Image.network(
                          sub.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Image.asset(
                            getFallbackAsset(sub.subcategoryId),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          getFallbackAsset(sub.subcategoryId),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                // Title + description + NGO badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.name ?? "",
                        style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub.description ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500, height: 1.3),
                      ),
                      if (sub.ngoId != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.account_balance_outlined, size: 11, color: Colors.blue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sub.ngoId!.name ?? "",
                                style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.addItemsBg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Get.toNamed(MyRouters.daanDetailsScreen, arguments: sub),
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
                    if (controller.itemsTotal > 0) {
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
                          Container(height: 20, width: 1, color: Colors.white30),
                          const SizedBox(width: 12),
                          Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(color: Colors.white70, fontSize: 9),
                              ),
                              Text(
                                "₹ ${controller.itemsTotal}",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
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
