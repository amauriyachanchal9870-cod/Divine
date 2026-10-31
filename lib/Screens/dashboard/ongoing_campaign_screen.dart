import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Controller/active_campaigns_controller.dart';
import '../../Controller/banner_controller.dart';
import '../../Widget/banner_slider_widget.dart';
import '../../Model/campaign_details_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_assets.dart';
import '../../Routes/my_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OngoingCampaignScreen extends StatelessWidget {
  const OngoingCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActiveCampaignsController activeCampaignsController = Get.put(ActiveCampaignsController());
    final BannerController bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController());

    bannerController.fetchBanners('campaign_list');

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
          AppString.ongoingCampaigns.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (activeCampaignsController.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        final campaigns = activeCampaignsController.filteredCampaigns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(activeCampaignsController),
            Obx(() {
              final topBanners = bannerController.getTopBanners('campaign_list');
              if (topBanners.isNotEmpty) {
                return BannerSliderWidget(
                  banners: topBanners,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                );
              }
              return const SizedBox.shrink();
            }),
            _buildCategories(activeCampaignsController),
            const SizedBox(height: 16),
            Expanded(
              child: campaigns.isEmpty
                  ? Center(
                      child: Text(
                        "No ongoing campaigns found",
                        style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: campaigns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final campaign = campaigns[index];
                        return _buildCampaignCard(campaign);
                      },
                    ),
            ),
            Obx(() {
              final bottomBanners = bannerController.getBottomBanners('campaign_list');
              if (bottomBanners.isNotEmpty) {
                return BannerSliderWidget(
                  banners: bottomBanners,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(ActiveCampaignsController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) {
                controller.searchQuery.value = val;
              },
              decoration: InputDecoration(
                hintText: AppString.searchForCampaigns.tr,
                hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(ActiveCampaignsController controller) {
    return Obx(() {
      final dynamicList = controller.categoriesList;

      final categories = [
        {'key': 'All', 'name': AppString.all.tr, 'icon': Icons.grid_view},
        ...dynamicList.map((cat) {
          final name = cat.name ?? '';
          final iconStr = cat.icon ?? '';
          final imgStr = cat.imageUrl ?? '';

          dynamic iconVal;
          if (iconStr.startsWith('http://') || iconStr.startsWith('https://')) {
            iconVal = iconStr;
          } else if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
            iconVal = imgStr;
          } else {
            final nameLower = name.toLowerCase();
            final iconLower = iconStr.toLowerCase();
            final idLower = (cat.categoryId ?? '').toLowerCase();

            if (iconLower == 'book-open' || nameLower.contains('book') || idLower.contains('book')) {
              iconVal = AppAssets.books;
            } else if (iconLower == 'utensils' || nameLower.contains('food') || idLower.contains('food')) {
              iconVal = AppAssets.food;
            } else if (iconLower == 'heart' || nameLower.contains('gau') || nameLower.contains('cow') || idLower.contains('cow') || idLower.contains('gau')) {
              iconVal = AppAssets.gau;
            } else if (iconLower == 'church' || nameLower.contains('temple') || idLower.contains('temp')) {
              iconVal = AppAssets.temple;
            } else if (nameLower.contains('cloth') || idLower.contains('cloth')) {
              iconVal = AppAssets.clothes;
            } else if (iconStr.isNotEmpty) {
              iconVal = iconStr;
            } else {
              iconVal = Icons.category;
            }
          }

          return {
            'key': name,
            'name': name,
            'icon': iconVal,
          };
        }),
      ];

      return SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final catKey = categories[index]['key'] as String;
            final catName = categories[index]['name'] as String;
            final iconData = categories[index]['icon'];
            final isSelected = controller.selectedCategory.value.toLowerCase() == catKey.toLowerCase();

            return GestureDetector(
              onTap: () {
                controller.selectedCategory.value = catKey;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryDeepBlue : Colors.white,
                  border: isSelected 
                      ? Border.all(color: AppTheme.primaryDeepBlue) 
                      : Border.all(color: AppTheme.fieldBorderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (iconData is IconData)
                      Icon(
                        iconData,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.orange,
                      )
                    else if (iconData is String && (iconData.startsWith('http://') || iconData.startsWith('https://')))
                      CachedNetworkImage(
                        imageUrl: iconData,
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                        errorWidget: (c, e, s) => Icon(
                          Icons.category,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.orange,
                        ),
                      )
                    else if (iconData is String && iconData.isNotEmpty)
                      Image.asset(
                        iconData,
                        width: 14,
                        height: 14,
                        errorBuilder: (c, e, s) => Icon(
                          Icons.category,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.orange,
                        ),
                      )
                    else
                      Icon(
                        Icons.category,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.orange,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      catName,
                      style: AppFonts.semiBoldText.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCampaignCard(CampaignDetailsData c) {
    return GestureDetector(
      onTap: () => Get.toNamed(MyRouters.campaignDetailsScreen, arguments: c.sId),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.fieldBorderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: c.imageUrl != null && c.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: c.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => const ShimmerWidget(height: 160, width: double.infinity),
                      errorWidget: (ctx, url, err) => Image.asset(
                        AppAssets.appLogo,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      AppAssets.appLogo,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    c.description ?? '',
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹ ${c.formattedRaised} raised", style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen)),
                      Text("of ${c.formattedGoal}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: c.progress,
                    backgroundColor: AppTheme.fieldBorderColor,
                    color: AppTheme.progressGreen,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${c.formattedDonors} Donors", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${c.daysLeft} days left", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDeepBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.toNamed(MyRouters.donateAmountScreen, arguments: c);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
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
  }
}
