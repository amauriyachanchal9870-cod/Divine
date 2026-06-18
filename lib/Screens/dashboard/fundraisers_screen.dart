import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/home_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class FundraisersScreen extends StatelessWidget {
  const FundraisersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

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
          AppString.fundraisers.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final campaigns = homeController.campaigns;

        if (campaigns.isEmpty) {
          return Center(
            child: Text(
              "No fundraisers found",
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildCategories(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: campaigns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final campaign = campaigns[index];
                  return _buildCampaignCard(campaign);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(
            AppString.searchForCampaigns.tr,
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': AppString.all.tr, 'icon': Icons.grid_view, 'selected': true},
      {'name': AppString.medical.tr, 'icon': Icons.medical_services_outlined, 'selected': false},
      {'name': AppString.education.tr, 'icon': 'assets/icons/booksIcon.png', 'selected': false},
      {'name': AppString.emergency.tr, 'icon': Icons.warning_amber_rounded, 'selected': false},
      {'name': AppString.animalWelfare.tr, 'icon': 'assets/icons/gauIcon.png', 'selected': false},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = categories[index]['selected'] as bool;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryDeepBlue : Colors.white,
              border: isSelected ? Border.all(color: AppTheme.primaryDeepBlue) : Border.all(color: AppTheme.fieldBorderColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                categories[index]['icon'] is IconData
                    ? Icon(
                        categories[index]['icon'] as IconData,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.black54,
                      )
                    : Image.asset(
                        categories[index]['icon'] as String,
                        width: 14,
                        height: 14,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.category,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                const SizedBox(width: 6),
                Text(
                  categories[index]['name'] as String,
                  style: AppFonts.semiBoldText.copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCampaignCard(HomeCampaign c) {
    return GestureDetector(
      onTap: () => Get.toNamed(MyRouters.campaignDetailsScreen),
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
                      placeholder: (ctx, url) => Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (ctx, url, err) => Image.asset(
                        'assets/images/campaign_image.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/campaign_image.png',
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
                      Text("₹ ${c.raised} raised", style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen)),
                      Text("of ${c.goal}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
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
                        Get.toNamed(MyRouters.donateAmountScreen);
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
