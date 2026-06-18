import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/home_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: const Color(0xFFEDF3F8),
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty && controller.homeData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(controller.errorMessage.value, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchHomeData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildCategories(),
                _buildActionButtons(context),
                _buildBannerSlider(context, controller.banners),
                _buildOngoingCampaigns(controller.campaigns),
                _buildTopNGOs(controller.ngos),
                _buildDonationHistory(controller.donationHistory),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar(HomeController controller) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Obx(() {
        final name = controller.user?.name ?? 'User';
        return Text(
          'Hello $name !',
          style: AppFonts.titleStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }),
      actions: [
        Obx(() {
          final balance = controller.user?.walletBalance ?? 0;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Image.asset('assets/icons/homeWalletIcon.png', width: 14, height: 14,),
                  const SizedBox(width: 6),
                  Text('₹ $balance', style: AppFonts.semiBoldText.copyWith(color: Colors.black, fontSize: 14)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Get.toNamed(MyRouters.notificationScreen),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 22),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Get.toNamed(MyRouters.searchScreen),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
            Text(AppString.searchForCampaigns.tr, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': AppString.all.tr, 'icon': Icons.grid_view, 'selected': true},
      {'name': AppString.temple.tr, 'icon': 'assets/icons/templeIcon.png', 'selected': false},
      {'name': AppString.books.tr, 'icon': 'assets/icons/booksIcon.png', 'selected': false},
      {'name': AppString.food.tr, 'icon': 'assets/icons/foodIcon.png', 'selected': false},
      {'name': AppString.gauSeva.tr, 'icon': 'assets/icons/gauIcon.png', 'selected': false},
      {'name': AppString.clothes.tr, 'icon': 'assets/icons/clothesIcon.png', 'selected': false},
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
              color: isSelected ? AppTheme.genderSelectColor : Colors.white,
              border: isSelected ? Border.all(color: AppTheme.primaryDeepBlue) : Border.all(color: AppTheme.fieldBorderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                categories[index]['icon'] is IconData
                    ? Icon(categories[index]['icon'] as IconData, size: 14, color: isSelected ? AppTheme.primaryDeepBlue : Colors.orange)
                    : Image.asset(
                        categories[index]['icon'] as String,
                        width: 14,
                        height: 14,
                        errorBuilder: (c, e, s) => Icon(Icons.category, size: 14, color: isSelected ? AppTheme.primaryDeepBlue : Colors.orange),
                      ),
                const SizedBox(width: 6),
                Text(
                  categories[index]['name'] as String,
                  style: AppFonts.semiBoldText.copyWith(color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.findAncestorStateOfType<MainNavigationScreenState>()?.changeTab(1),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.donateGradientStart, AppTheme.donateGradientEnd]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Padding(padding: const EdgeInsets.all(6.0), child: Image.asset('assets/icons/donateHomeIcon.png', fit: BoxFit.contain)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Text(AppString.donate.tr, style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(MyRouters.raiseCampaignWizardScreen),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.raiseGradientStart, AppTheme.raiseGradientEnd]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Padding(padding: const EdgeInsets.all(6.0), child: Image.asset('assets/icons/raiseHomeIcon.png', fit: BoxFit.contain)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Text(AppString.raise.tr, style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(BuildContext context, List<HomeBanner> banners) {
    if (banners.isEmpty) {
      return _buildStaticBanner(context);
    }
    return _BannerSlider(banners: banners, context: context);
  }

  Widget _buildStaticBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(color: AppTheme.bannerBgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppString.everyContributionCreatesImpact.tr, style: AppFonts.semiBoldText.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.findAncestorStateOfType<MainNavigationScreenState>()?.changeTab(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.bannerButtonGreen, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppString.startDonating.tr, style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 11)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 5, child: Image.asset('assets/images/donateAndFund.png', height: 100, fit: BoxFit.contain)),
        ],
      ),
    );
  }

  Widget _buildOngoingCampaigns(List<HomeCampaign> campaigns) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppString.ongoingCampaigns.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              GestureDetector(
                onTap: () => Get.toNamed(MyRouters.fundraisersScreen),
                child: Text(AppString.seeAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (campaigns.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No campaigns available')))
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: campaigns.length > 3 ? 3 : campaigns.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final c = campaigns[index];
                return GestureDetector(
                  onTap: () => Get.toNamed(MyRouters.campaignDetailsScreen),
                  child: Container(
                    width: 260,
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
                              ? CachedNetworkImage(imageUrl: c.imageUrl!, height: 120, width: double.infinity, fit: BoxFit.cover,
                                  placeholder: (ctx, url) => Container(height: 120, color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                                  errorWidget: (ctx, url, err) => Image.asset('assets/images/campaign_image.png', height: 120, width: double.infinity, fit: BoxFit.cover))
                              : Image.asset('assets/images/campaign_image.png', height: 120, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(c.user ?? '', style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹ ${c.raised} raised', style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen)),
                                  Text('of ${c.goal}', style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
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
                                  Text('${c.formattedDonors} Donors', style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                                  const Spacer(),
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${c.daysLeft} days left', style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDeepBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                                  onPressed: () => Get.toNamed(MyRouters.donateAmountScreen),
                                  child: Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
          ),
      ],
    );
  }

  Widget _buildTopNGOs(List<HomeNgo> ngos) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppString.topNGOs.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              GestureDetector(onTap: () => Get.toNamed(MyRouters.ngosScreen), child: Text(AppString.seeAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (ngos.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No NGOs available')))
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ngos.length > 3 ? 3 : ngos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final ngo = ngos[index];
                return GestureDetector(
                  onTap: () => Get.toNamed(MyRouters.ngoDetailsScreen),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.fieldBorderColor), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade200,
                              child: ngo.logo != null && ngo.logo!.isNotEmpty
                                  ? ClipOval(child: CachedNetworkImage(imageUrl: ngo.logo!, width: 60, height: 60, fit: BoxFit.cover, errorWidget: (c, u, e) => Image.asset('assets/images/ngo_logo.png', fit: BoxFit.cover)))
                                  : ClipOval(child: Image.asset('assets/images/ngo_logo.png', fit: BoxFit.cover)),
                            ),
                            Positioned(
                              bottom: -6, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.progressGreen, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.white, size: 10),
                                      const SizedBox(width: 2),
                                      Text('${ngo.rating ?? 4.5}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(ngo.name ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (ngo.impactStats != null && ngo.impactStats!.isNotEmpty)
                          Text(ngo.impactStats!, style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryDeepBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: EdgeInsets.zero),
                            onPressed: () {},
                            child: Text(AppString.follow.tr, style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDonationHistory(List<HomeDonationHistory> history) {
    if (history.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppString.donationHistory.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              GestureDetector(
                onTap: () => Get.toNamed(MyRouters.donationHistoryScreen),
                child: Text(AppString.seeAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: history.length > 3 ? 3 : history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final txn = history[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.fieldBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDeepBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (txn.item?.isNotEmpty == true ? txn.item![0] : '?').toUpperCase(),
                        style: TextStyle(color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(txn.item ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: txn.status == 'Success' ? AppTheme.progressGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                txn.status ?? '',
                                style: AppFonts.regularText.copyWith(
                                  fontSize: 10,
                                  color: txn.status == 'Success' ? AppTheme.progressGreen : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('by ${txn.donor ?? ''}', style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹ ${txn.amount}', style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
                      const SizedBox(height: 2),
                      Text(txn.timeAgo, style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey400)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// Auto-scrolling banner slider widget
class _BannerSlider extends StatefulWidget {
  final List<HomeBanner> banners;
  final BuildContext context;
  const _BannerSlider({required this.banners, required this.context});

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      Future.delayed(const Duration(seconds: 3), _autoScroll);
    }
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_currentPage + 1) % widget.banners.length;
    _pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) {
              final banner = widget.banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.bannerBgColor, borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: banner.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(color: AppTheme.bannerBgColor),
                            errorWidget: (c, u, e) => Image.asset('assets/images/donateAndFund.png', fit: BoxFit.cover),
                          ),
                        ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]),
                          ),
                          child: Text(banner.title ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _currentPage == i ? 12 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: _currentPage == i ? AppTheme.primaryDeepBlue : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
