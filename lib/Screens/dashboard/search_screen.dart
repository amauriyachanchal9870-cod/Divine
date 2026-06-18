import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/search_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CampaignSearchController controller = Get.put(CampaignSearchController());
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchRecentSearches();
    _searchTextController.addListener(() {
      controller.searchQuery.value = _searchTextController.text;
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppString.search.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    controller: _searchTextController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: AppString.searchForCampaigns.tr,
                      hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    style: AppFonts.regularText.copyWith(fontSize: 14),
                    onSubmitted: (value) {
                      controller.saveRecentSearch(value);
                    },
                  ),
                ),
                Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        _searchTextController.clear();
                        controller.searchQuery.value = '';
                      },
                      child: const Icon(Icons.clear, color: Colors.grey, size: 20),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          
          Expanded(
            child: Obx(() {
              final query = controller.searchQuery.value;
              final filtered = controller.filteredCampaigns;

              return CustomScrollView(
                slivers: [
                  // Recent Searches Section (only when query is empty and list is not empty)
                  if (query.isEmpty && controller.recentSearches.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          AppString.recentSearches.tr,
                          style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = controller.recentSearches[index];
                          return ListTile(
                            leading: const Icon(Icons.history, color: Colors.grey, size: 20),
                            title: Text(item, style: AppFonts.regularText.copyWith(fontSize: 14)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                              onPressed: () {
                                controller.removeRecentSearch(item);
                              },
                            ),
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                            onTap: () {
                              _searchTextController.text = item;
                              _searchTextController.selection = TextSelection.fromPosition(
                                TextPosition(offset: item.length),
                              );
                              controller.searchQuery.value = item;
                              controller.saveRecentSearch(item);
                            },
                          );
                        },
                        childCount: controller.recentSearches.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],

                  // Campaigns List Header
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        query.isEmpty ? AppString.ongoingCampaigns.tr : "Search Results",
                        style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
                      ),
                    ),
                  ),

                  // Campaigns List / Empty State
                  if (filtered.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text("No campaigns found"),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final campaign = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildCampaignCard(campaign),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(HomeCampaign c) {
    return GestureDetector(
      onTap: () {
        if (controller.searchQuery.value.isNotEmpty) {
          controller.saveRecentSearch(controller.searchQuery.value);
        }
        Get.toNamed(MyRouters.campaignDetailsScreen);
      },
      child: Container(
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
                  ? CachedNetworkImage(
                      imageUrl: c.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (ctx, url, err) => Image.asset(
                        'assets/images/campaign_image.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/campaign_image.png',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title ?? '',
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.user ?? '',
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹ ${c.raised} raised',
                        style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen),
                      ),
                      Text(
                        'of ${c.goal}',
                        style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                      ),
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
                      Text(
                        '${c.formattedDonors} Donors',
                        style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${c.daysLeft} days left',
                        style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDeepBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (controller.searchQuery.value.isNotEmpty) {
                          controller.saveRecentSearch(controller.searchQuery.value);
                        }
                        Get.toNamed(MyRouters.donateAmountScreen);
                      },
                      child: Text(
                        AppString.donateNow.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
  }
}
