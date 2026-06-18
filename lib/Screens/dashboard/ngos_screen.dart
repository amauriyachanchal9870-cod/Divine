import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/home_controller.dart';
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
  final HomeController homeController = Get.find<HomeController>();
  final RxSet<String> followedNgos = <String>{}.obs;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Obtain the category passed via arguments (if any)
    final categoryArg = (Get.arguments?['category'] ?? '').toString();

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
            child: Obx(() {
              final allNgos = homeController.ngos;
              
              final filteredNgos = allNgos.where((ngo) {
                final name = (ngo.name ?? '').toLowerCase();
                final matchesSearch = name.contains(searchQuery.toLowerCase());

                if (categoryArg.isNotEmpty) {
                  final description = (ngo.description ?? '').toLowerCase();
                  final lowerCategoryArg = categoryArg.toLowerCase();
                  
                  // Helper to match broad categories to descriptions or names
                  bool categoryMatch = false;
                  if (lowerCategoryArg.contains("women") || lowerCategoryArg.contains("girl")) {
                    categoryMatch = description.contains("women") || description.contains("girl") || name.contains("women") || name.contains("girl") || description.contains("empowerment");
                  } else if (lowerCategoryArg.contains("child")) {
                    categoryMatch = description.contains("child") || description.contains("kid") || name.contains("child") || name.contains("kid");
                  } else if (lowerCategoryArg.contains("animal") || lowerCategoryArg.contains("cow") || lowerCategoryArg.contains("gau")) {
                    categoryMatch = description.contains("animal") || description.contains("cow") || description.contains("gau") || name.contains("animal") || name.contains("cow") || name.contains("gau") || description.contains("welfare");
                  } else if (lowerCategoryArg.contains("medic")) {
                    categoryMatch = description.contains("medic") || description.contains("health") || name.contains("medic") || name.contains("health");
                  } else if (lowerCategoryArg.contains("educat") || lowerCategoryArg.contains("literac")) {
                    categoryMatch = description.contains("educat") || description.contains("school") || description.contains("literac") || name.contains("educat") || name.contains("school") || name.contains("literac");
                  } else if (lowerCategoryArg.contains("disab") || lowerCategoryArg.contains("care")) {
                    categoryMatch = description.contains("disab") || description.contains("care") || name.contains("disab") || name.contains("care");
                  } else {
                    categoryMatch = description.contains(lowerCategoryArg) || name.contains(lowerCategoryArg);
                  }
                  
                  return matchesSearch && categoryMatch;
                }
                return matchesSearch;
              }).toList();

              if (filteredNgos.isEmpty) {
                return Center(
                  child: Text(
                    AppString.noDataFound.tr,
                    style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
                  ),
                );
              }

              return GridView.builder(
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
                  final isFollowed = followedNgos.contains(ngo.id ?? ngo.name);
                  
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(MyRouters.ngoDetailsScreen, arguments: {
                        'name': ngo.name,
                        'isFollowed': isFollowed,
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
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey.shade200,
                                child: ngo.logo != null && ngo.logo!.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: ngo.logo!,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorWidget: (c, u, e) => Image.asset(
                                            'assets/images/ngo_logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : ClipOval(
                                        child: Image.asset(
                                          'assets/images/ngo_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                          '${ngo.rating ?? 4.5}', 
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
                            ngo.name ?? '',
                            style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ngo.impactStats ?? 'Active Impact',
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
                                final ngoKey = ngo.id ?? ngo.name ?? '';
                                if (isFollowed) {
                                  followedNgos.remove(ngoKey);
                                } else {
                                  followedNgos.add(ngoKey);
                                }
                                Get.snackbar(
                                  isFollowed ? AppString.unfollow.tr : AppString.follow.tr, 
                                  isFollowed 
                                      ? "${AppString.youUnfollowed.tr} ${ngo.name}" 
                                      : "${AppString.youAreNowFollowing.tr} ${ngo.name}",
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
              );
            }),
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
