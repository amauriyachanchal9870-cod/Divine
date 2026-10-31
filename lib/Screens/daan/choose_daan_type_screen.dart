import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/daan_controller.dart';
import '../../Controller/banner_controller.dart';
import '../../Widget/banner_slider_widget.dart';
import '../../Model/dan_categories_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChooseDaanTypeScreen extends StatelessWidget {
  const ChooseDaanTypeScreen({super.key});

  String getCategoryFallbackAsset(String? categoryId) {
    switch (categoryId) {
      case 'CAT-FOOD':
        return AppAssets.appLogo;
      case 'CAT-CLOTHES':
        return AppAssets.appLogo;
      case 'CAT-GAU':
        return AppAssets.appLogo;
      case 'CAT-NGO':
        return AppAssets.appLogo;
      case 'CAT-BOOKS':
        return AppAssets.danBooks;
      case 'CAT-TEMPLE':
        return AppAssets.appLogo;
      default:
        return AppAssets.appLogo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DaanController controller = Get.put(DaanController());
    final BannerController bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController());

    bannerController.fetchBanners('daan_category');

    // Reset search query when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
    });

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
          AppString.chooseDaanType.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final topBanner = controller.topBanners.isNotEmpty ? controller.topBanners.first : null;
        final bottomBanner = controller.bottomBanners.isNotEmpty ? controller.bottomBanners.first : null;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchDaanCategories();
            await bannerController.fetchBanners('daan_category', forceRefresh: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildSearchBar(controller),
                Obx(() {
                  final topBanners = bannerController.getTopBanners('daan_category');
                  if (topBanners.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: BannerSliderWidget(banners: topBanners),
                    );
                  }
                  if (topBanner != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: _buildSlidingBanner(topBanner, AppString.everyContributionCreatesImpact.tr),
                    );
                  }
                  return const SizedBox(height: 16);
                }),
                _buildDaanGrid(controller),
                Obx(() {
                  final bottomBanners = bannerController.getBottomBanners('daan_category');
                  if (bottomBanners.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: BannerSliderWidget(banners: bottomBanners),
                    );
                  }
                  if (bottomBanner != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _buildSlidingBanner(bottomBanner, "Every Act of Giving Creates a Ripple of Hope"),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar(DaanController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        onChanged: (val) {
          controller.searchQuery.value = val;
        },
        decoration: InputDecoration(
          hintText: AppString.search.tr,
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSlidingBanner(DanBannerItem? banner, String defaultTitle) {
    if (banner == null) return const SizedBox.shrink();
    final String title = banner.title ?? defaultTitle;
    final String? imageUrl = banner.imageUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bannerBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.titleStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bannerButtonGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppString.startDonating.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      AppString.tcApply.tr,
                      style: AppFonts.regularText.copyWith(fontSize: 8, color: AppTheme.textGrey500),
                    ),
                    const SizedBox(width: 32),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.asset(
                      AppAssets.appLogo,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    AppAssets.appLogo,
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaanGrid(DaanController controller) {
    final items = controller.filteredCategories;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            "No categories found.",
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final String fallbackAsset = getCategoryFallbackAsset(item.categoryId);

          return GestureDetector(
            onTap: () => Get.toNamed(MyRouters.donateFoodScreen, arguments: item),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.fieldBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFFF8FAFC),
                        alignment: Alignment.center,
                        child: (item.imageUrl != null && item.imageUrl!.trim().isNotEmpty)
                            ? Image.network(
                                item.imageUrl!.trim(),
                                width: double.infinity,
                                height: double.infinity,
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
                                  fallbackAsset,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                ),
                              )
                            : Image.asset(
                                fallbackAsset,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? "",
                          style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description ?? "",
                          style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.bannerButtonGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            onPressed: () => Get.toNamed(MyRouters.donateFoodScreen, arguments: item),
                            child: Text(
                              AppString.donateNow.tr,
                              style: TextStyle(color: AppTheme.bannerButtonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
