import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class ChooseDaanTypeScreen extends StatelessWidget {
  const ChooseDaanTypeScreen({super.key});

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
          AppString.chooseDaanType.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildSlidingBanner(),
            const SizedBox(height: 20),
            _buildDaanGrid(),
            const SizedBox(height: 24),
            _buildSlidingBanner(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            AppString.search.tr,
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingBanner() {
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
                  AppString.everyContributionCreatesImpact.tr,
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
          Image.asset(
            'assets/images/donateAndFund.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const SizedBox(width: 70, height: 70),
          ),
        ],
      ),
    );
  }

  Widget _buildDaanGrid() {
    final items = [
      {
        'title': AppString.foodLabel.tr,
        'subtitle': 'Food for the needy',
        'image': 'assets/icons/danFoodIcon.png',
        'route': MyRouters.donateFoodScreen,
      },
      {
        'title': AppString.clothesLabel.tr,
        'subtitle': 'Clothes donation',
        'image': 'assets/icons/danClothesIcon.png',
        'route': MyRouters.donateFoodScreen,
      },
      {
        'title': AppString.gauDaanLabel.tr,
        'subtitle': 'Gau seva',
        'image': 'assets/icons/danGauIcon.png',
        'route': MyRouters.donateFoodScreen,
      },
      {
        'title': AppString.ngoWelfareLabel.tr,
        'subtitle': 'Support NGOs',
        'image': 'assets/icons/danNgoIcon.png',
        'route': MyRouters.donateFoodScreen,
      },
      {
        'title': AppString.booksLabel.tr,
        'subtitle': 'Foundation support',
        'image': 'assets/icons/danBooksIcon.png',
        'route': MyRouters.donateFoodScreen,
      },
      {
        'title': AppString.templeLabel.tr,
        'subtitle': 'Temple donation',
        'image': 'assets/icons/danTempleIcon.png',
        'route': MyRouters.donateFoodScreen,
      },
    ];

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
          return GestureDetector(
            onTap: () => Get.toNamed(item['route'] as String),
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
                      child: Image.asset(
                        item['image'] as String,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
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
                            onPressed: () => Get.toNamed(item['route'] as String),
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
