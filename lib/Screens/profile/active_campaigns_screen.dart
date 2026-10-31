import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Controller/active_campaigns_controller.dart';
import '../../Model/campaign_details_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_assets.dart';
import '../../Routes/my_routes.dart';
import '../../Widget/campaign_review_bottom_sheet.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ActiveCampaignsScreen extends StatefulWidget {
  const ActiveCampaignsScreen({super.key});

  @override
  State<ActiveCampaignsScreen> createState() => _ActiveCampaignsScreenState();
}

class _ActiveCampaignsScreenState extends State<ActiveCampaignsScreen> {
  final ActiveCampaignsController controller = Get.put(ActiveCampaignsController());

  @override
  void initState() {
    super.initState();
    controller.searchQuery.value = '';
    controller.selectedCategory.value = 'All';
    controller.fetchCampaignCategories();
  }

  Future<void> _refreshData() async {
    await controller.fetchActiveCampaigns();
    await controller.fetchCampaignCategories();
  }

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
        title: Text(AppString.activeCampaigns.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: AppFonts.regularText.copyWith(
                    fontSize: 14,
                    color: Colors.red.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final campaigns = controller.filteredCampaigns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSearchBar(controller),
            // _buildTabs(controller),
            // const SizedBox(height: 12),
            _buildCategories(controller),
            const SizedBox(height: 16),
            Expanded(
              child: campaigns.isEmpty
                  ? Center(
                      child: Text(
                        controller.selectedCampaignTab.value == 'Completed'
                            ? "No completed campaigns found"
                            : "No active campaigns found",
                        style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = campaigns[index];
                          return _buildCampaignCard(campaign);
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabs(ActiveCampaignsController controller) {
    return Obx(() {
      final isCompleted = controller.selectedCampaignTab.value == 'Completed';

      return Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.selectedCampaignTab.value = 'Active';
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isCompleted ? AppTheme.primaryDeepBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !isCompleted
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryDeepBlue.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    "Active",
                    style: AppFonts.semiBoldText.copyWith(
                      color: !isCompleted ? Colors.white : AppTheme.textGrey500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.selectedCampaignTab.value = 'Completed';
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.primaryDeepBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryDeepBlue.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    "Completed",
                    style: AppFonts.semiBoldText.copyWith(
                      color: isCompleted ? Colors.white : AppTheme.textGrey500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar(ActiveCampaignsController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) {
                controller.searchQuery.value = val;
              },
              decoration: InputDecoration(
                hintText: AppString.searchForCampaigns.tr,
                hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(ActiveCampaignsController controller) {
    return Obx(() {
      final dynamicList = controller.categoriesList;

      final categories = [
        {'key': 'All', 'name': AppString.all.tr, 'icon': Icons.grid_view},
        ...dynamicList.map((cat) {
          final name = cat.name ?? '';
          final iconStr = cat.icon ?? '';
          final imgStr = cat.imageUrl ?? '';

          dynamic iconVal;
          if (iconStr.startsWith('http://') || iconStr.startsWith('https://')) {
            iconVal = iconStr;
          } else if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
            iconVal = imgStr;
          } else {
            final nameLower = name.toLowerCase();
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

          return {
            'key': name,
            'name': name,
            'icon': iconVal,
          };
        }),
      ];

      return SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final catKey = categories[index]['key'] as String;
            final catName = categories[index]['name'] as String;
            final iconData = categories[index]['icon'];
            final isSelected = controller.selectedCategory.value.toLowerCase() == catKey.toLowerCase();

            return GestureDetector(
              onTap: () {
                controller.selectedCategory.value = catKey;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryDeepBlue : Colors.white,
                  border: isSelected 
                      ? Border.all(color: AppTheme.primaryDeepBlue) 
                      : Border.all(color: AppTheme.fieldBorderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (iconData is IconData)
                      Icon(
                        iconData,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.orange,
                      )
                    else if (iconData is String && (iconData.startsWith('http://') || iconData.startsWith('https://')))
                      CachedNetworkImage(
                        imageUrl: iconData,
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                        errorWidget: (c, e, s) => Icon(
                          Icons.category,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.orange,
                        ),
                      )
                    else if (iconData is String && iconData.isNotEmpty)
                      Image.asset(
                        iconData,
                        width: 14,
                        height: 14,
                        errorBuilder: (c, e, s) => Icon(
                          Icons.category,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.orange,
                        ),
                      )
                    else
                      Icon(
                        Icons.category,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.orange,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      catName,
                      style: AppFonts.semiBoldText.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCampaignCard(CampaignDetailsData campaign) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(MyRouters.campaignDetailsScreen, arguments: campaign.sId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.fieldBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: campaign.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => const ShimmerWidget(height: 140, width: double.infinity),
                      errorWidget: (ctx, url, err) => Image.asset(
                        AppAssets.appLogo,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      AppAssets.appLogo,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campaign.title ?? "", style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  _ExpandableDescription(text: campaign.description ?? ""),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text("${campaign.formattedRaised} ${AppString.raised.tr}", style: AppFonts.semiBoldText.copyWith(color: AppTheme.progressGreen, fontSize: 13)),
                      const Spacer(),
                      Text("of ${campaign.formattedGoal}", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: campaign.progress,
                    backgroundColor: AppTheme.fieldBorderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.progressGreen),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${campaign.formattedDonors} ${AppString.donors.tr}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${campaign.daysLeft ?? 0} ${AppString.daysLeft.tr}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      final bool isSelf = isSelfCampaign(
                        campaignUserId: campaign.userId,
                        campaignUser: campaign.user,
                        campaignId: campaign.campaignId,
                        campaignSId: campaign.sId,
                      );
                      final bool showReview = canShowCampaignReviewButton(
                        isSelf: isSelf,
                        isCompleted: campaign.isCompleted,
                      );

                      if (showReview) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.primaryDeepBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                showCampaignReviewBottomSheet(
                                  context: context,
                                  campaignId: (campaign.campaignId != null && campaign.campaignId!.isNotEmpty) ? campaign.campaignId! : (campaign.sId ?? ''),
                                  campaignTitle: campaign.title,
                                  onSuccess: () => controller.fetchActiveCampaigns(forceRefresh: true),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star_outline, size: 16, color: AppTheme.primaryDeepBlue),
                                  const SizedBox(width: 6),
                                  Text("Review", style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
          ),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(
            widget.text,
            style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? "Show less" : "Show more",
                style: AppFonts.semiBoldText.copyWith(
                  fontSize: 12,
                  color: AppTheme.primaryDeepBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
