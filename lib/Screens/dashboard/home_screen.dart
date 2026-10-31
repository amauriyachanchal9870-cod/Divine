import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Controller/home_controller.dart';
import '../../Controller/daan_controller.dart';
import '../../Controller/follows_controller.dart';
import '../../Controller/notification_controller.dart';
import '../../Controller/banner_controller.dart';
import '../../Widget/banner_slider_widget.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/helper.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/wallet_controller.dart';
import 'main_navigation_screen.dart';
import '../../Widget/campaign_review_bottom_sheet.dart';
import 'press_and_media_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final BannerController bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController());

    return Obx(() {
      final isDataLoading = controller.isLoading.value && controller.homeData.value == null;
      return Scaffold(
        backgroundColor: const Color(0xFFEDF3F8),
        appBar: isDataLoading ? null : _buildAppBar(context, controller),
        body: isDataLoading
            ? Center(
                child: LoadingAnimationWidget.threeRotatingDots(
                  color: AppTheme.primaryDeepBlue,
                  size: 50,
                ),
              )
            : controller.errorMessage.value.isNotEmpty && controller.homeData.value == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(controller.errorMessage.value, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchHomeData(forceRefresh: true),
                          child: Text(AppString.retry.tr),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.fetchHomeData(forceRefresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          // const SizedBox(height: 12),
                          // _buildCategories(controller),
                          const SizedBox(height: 12),
                          Obx(() => _buildActionButtons(context)),
                          const SizedBox(height: 12),
                          Obx(() {
                            final topBanners = bannerController.getTopBanners('home');
                            if (topBanners.isNotEmpty) {
                              return BannerSliderWidget(banners: topBanners);
                            }
                            if (controller.banners.isNotEmpty) {
                              return _buildBannerSlider(context, controller.banners);
                            }
                            return const SizedBox.shrink();
                          }),
                          _buildOngoingCampaigns(controller.campaigns),
                          _buildTopNGOs(controller.ngos),
                          _buildPressAndMedia(controller.pressAndMedia),
                          _buildDonationHistory(controller.homeDonationHistory),
                          Obx(() {
                            final bottomBanners = bannerController.getBottomBanners('home');
                            if (bottomBanners.isNotEmpty) {
                              return BannerSliderWidget(
                                banners: bottomBanners,
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context, HomeController controller) {
    final ProfileController profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Obx(() {
        final pData = profileController.profileData.value;
        final role = (pData?.role ?? controller.user?.role ?? '').toLowerCase();
        final bool isOrg = role == 'ngo' || role == 'corporate';
        final String name = isOrg
            ? ((pData?.organizationName != null && pData!.organizationName!.trim().isNotEmpty)
                ? pData.organizationName!.trim()
                : ((pData?.name != null && pData!.name!.trim().isNotEmpty)
                    ? pData.name!.trim()
                    : (controller.user?.name ?? AppString.userFallback.tr)))
            : ((pData?.name != null && pData!.name!.trim().isNotEmpty)
                ? pData.name!.trim()
                : (controller.user?.name ?? AppString.userFallback.tr));
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
                        key: ValueKey(profilePhoto),
                        imageUrl: profilePhoto,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => const ShimmerWidget(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                        errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, width: 36, height: 36, fit: BoxFit.cover),
                      )
                    : Image.asset(AppAssets.appLogo, width: 36, height: 36, fit: BoxFit.cover),
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
          final homeUser = controller.homeData.value?.user;
          final profileController = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;
          final walletController = Get.isRegistered<WalletController>() ? Get.find<WalletController>() : null;

          double walletBalance = profileController?.profileData.value?.walletBalance ?? 
              (walletController?.walletBalance.value ?? 0.0);
          if (walletBalance == 0.0 && homeUser?.walletBalance != null && homeUser!.walletBalance! > 0) {
            walletBalance = homeUser.walletBalance!.toDouble();
          }

          final formattedBalance = formatPrice(walletBalance);

          return GestureDetector(
            onTap: () {
              final mainState = context.findAncestorStateOfType<MainNavigationScreenState>();
              if (mainState != null) {
                mainState.changeTab(3);
              } else {
                mainNavKey.currentState?.changeTab(3);
              }
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
                    Text("₹ $formattedBalance", style: AppFonts.semiBoldText.copyWith(color: Colors.black, fontSize: 14)),
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
                  final notifCtrl = Get.isRegistered<NotificationController>()
                      ? Get.find<NotificationController>()
                      : Get.put(NotificationController());
                  final hasUnread = notifCtrl.notifications.isNotEmpty &&
                      notifCtrl.notifications.any((n) => n.isRead == false);
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

  Widget _buildCategories(HomeController controller) {
    final List<Map<String, dynamic>> categoriesList = [
      {
        'name': AppString.all.tr,
        'icon': Icons.grid_view,
        'selected': true,
        'categoryId': 'ALL'
      },
    ];

    if (controller.categories.isNotEmpty) {
      for (var cat in controller.categories) {
        dynamic iconVal;
        final iconStr = cat.icon ?? '';
        final imgStr = cat.imageUrl ?? '';

        if (iconStr.startsWith('http://') || iconStr.startsWith('https://')) {
          iconVal = iconStr;
        } else if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
          iconVal = imgStr;
        } else {
          final nameLower = (cat.name ?? '').toLowerCase();
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

        categoriesList.add({
          'name': cat.name ?? '',
          'icon': iconVal,
          'selected': false,
          'categoryId': cat.categoryId ?? '',
        });
      }
    } else {
      categoriesList.addAll([
        {'name': AppString.temple.tr, 'icon': AppAssets.temple, 'selected': false, 'categoryId': 'CAT-TEMPLE'},
        {'name': AppString.books.tr, 'icon': AppAssets.books, 'selected': false, 'categoryId': 'CAT-BOOKS'},
        {'name': AppString.food.tr, 'icon': AppAssets.food, 'selected': false, 'categoryId': 'CAT-FOOD'},
        {'name': AppString.gauSeva.tr, 'icon': AppAssets.gau, 'selected': false, 'categoryId': 'CAT-GAU'},
        {'name': AppString.clothes.tr, 'icon': AppAssets.clothes, 'selected': false, 'categoryId': 'CAT-CLOTHES'},
      ]);
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categoriesList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categoriesList[index];
          final isSelected = item['selected'] as bool;
          final catName = item['name'] as String;
          final catId = item['categoryId'] as String;
          final iconData = item['icon'];

          return GestureDetector(
            onTap: () async {
              if (catId == 'ALL') {
                Get.toNamed(MyRouters.chooseDaanTypeScreen);
                return;
              }
              final DaanController daanController = Get.isRegistered<DaanController>()
                  ? Get.find<DaanController>()
                  : Get.put(DaanController());
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
              final matchingCat = daanController.categories.firstWhereOrNull(
                (c) => c.categoryId == catId ||
                       (c.categoryId != null && catId.isNotEmpty && c.categoryId!.toLowerCase() == catId.toLowerCase()) ||
                       (c.name != null && catName.isNotEmpty && c.name!.toLowerCase() == catName.toLowerCase()),
              );
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
                  if (iconData is IconData)
                    Icon(iconData, size: 14, color: isSelected ? AppTheme.primaryDeepBlue : Colors.orange)
                  else if (iconData is String && (iconData.startsWith('http://') || iconData.startsWith('https://')))
                    Image.network(
                      iconData,
                      width: 14,
                      height: 14,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.category, size: 14, color: isSelected ? AppTheme.primaryDeepBlue : Colors.orange),
                    )
                  else if (iconData is String && iconData.isNotEmpty)
                    Image.asset(
                      iconData,
                      width: 14,
                      height: 14,
                      errorBuilder: (c, e, s) => Icon(Icons.category, size: 14, color: isSelected ? AppTheme.primaryDeepBlue : Colors.orange),
                    )
                  else
                    Icon(Icons.category, size: 14, color: isSelected ? AppTheme.primaryDeepBlue : Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    catName,
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
    final profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());
    final userRole = (profileCtrl.profileData.value?.role ?? '').toLowerCase();
    final isCorporate = userRole == 'corporate';

    if (isCorporate) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GestureDetector(
          onTap: () => context.findAncestorStateOfType<MainNavigationScreenState>()?.changeTab(1),
          child: Container(
            height: 55,
            width: double.infinity,
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
      );
    }

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
      return const SizedBox.shrink();
    }
    return _BannerSlider(banners: banners, context: context);
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
              if(ongoingCampaigns.isNotEmpty)
              GestureDetector(
                onTap: () => Get.toNamed(MyRouters.ongoingCampaignScreen),
                child: Text(AppString.seeAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (ongoingCampaigns.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22), child: Center(child: Text(AppString.noCampaignsAvailable.tr)))
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
                                  errorWidget: (ctx, url, err) => Image.asset(AppAssets.appLogo, height: 120, width: double.infinity, fit: BoxFit.cover))
                              : Image.asset(AppAssets.appLogo, height: 120, width: double.infinity, fit: BoxFit.cover),
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
                              Builder(
                                builder: (context) {
                                  final bool isSelf = isSelfCampaign(
                                    campaignUserId: c.userId,
                                    campaignUser: c.user,
                                    campaignId: c.campaignId,
                                    campaignSId: c.sId,
                                  );
                                  final bool showReview = canShowCampaignReviewButton(
                                    isSelf: isSelf,
                                    isCompleted: c.isCompleted,
                                  );

                                  if (showReview) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 36,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryDeepBlue,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () => Get.toNamed(MyRouters.donateAmountScreen, arguments: c),
                                              child: Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: SizedBox(
                                            height: 36,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: AppTheme.primaryDeepBlue),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                showCampaignReviewBottomSheet(
                                                  context: context,
                                                  campaignId: (c.campaignId != null && c.campaignId!.isNotEmpty) ? c.campaignId! : (c.sId ?? ''),
                                                  campaignTitle: c.title,
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.star_outline, size: 14, color: AppTheme.primaryDeepBlue),
                                                  const SizedBox(width: 4),
                                                  Text("Review", style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDeepBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                                      onPressed: () => Get.toNamed(MyRouters.donateAmountScreen, arguments: c),
                                      child: Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                },
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
    final followsController = Get.isRegistered<FollowsController>()
        ? Get.find<FollowsController>()
        : Get.put(FollowsController());
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppString.topNGOs.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              if (ngos.isNotEmpty)
              GestureDetector(onTap: () => Get.toNamed(MyRouters.ngosGridScreen), child: Text(AppString.seeAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (ngos.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22), child: Center(child: Text(AppString.noNgosAvailable.tr)))
        else
          SizedBox(
            height: 160,
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
                                          errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                                        ),
                                      )
                                    : ClipOval(child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover)),
                              ),
                              if (ngo.rating != null && ngo.rating! > 0.0)
                                Positioned(
                                  bottom: -10, left: 0, right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppTheme.progressGreen, borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: Colors.white, size: 10),
                                          const SizedBox(width: 2),
                                          Text('${ngo.rating}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(ngo.name ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          // if (ngo.impactStats != null && ngo.impactStats!.isNotEmpty)
                          //   Text(ngo.impactStats!, style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildPressAndMedia(List<HomePressMedia> pressList) {
    if (pressList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.pressAndMedia.tr,
                style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(MyRouters.pressAndMediaScreen, arguments: pressList),
                child: Text(
                  AppString.seeAll.tr,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 185,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: pressList.length > 3 ? 3 : pressList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = pressList[index];
              final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
              return GestureDetector(
                onTap: () => PressAndMediaScreen.showDetailsSheet(context, item),
                child: Container(
                  width: 220,
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
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl!.trim(),
                              height: 105,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => const ShimmerWidget(height: 105, width: double.infinity),
                              errorWidget: (ctx, url, err) => Container(
                                height: 105,
                                width: double.infinity,
                                color: const Color(0xFFF5F7FA),
                                alignment: Alignment.center,
                                child: Image.asset(AppAssets.appLogo, height: 60, fit: BoxFit.contain),
                              ),
                            )
                          : Container(
                              height: 105,
                              width: double.infinity,
                              color: const Color(0xFFF5F7FA),
                              alignment: Alignment.center,
                              child: Image.asset(AppAssets.appLogo, height: 60, fit: BoxFit.contain),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.source != null && item.source!.trim().isNotEmpty) ...[
                            Text(
                              item.source!.trim(),
                              style: AppFonts.regularText.copyWith(
                                fontSize: 10,
                                color: AppTheme.primaryDeepBlue,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                          ],
                          Text(
                            item.title ?? '',
                            style: AppFonts.semiBoldText.copyWith(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
              Text(AppString.recentDonorTransaction.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              // GestureDetector(
              //   onTap: () => Get.toNamed(MyRouters.donationHistoryScreen),
              //   child: Text(AppString.seeAll.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue)),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _AutoScrollDonationHistoryList(history: history),
      ],
    );
  }
}

class _AutoScrollDonationHistoryList extends StatefulWidget {
  final List<HomeDonationHistory> history;
  const _AutoScrollDonationHistoryList({required this.history});

  @override
  State<_AutoScrollDonationHistoryList> createState() => _AutoScrollDonationHistoryListState();
}

class _AutoScrollDonationHistoryListState extends State<_AutoScrollDonationHistoryList> {
  late final ScrollController _scrollController;
  Timer? _timer;
  int _currentIndex = 0;
  final double _itemHeight = 76.0; // Card height (64) + spacing (12)

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final itemsCount = widget.history.length > 10 ? 10 : widget.history.length;
    if (itemsCount > 3) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_scrollController.hasClients) return;
      final itemsCount = widget.history.length > 10 ? 10 : widget.history.length;
      if (itemsCount <= 3) return;

      final currentOffsetIndex = (_scrollController.offset / _itemHeight).round();
      _currentIndex = currentOffsetIndex + 1;

      _scrollController.animateTo(
        _currentIndex * _itemHeight,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _AutoScrollDonationHistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.history != oldWidget.history) {
      _timer?.cancel();
      final itemsCount = widget.history.length > 10 ? 10 : widget.history.length;
      if (itemsCount > 3) {
        _startAutoScroll();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = widget.history.take(10).toList();
    final count = displayList.length;
    if (count == 0) return const SizedBox.shrink();

    if (count <= 3) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildItem(displayList[index]),
      );
    }

    return SizedBox(
      height: 216,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: 10000,
        itemBuilder: (context, index) {
          final txn = displayList[index % count];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItem(txn),
          );
        },
      ),
    );
  }

  Widget _buildItem(HomeDonationHistory txn) {
    return Container(
      height: 66,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  txn.item ?? '',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                    Expanded(
                      child: Text(
                        AppString.byDonor.trParams({'donor': txn.donor ?? ''}),
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("₹${formatPrice(txn.amount ?? 0)}", style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
              const SizedBox(height: 2),
              Text(txn.timeAgo, style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey400)),
            ],
          ),
        ],
      ),
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
                            errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
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
