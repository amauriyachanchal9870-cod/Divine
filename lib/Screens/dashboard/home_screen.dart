import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Controller/home_controller.dart';
import '../../Controller/daan_controller.dart';
import '../../Controller/follows_controller.dart';
import '../../Controller/notification_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/helper.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/profile_controller.dart';
import 'main_navigation_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: const Color(0xFFEDF3F8),
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.homeData.value == null) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
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
                  child: Text(AppString.retry.tr),
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
                const SizedBox(height: 12),
                _buildCategories(),
                const SizedBox(height: 12),
                _buildActionButtons(context),
                const SizedBox(height: 12),
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
    final ProfileController profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Obx(() {
        final pData = profileController.profileData.value;
        final name = pData?.name ?? pData?.organizationName ?? controller.user?.name ?? AppString.userFallback.tr;
        final firstName = name.isNotEmpty ? name.trim().split(' ').first : name;
        final profilePhoto = pData?.profilePhoto ?? pData?.logo ?? controller.user?.profilePhoto ?? '';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (controller.isLoading.value) return;
                mainNavKey.currentState?.changeTab(4);
              },
              child: ClipOval(
                child: profilePhoto.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profilePhoto,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => const ShimmerWidget(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                        errorWidget: (c, u, e) => Container(
                          width: 36,
                          height: 36,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, size: 22, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 22, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppString.helloUser.trParams({'name': firstName}),
                style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
      actions: [
        Obx(() {
          final balance = controller.user?.walletBalance ?? 0;
          return GestureDetector(
            onTap: () {
              if (controller.isLoading.value) return;
              mainNavKey.currentState?.changeTab(3);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Image.asset(AppAssets.homeWallet, width: 14, height: 14,),
                    const SizedBox(width: 6),
                    Text(AppString.rupeeBalanceFormat.trParams({'balance': balance.toString()}), style: AppFonts.semiBoldText.copyWith(color: Colors.black, fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (controller.isLoading.value) return;
            Get.toNamed(MyRouters.notificationScreen);
            Get.put(NotificationController()).markNotificationsAsRead();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 22),
                Obx(() {
                  final notifCtrl = Get.put(NotificationController());
                  final hasUnread = notifCtrl.notifications.any((n) => n.isRead == false);
                  if (!hasUnread) return const SizedBox.shrink();
                  
                  return Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                    ),
                  );
                }),
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
        margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
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
      {'name': AppString.all.tr, 'icon': Icons.grid_view, 'selected': true, 'categoryId': 'ALL'},
      {'name': AppString.temple.tr, 'icon': AppAssets.temple, 'selected': false, 'categoryId': 'CAT-TEMPLE'},
      {'name': AppString.books.tr, 'icon': AppAssets.books, 'selected': false, 'categoryId': 'CAT-BOOKS'},
      {'name': AppString.food.tr, 'icon': AppAssets.food, 'selected': false, 'categoryId': 'CAT-FOOD'},
      {'name': AppString.gauSeva.tr, 'icon': AppAssets.gau, 'selected': false, 'categoryId': 'CAT-GAU'},
      {'name': AppString.clothes.tr, 'icon': AppAssets.clothes, 'selected': false, 'categoryId': 'CAT-CLOTHES'},
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
          return GestureDetector(
            onTap: () async {
              final catId = categories[index]['categoryId'] as String;
              if (catId == 'ALL') {
                Get.toNamed(MyRouters.chooseDaanTypeScreen);
                return;
              }
              final DaanController daanController = Get.find<DaanController>();
              if (daanController.categories.isEmpty) {
                Get.dialog(
                  Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                      color: AppTheme.primaryDeepBlue,
                      size: 50,
                    ),
                  ),
                  barrierDismissible: false,
                );
                await daanController.fetchDaanCategories();
                Get.back();
              }
              final matchingCat = daanController.categories.firstWhereOrNull((c) => c.categoryId == catId);
              if (matchingCat != null) {
                Get.toNamed(MyRouters.donateFoodScreen, arguments: matchingCat);
              } else {
                Get.toNamed(MyRouters.chooseDaanTypeScreen);
              }
            },
            child: Container(
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      child: Padding(padding: const EdgeInsets.all(6.0), child: Image.asset(AppAssets.donateHome, fit: BoxFit.contain)),
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
                      child: Padding(padding: const EdgeInsets.all(6.0), child: Image.asset(AppAssets.raiseHome, fit: BoxFit.contain)),
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
          Expanded(flex: 5, child: Image.asset(AppAssets.donateAndFund, height: 100, fit: BoxFit.contain)),
        ],
      ),
    );
  }

  Widget _buildOngoingCampaigns(List<HomeCampaign> campaigns) {
    final ongoingCampaigns = campaigns.where((c) => c.isOngoing).toList();
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
        if (ongoingCampaigns.isEmpty)
          Padding(padding: const EdgeInsets.all(16), child: Center(child: Text(AppString.noCampaignsAvailable.tr)))
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ongoingCampaigns.length > 3 ? 3 : ongoingCampaigns.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final c = ongoingCampaigns[index];
                return GestureDetector(
                  onTap: () => Get.toNamed(MyRouters.campaignDetailsScreen, arguments: c.sId),
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
                                  placeholder: (ctx, url) => const ShimmerWidget(height: 120, width: double.infinity),
                                  errorWidget: (ctx, url, err) => Image.asset(AppAssets.campaignImage, height: 120, width: double.infinity, fit: BoxFit.cover))
                              : Image.asset(AppAssets.campaignImage, height: 120, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(c.description ?? '', style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppString.amountRaised.trParams({'amount': c.formattedRaised}), style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen)),
                                  Text(AppString.amountGoal.trParams({'goal': c.formattedGoal}), style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
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
                                  Text(AppString.donorsCount.trParams({'count': c.formattedDonors.toString()}), style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                                  const Spacer(),
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(AppString.daysLeftCount.trParams({'days': c.daysLeft.toString()}), style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDeepBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                                  onPressed: () => Get.toNamed(MyRouters.donateAmountScreen, arguments: c),
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
    final followsController = Get.put(FollowsController());
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
          Padding(padding: const EdgeInsets.all(16), child: Center(child: Text(AppString.noNgosAvailable.tr)))
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
                return Obx(() {
                  final bool isFollowed = followsController.isNgoFollowed(ngo.id ?? '');
                  return GestureDetector(
                    onTap: () => Get.toNamed(MyRouters.ngoDetailsScreen, arguments: {
                      'id': ngo.id,
                      'name': ngo.name,
                      'isFollowing': isFollowed,
                    }),
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
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: ngo.logo!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          placeholder: (c, u) => const ShimmerWidget(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
                                          errorWidget: (c, u, e) => Image.asset(AppAssets.ngoLogo, fit: BoxFit.cover),
                                        ),
                                      )
                                    : ClipOval(child: Image.asset(AppAssets.ngoLogo, fit: BoxFit.cover)),
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
                          Obx(() {
                            final isFollowedLocal = followsController.isNgoFollowed(ngo.id ?? '');
                            return SizedBox(
                              width: double.infinity,
                              height: 28,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isFollowedLocal ? AppTheme.textGrey400 : AppTheme.primaryDeepBlue),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: EdgeInsets.zero,
                                  backgroundColor: isFollowedLocal ? AppTheme.greyBg300.withValues(alpha: 0.2) : Colors.transparent,
                                ),
                                onPressed: () {
                                  followsController.toggleFollowNgoApi(ngo.id ?? '');
                                },
                                child: Text(
                                  isFollowedLocal ? AppString.unfollow.tr : AppString.follow.tr,
                                  style: TextStyle(
                                    color: isFollowedLocal ? AppTheme.textGrey500 : AppTheme.primaryDeepBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                });
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
                            Text(AppString.byDonor.trParams({'donor': txn.donor ?? ''}), style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("₹${formatPrice(txn.amount ?? 0)}", style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
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
                            placeholder: (c, u) => const ShimmerWidget(width: double.infinity, height: double.infinity),
                            errorWidget: (c, u, e) => Image.asset(AppAssets.donateAndFund, fit: BoxFit.cover),
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
