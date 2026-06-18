import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class NgosScreen extends StatefulWidget {
  const NgosScreen({super.key});

  @override
  State<NgosScreen> createState() => _NgosScreenState();
}

class _NgosScreenState extends State<NgosScreen> {
  final List<Map<String, dynamic>> ngos = [
    {
      'name': 'Save the Children',
      'impact': '4.8M Global Impact',
      'rating': '4.8',
      'isFollowed': false,
      'category': 'childrenCategory',
    },
    {
      'name': 'Green Earth Foundation',
      'impact': '12.4M Trees Planted',
      'rating': '4.9',
      'isFollowed': false,
      'category': 'animal',
    },
    {
      'name': 'Women Empowerment Trust',
      'impact': '2.1M Girls Educated',
      'rating': '4.7',
      'isFollowed': false,
      'category': 'womenAndGirls',
    },
    {
      'name': 'Global Medical Relief',
      'impact': '500K Lives Saved',
      'rating': '4.8',
      'isFollowed': false,
      'category': 'medicalCategory',
    },
    {
      'name': 'National Literacy Campaign',
      'impact': '1.2M Adults Literate',
      'rating': '4.6',
      'isFollowed': false,
      'category': 'educationCategory',
    },
    {
      'name': 'Disabled Care Foundation',
      'impact': '300K Wheelchairs Donated',
      'rating': '4.9',
      'isFollowed': false,
      'category': 'disabledCategory',
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Obtain the category passed via arguments (if any)
    final categoryArg = (Get.arguments?['category'] ?? '').toString();

    final filteredNgos = ngos.where((ngo) {
      final name = ngo['name'].toString().toLowerCase();
      final matchesSearch = name.contains(searchQuery.toLowerCase());

      if (categoryArg.isNotEmpty) {
        // Find if category translates or matches
        final ngoCatKey = ngo['category'] as String;
        // Translate key to compare with the translated categoryArg
        final translatedNgoCat = ngoCatKey.tr.toLowerCase();
        final lowerCategoryArg = categoryArg.toLowerCase();
        return matchesSearch && (translatedNgoCat.contains(lowerCategoryArg) || ngoCatKey.toLowerCase().contains(lowerCategoryArg));
      }
      return matchesSearch;
    }).toList();

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
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: filteredNgos.isEmpty
                ? Center(
                    child: Text(
                      AppString.noDataFound.tr,
                      style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.73,
                    ),
                    itemCount: filteredNgos.length,
                    itemBuilder: (context, index) {
                      final ngo = filteredNgos[index];
                      final isFollowed = ngo['isFollowed'] as bool;
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(MyRouters.ngoDetailsScreen, arguments: {
                            'name': ngo['name'],
                            'isFollowed': ngo['isFollowed'],
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppTheme.fieldBorderColor),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const CircleAvatar(
                                    radius: 36,
                                    backgroundImage: AssetImage('assets/images/ngo_logo.png'),
                                  ),
                                  Positioned(
                                    bottom: -8,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.progressGreen,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, color: Colors.white, size: 10),
                                            const SizedBox(width: 2),
                                            Text(
                                              ngo['rating'] as String, 
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                ngo['name'] as String,
                                style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ngo['impact'] as String,
                                style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: isFollowed ? AppTheme.textGrey400 : AppTheme.primaryDeepBlue),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: EdgeInsets.zero,
                                    backgroundColor: isFollowed ? AppTheme.greyBg300.withValues(alpha: 0.2) : Colors.transparent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      ngo['isFollowed'] = !isFollowed;
                                    });
                                    Get.snackbar(
                                      isFollowed ? AppString.unfollow.tr : AppString.follow.tr, 
                                      isFollowed 
                                          ? "${AppString.youUnfollowed.tr} ${ngo['name']}" 
                                          : "${AppString.youAreNowFollowing.tr} ${ngo['name']}",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                  child: Text(
                                    isFollowed ? AppString.following.tr : AppString.follow.tr, 
                                    style: TextStyle(
                                      color: isFollowed ? AppTheme.textGrey500 : AppTheme.primaryDeepBlue, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Expanded(
            child: TextField(
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: AppString.searchForNgos.tr,
                hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppFonts.regularText.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
