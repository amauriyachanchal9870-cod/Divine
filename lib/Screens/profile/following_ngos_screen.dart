import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import '../../Controller/follows_controller.dart';
import '../../Model/social_model.dart';

class FollowingNgosScreen extends StatefulWidget {
  const FollowingNgosScreen({super.key});

  @override
  State<FollowingNgosScreen> createState() => _FollowingNgosScreenState();
}

class _FollowingNgosScreenState extends State<FollowingNgosScreen> {
  bool isFollowersTab = true; // true = Followers, false = Following
  bool isFilterNgo = true;    // true = NGOs, false = Individuals

  final TextEditingController _searchController = TextEditingController();
  final FollowsController _followsController = Get.put(FollowsController());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _followsController.searchQuery.value = _searchController.text;
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
            AppString.follows.tr, 
            style: AppFonts.titleStyle.copyWith(fontSize: 18, color: Colors.black87)
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            // Custom Tab Switcher (Followers vs Following)
            _buildTabSwitcher(),
            const SizedBox(height: 16),
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 16),
            // Filter Selector row
            _buildFilterRow(),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: Obx(() {
                if (_followsController.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                      color: AppTheme.primaryDeepBlue,
                      size: 50,
                    ),
                  );
                }

                if (isFollowersTab) {
                  if (isFilterNgo) {
                    return _buildNgosGrid(_followsController.topNgos);
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
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.greyBg100,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          // Followers Tab
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
                  color: !isFollowersTab ? AppTheme.secondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppString.following.tr,
                  style: AppFonts.semiBoldText.copyWith(
                    fontSize: 14,
                    color: !isFollowersTab ? AppTheme.whiteColor : Colors.black54,
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
        childAspectRatio: 0.72,
      ),
      itemCount: displayedNgos.length,
      itemBuilder: (context, index) {
        final ngo = displayedNgos[index];
        return _buildNgoCard(ngo);
      },
    );
  }

  Widget _buildNgoCard(SocialNgo ngo) {
    final bool isFollowed = _followsController.isNgoFollowed(ngo.id ?? '');

    return GestureDetector(
      onTap: () {
        Get.toNamed(MyRouters.ngoDetailsScreen, arguments: {
          'id': ngo.id,
          'name': ngo.name,
          'isFollowing': isFollowed,
        });
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
                          errorWidget: (c, u, e) => Image.asset(AppAssets.ngoLogo, width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : Image.asset(AppAssets.ngoLogo, width: 60, height: 60, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.ratingGreenBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: AppTheme.whiteColor, size: 8),
                        const SizedBox(width: 2),
                        Text(
                          ngo.rating?.toString() ?? '4.5',
                          style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 4),
            Text(
              ngo.about?.isNotEmpty == true ? ngo.about! : "Divine Help",
              style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                child: Text(
                  isFollowed ? AppString.unfollow.tr : AppString.follow.tr,
                  style: TextStyle(
                    color: AppTheme.primaryDeepBlue, 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
                  item.name?.isNotEmpty == true ? item.name! : (item.phone ?? ''),
                  style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87),
                ),
              ),
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
