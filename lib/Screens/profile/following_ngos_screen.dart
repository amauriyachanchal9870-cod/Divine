import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class FollowingNgosScreen extends StatefulWidget {
  const FollowingNgosScreen({super.key});

  @override
  State<FollowingNgosScreen> createState() => _FollowingNgosScreenState();
}

class _FollowingNgosScreenState extends State<FollowingNgosScreen> {
  bool isFollowersTab = true; // true = Followers, false = Following
  bool isFilterNgo = true;    // true = NGOs, false = Individuals

  final TextEditingController _searchController = TextEditingController();

  // NGO Demo State
  final List<Map<String, dynamic>> ngos = [
    {
      "name": "Save the Children",
      "impact": "4.8M Global Impact",
      "rating": "4.8",
      "isFollowed": false, // Tab = Followers -> shows Follow
      "logo": "assets/images/ngo_logo.png",
    },
    {
      "name": "Green Earth Foundation",
      "impact": "12.4M Trees Planted",
      "rating": "4.8",
      "isFollowed": true,  // Tab = Followers -> shows Unfollow
      "logo": "assets/images/ngo_logo.png",
    },
    {
      "name": "Save the Children",
      "impact": "4.8M Global Impact",
      "rating": "4.8",
      "isFollowed": true,
      "logo": "assets/images/ngo_logo.png",
    },
    {
      "name": "Green Earth Foundation",
      "impact": "12.4M Trees Planted",
      "rating": "4.8",
      "isFollowed": false,
      "logo": "assets/images/ngo_logo.png",
    },
  ];

  // Individuals Demo State
  final List<Map<String, dynamic>> individuals = [
    {"name": "Aman Singh", "avatar": "https://randomuser.me/api/portraits/men/32.jpg"},
    {"name": "Dianne Russell", "avatar": "https://randomuser.me/api/portraits/women/44.jpg"},
    {"name": "Darlene Robertson", "avatar": "https://randomuser.me/api/portraits/women/12.jpg"},
    {"name": "Wade Warren", "avatar": "https://randomuser.me/api/portraits/men/45.jpg"},
    {"name": "Marvin McKinney", "avatar": "https://randomuser.me/api/portraits/men/22.jpg"},
    {"name": "Esther Howard", "avatar": "https://randomuser.me/api/portraits/women/28.jpg"},
    {"name": "Jenny Wilson", "avatar": "https://randomuser.me/api/portraits/women/35.jpg"},
    {"name": "Ronald Richards", "avatar": "https://randomuser.me/api/portraits/men/50.jpg"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter NGOs based on tab selection
    final List<Map<String, dynamic>> displayedNgos = isFollowersTab 
        ? ngos 
        : ngos.where((n) => n['isFollowed'] == true).toList();

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
            // Filter Selector row (only shown for Followers tab in the mockup)
            if (isFollowersTab) ...[
              _buildFilterRow(),
              const SizedBox(height: 16),
            ],
            
            // Content
            Expanded(
              child: isFollowersTab && !isFilterNgo 
                  ? _buildIndividualsList()
                  : _buildNgosGrid(displayedNgos),
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
                  isFilterNgo = true; // Force NGO view for Following tab
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

  Widget _buildNgosGrid(List<Map<String, dynamic>> displayedNgos) {
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

  Widget _buildNgoCard(Map<String, dynamic> ngo) {
    final bool isFollowed = ngo['isFollowed'];

    return GestureDetector(
      onTap: () {
        Get.toNamed(MyRouters.ngoDetailsScreen, arguments: {'isFollowing': isFollowed});
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
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(ngo['logo']),
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
                          ngo['rating'],
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
                ngo['name'],
                style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ngo['impact'],
              style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
              textAlign: TextAlign.center,
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
                  setState(() {
                    ngo['isFollowed'] = !isFollowed;
                  });
                  Get.snackbar(
                    isFollowed ? AppString.unfollow.tr : AppString.follow.tr, 
                    isFollowed ? "${AppString.youUnfollowed.tr} ${ngo['name']}" : "${AppString.youAreNowFollowing.tr} ${ngo['name']}",
                    snackPosition: SnackPosition.BOTTOM,
                  );
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

  Widget _buildIndividualsList() {
    if (individuals.isEmpty) {
      return Center(
        child: Text(
          AppString.noFollowersFound.tr,
          style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey400),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      itemCount: individuals.length,
      separatorBuilder: (_, __) => Divider(color: AppTheme.greyBg100, height: 1),
      itemBuilder: (context, index) {
        final item = individuals[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(item['avatar']),
                backgroundColor: AppTheme.greyBg100,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item['name'],
                  style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    individuals.removeAt(index);
                  });
                  Get.snackbar(
                    AppString.removed.tr, 
                    AppString.followerRemovedSuccess.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      AppString.remove.tr,
                      style: AppFonts.mediumText.copyWith(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
