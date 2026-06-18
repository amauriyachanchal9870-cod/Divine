import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class FundraisersScreen extends StatelessWidget {
  const FundraisersScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildCategories(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildCampaignCard();
              },
            ),
          ),
        ],
      ),
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

  Widget _buildCampaignCard() {
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
              child: Image.asset(
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
                  Text("Rural education Initiative", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Providing supplies for 50 students", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹ 54,000 raised", style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen)),
                      Text("of 75k", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 54000 / 75000,
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
                      Text("1.3K Donors", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                      const SizedBox(width: 16),
                      const Icon(Icons.timelapse_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("12 days left", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("Oct Now", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
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
                        Get.toNamed(MyRouters.campaignDetailsScreen);
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
