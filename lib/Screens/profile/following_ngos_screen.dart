import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/helper.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/follows_controller.dart';
import '../../Controller/banner_controller.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';
import '../../Widget/banner_slider_widget.dart';
import '../../Model/social_model.dart';

class FollowingNgosScreen extends StatefulWidget {
  const FollowingNgosScreen({super.key});

  @override
  State<FollowingNgosScreen> createState() => _FollowingNgosScreenState();
}

class _FollowingNgosScreenState extends State<FollowingNgosScreen> {
  bool isFollowersTab = false; // true = Followers, false = Following (defaults to false for donor/individual/corporate)
  bool isFilterNgo = true;    // true = NGOs, false = Individuals
  String _userRole = '';

  final TextEditingController _searchController = TextEditingController();
  final FollowsController _followsController = Get.put(FollowsController());
  late final BannerController _bannerController;

  String _determineRole() {
    if (Get.isRegistered<ProfileController>()) {
      final r = Get.find<ProfileController>().profileData.value?.role;
      if (r != null && r.trim().isNotEmpty) return r.trim().toLowerCase();
    }
    if (Get.isRegistered<HomeController>()) {
      final r = Get.find<HomeController>().user?.role;
      if (r != null && r.trim().isNotEmpty) return r.trim().toLowerCase();
    }
    return '';
  }

  bool get _isNgoUser {
    final role = _userRole.isNotEmpty ? _userRole : _determineRole();
    return role.toLowerCase() == 'ngo';
  }

  Future<void> _loadRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = (prefs.getString('role') ?? '').trim().toLowerCase();
      if (savedRole.isNotEmpty && mounted) {
        final wasEmpty = _userRole.isEmpty;
        setState(() {
          _userRole = savedRole;
          if (_isNgoUser) {
            if (wasEmpty) isFollowersTab = true;
          } else {
            isFollowersTab = false;
          }
        });
        if (_isNgoUser) {
          _followsController.fetchFollowersList(forceRefresh: true);
        }
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void initState() {
    super.initState();
    _userRole = _determineRole();
    if (_isNgoUser) {
      isFollowersTab = true;
    } else {
      isFollowersTab = false;
    }
    _loadRole();

    _bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController());

    _searchController.addListener(() {
      _followsController.searchQuery.value = _searchController.text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bannerController.fetchBanners('following_list');
        _followsController.fetchFollowingList(forceRefresh: true);
        if (_isNgoUser) {
          _followsController.fetchFollowersList(forceRefresh: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(
              _isNgoUser ? AppString.socialNetwork.tr : AppString.following.tr,
            style: AppFonts.titleStyle.copyWith(fontSize: 18, color: Colors.black87)
          ),
          centerTitle: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _followsController.fetchFollowingList();
            if (_isNgoUser) {
              await _followsController.fetchFollowersList();
            }
            await _bannerController.fetchBanners('following_list', forceRefresh: true);
          },
          child: Column(
            children: [
              const SizedBox(height: 8),
              Obx(() {
                final topBanners = _bannerController.getTopBanners('following_list');
                if (topBanners.isNotEmpty) {
                  return BannerSliderWidget(
                    banners: topBanners,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  );
                }
                return const SizedBox.shrink();
              }),
              // Custom Tab Switcher (Followers vs Following)
              _buildTabSwitcher(),
              const SizedBox(height: 16),
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              Obx(() {
                final bottomBanners = _bannerController.getBottomBanners('following_list');
                if (bottomBanners.isNotEmpty) {
                  return BannerSliderWidget(
                    banners: bottomBanners,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  );
                }
                return const SizedBox.shrink();
              }),
              // Filter Selector row
              // _buildFilterRow(),
              // const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: Obx(() {
                  final bool showFollowers = _isNgoUser;
                  if (_followsController.isFollowingLoading.value || (showFollowers && _followsController.isFollowersLoading.value)) {
                    return Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppTheme.primaryDeepBlue,
                        size: 50,
                      ),
                    );
                  }

                  if (showFollowers && isFollowersTab) {
                    if (isFilterNgo) {
                      return _buildNgosGrid(_followsController.followersNgos);
                    } else {
                      return _buildIndividualsList(_followsController.followers);
                    }
                  } else {
                    if (isFilterNgo) {
                      return _buildNgosGrid(_followsController.followingNgos);
                    } else {
                      return _buildIndividualsList(_followsController.followingUsers);
                    }
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final bool showFollowers = _isNgoUser;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.greyBg100,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          // Followers Tab (Only for NGO users)
          if (showFollowers)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFollowersTab = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isFollowersTab ? AppTheme.secondaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppString.followers.tr,
                    style: AppFonts.semiBoldText.copyWith(
                      fontSize: 14,
                      color: isFollowersTab ? AppTheme.whiteColor : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          // Following Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFollowersTab = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: (!isFollowersTab || !showFollowers) ? AppTheme.secondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppString.following.tr,
                  style: AppFonts.semiBoldText.copyWith(
                    fontSize: 14,
                    color: (!isFollowersTab || !showFollowers) ? AppTheme.whiteColor : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.fieldBorderColor),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppString.searchForNgos.tr,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // NGOs Filter Pill
          GestureDetector(
            onTap: () {
              setState(() {
                isFilterNgo = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isFilterNgo ? AppTheme.blueLightBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFilterNgo ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
                ),
              ),
              child: Text(
                AppString.ngos.tr,
                style: AppFonts.semiBoldText.copyWith(
                  fontSize: 12,
                  color: isFilterNgo ? AppTheme.primaryDeepBlue : Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Individuals Filter Pill
          GestureDetector(
            onTap: () {
              setState(() {
                isFilterNgo = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !isFilterNgo ? AppTheme.blueLightBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: !isFilterNgo ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
                ),
              ),
              child: Text(
                AppString.individuals.tr,
                style: AppFonts.semiBoldText.copyWith(
                  fontSize: 12,
                  color: !isFilterNgo ? AppTheme.primaryDeepBlue : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNgosGrid(List<SocialNgo> displayedNgos) {
    if (displayedNgos.isEmpty) {
      return Center(
        child: Text(
          AppString.noFollowedNgos.tr,
          style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey400),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: displayedNgos.length,
      itemBuilder: (context, index) {
        final ngo = displayedNgos[index];
        return _buildNgoCard(ngo);
      },
    );
  }

  Widget _buildNgoCard(SocialNgo ngo) {
    final String role = (ngo.role != null && ngo.role!.trim().isNotEmpty)
        ? ngo.role!.trim().toLowerCase()
        : 'ngo';
    final bool isCorporateOrDonor = role == 'corporate' || role == 'donor';
    final bool showFollowButton = !isFollowersTab || (_isNgoUser && !isCorporateOrDonor && role == 'ngo');

    return GestureDetector(
      onTap: isCorporateOrDonor
          ? null
          : () {
              final payload = {
                'id': ngo.ngoId,
                'name': ngo.name,
                'isFollowing': _followsController.isNgoFollowed(ngo.ngoId ?? ''),
              };
              debugPrint("==================================================");
              debugPrint("🟢 [TAP NGO] Navigating to NGO Details from FollowingNgosScreen");
              debugPrint("🟢 Payload / Arguments: $payload");
              debugPrint("==================================================");
              Get.toNamed(MyRouters.ngoDetailsScreen, arguments: payload);
            },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.fieldBorderColor),
          boxShadow: [
            BoxShadow(
              color: AppTheme.blackColor.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Stack with overlapping Rating Pill
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: ngo.logo != null && ngo.logo!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: ngo.logo!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => const ShimmerWidget(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
                          errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : Image.asset(AppAssets.appLogo, width: 60, height: 60, fit: BoxFit.cover),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ngo.name ?? '',
                style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showFollowButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 32,
                width: 100,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryDeepBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    _followsController.toggleFollowNgoApi(ngo.id ?? '');
                  },
                  child: Obx(() {
                    final isFollowed = _followsController.isNgoFollowed(ngo.id ?? '');
                    return Text(
                      isFollowed ? AppString.unfollow.tr : AppString.follow.tr,
                      style: TextStyle(
                        color: AppTheme.primaryDeepBlue, 
                        fontSize: 11, 
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualsList(List<SocialDonor> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          AppString.noFollowersFound.tr,
          style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey400),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => Divider(color: AppTheme.greyBg100, height: 1),
      itemBuilder: (context, index) {
        final item = list[index];
        final String role = (item.role != null && item.role!.trim().isNotEmpty)
            ? item.role!.trim().toLowerCase()
            : 'donor';
        final bool isCorporateOrDonor = role == 'corporate' || role == 'donor';
        final bool showFollowButton = !isFollowersTab || (_isNgoUser && !isCorporateOrDonor && role == 'ngo');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              ClipOval(
                child: item.profilePhoto != null && item.profilePhoto!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: item.profilePhoto!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => const ShimmerWidget(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
                        errorWidget: (c, u, e) => Container(
                          width: 40,
                          height: 40,
                          color: AppTheme.greyBg100,
                          child: const Icon(Icons.person, color: Colors.grey, size: 20),
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: AppTheme.greyBg100,
                        child: const Icon(Icons.person, color: Colors.grey, size: 20),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.name?.isNotEmpty == true ? item.name! : formatPhoneWithCountryCode(item.phone),
                  style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87),
                ),
              ),
              if (showFollowButton)
                SizedBox(
                  height: 32,
                  width: 90,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryDeepBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _followsController.toggleFollowUserApi(item.id ?? '');
                    },
                    child: Obx(() {
                      final isFollowed = _followsController.isUserFollowed(item.id ?? '');
                      return Text(
                        isFollowed ? AppString.following.tr : AppString.follow.tr,
                        style: TextStyle(
                          color: AppTheme.primaryDeepBlue, 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
