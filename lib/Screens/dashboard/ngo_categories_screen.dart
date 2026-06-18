import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class NgoCategoriesScreen extends StatelessWidget {
  const NgoCategoriesScreen({super.key});

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
          AppString.ngos.tr,
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
            _buildCategoriesGrid(),
            const SizedBox(height: 24),
            _buildSlidingBanner(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Get.toNamed(MyRouters.ngosGridScreen),
      child: Container(
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
              AppString.searchForNgos.tr,
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
            ),
          ],
        ),
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
                GestureDetector(
                  onTap: () => Get.toNamed(MyRouters.ngosGridScreen),
                  child: Container(
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

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'title': AppString.womenAndGirls.tr,
        'image': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        'fallbackIcon': 'assets/icons/profileIcon.png',
      },
      {
        'title': AppString.childrenCategory.tr,
        'image': 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=400&q=80',
        'fallbackIcon': 'assets/icons/danBooksIcon.png',
      },
      {
        'title': AppString.animal.tr,
        'image': 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?auto=format&fit=crop&w=400&q=80',
        'fallbackIcon': 'assets/icons/gauIcon.png',
      },
      {
        'title': AppString.medicalCategory.tr,
        'image': 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&w=400&q=80',
        'fallbackIcon': 'assets/icons/thankYouIcon.png',
      },
      {
        'title': AppString.educationCategory.tr,
        'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=400&q=80',
        'fallbackIcon': 'assets/icons/booksIcon.png',
      },
      {
        'title': AppString.disabledCategory.tr,
        'image': 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=400&q=80',
        'fallbackIcon': 'assets/icons/helpSupportIcon.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Get.toNamed(MyRouters.ngosGridScreen, arguments: {'category': cat['title']}),
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
                      child: CachedNetworkImage(
                        imageUrl: cat['image'] as String,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.greyBg300,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryDeepBlue,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.bannerBgColor,
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            cat['fallbackIcon'] as String,
                            fit: BoxFit.contain,
                          ),
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
                          cat['title'] as String,
                          style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
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
                            onPressed: () => Get.toNamed(MyRouters.ngosGridScreen, arguments: {'category': cat['title']}),
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
