import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Controller/my_campaigns_controller.dart';
import '../../Model/campaign_details_model.dart';
import '../../Model/my_campaigns_model.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/helper.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Widget/campaign_review_bottom_sheet.dart';

class MyCampaignsScreen extends StatefulWidget {
  const MyCampaignsScreen({super.key});

  @override
  State<MyCampaignsScreen> createState() => _MyCampaignsScreenState();
}

class _MyCampaignsScreenState extends State<MyCampaignsScreen> {
  final MyCampaignsController controller = Get.put(MyCampaignsController());

  @override
  void initState() {
    super.initState();
    controller.searchQuery.value = '';
    controller.selectedCategory.value = 'All';
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
        title: Text(
          AppString.myCampaigns.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                  onPressed: () {
                    controller.fetchMyCampaigns(forceRefresh: true);
                    controller.fetchCampaignCategories(forceRefresh: true);
                  },
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

        final modelData = controller.myCampaignsData.value;
        final campaigns = controller.filteredCampaigns;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.fetchMyCampaigns(forceRefresh: true),
              controller.fetchCampaignCategories(forceRefresh: true),
            ]);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalRaisedHeaderCard(modelData),
              // const SizedBox(height: 12),
              _buildTabs(controller),
              const SizedBox(height: 12),
              _buildSearchBar(controller),
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
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: campaigns.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final campaign = campaigns[index];
                          return _buildCampaignCard(campaign);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabs(MyCampaignsController controller) {
    return Obx(() {
      final isCompleted = controller.selectedCampaignTab.value == 'Completed';

      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildTotalRaisedHeaderCard(MyCampaignsModel? data) {
    final raised = data?.formattedTotalRaised ?? '₹0';
    final goal = data?.formattedTotalGoal ?? '₹0';
    final count = data?.count ?? data?.myCampaigns?.length ?? 0;
    final donors = data?.totalDonorsCount ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryDeepBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDeepBlue.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Raised Amount",
                    style: AppFonts.regularText.copyWith(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    raised,
                    style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text("Campaigns", style: AppFonts.regularText.copyWith(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text("$count", style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 14)),
                ],
              ),
              Container(height: 20, width: 1, color: Colors.white.withValues(alpha: 0.2)),
              Column(
                children: [
                  Text("Total Donors", style: AppFonts.regularText.copyWith(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text("$donors", style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 14)),
                ],
              ),
              Container(height: 20, width: 1, color: Colors.white.withValues(alpha: 0.2)),
              Column(
                children: [
                  Text("Total Goal", style: AppFonts.regularText.copyWith(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(goal, style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MyCampaignsController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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

  Widget _buildCategories(MyCampaignsController controller) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildVerificationBadge(bool isVerified, {bool isRejected = false}) {
    final Color bgColor = isRejected
        ? const Color(0xFFFFEBEE)
        : (isVerified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0));
    final Color textColor = isRejected
        ? const Color(0xFFD32F2F)
        : (isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE65100));
    final IconData icon = isRejected
        ? Icons.cancel_outlined
        : (isVerified ? Icons.verified : Icons.gpp_maybe_outlined);
    final String label = isRejected
        ? "Rejected"
        : (isVerified ? "Verified" : "Not Verified");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textColor.withValues(alpha: 0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppFonts.semiBoldText.copyWith(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(CampaignDetailsData c) {
    final bool isVerified = c.isCampaignVerified;

    return GestureDetector(
      onTap: isVerified
          ? () => Get.toNamed(MyRouters.campaignDetailsScreen, arguments: c.sId)
          : () {
              showSnackBar("This campaign is not verified yet.", false);
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: c.imageUrl != null && c.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: c.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => const ShimmerWidget(height: 160, width: double.infinity),
                          errorWidget: (ctx, url, err) => Image.asset(
                            AppAssets.campaignImage,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          AppAssets.campaignImage,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Verification Badge (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildVerificationBadge(isVerified, isRejected: c.isRejected),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title ?? '', style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    c.description ?? '',
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${c.formattedRaised} raised", style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.progressGreen)),
                      Text("of ${c.formattedGoal}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
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
                      Text("${c.formattedDonors} Donors", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${c.daysLeft} days left", style: AppFonts.regularText.copyWith(fontSize: 10, color: Colors.black)),
                    ],
                  ),
                  if (c.isRejected &&
                      c.rejectionReason != null &&
                      c.rejectionReason!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: Colors.red.shade700),
                              const SizedBox(width: 6),
                              Text(
                                "Rejection Reason",
                                style: AppFonts.semiBoldText.copyWith(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.rejectionReason!.trim(),
                            style: AppFonts.regularText.copyWith(
                              fontSize: 12,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isVerified) ...[
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final bool isCompletedTab = controller.selectedCampaignTab.value == 'Completed' || c.isCompleted;
                        final bool isSelf = isSelfCampaign(
                          campaignUserId: c.userId,
                          campaignUser: c.user,
                          campaignId: c.campaignId,
                          campaignSId: c.sId,
                          defaultSelf: true,
                        );
                        final bool showReview = canShowCampaignReviewButton(
                          isSelf: isSelf,
                          isCompleted: c.isCompleted,
                        );

                        // In Completed tab: do not show Edit or Activate/Deactivate button
                        if (isCompletedTab) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppTheme.primaryDeepBlue),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Get.toNamed(MyRouters.campaignDetailsScreen, arguments: c.sId);
                                  },
                                  child: Text(
                                    AppString.viewDetails.tr,
                                    style: TextStyle(
                                      color: AppTheme.primaryDeepBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (showReview) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppTheme.primaryDeepBlue),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      showCampaignReviewBottomSheet(
                                        context: context,
                                        campaignId: (c.campaignId != null && c.campaignId!.isNotEmpty) ? c.campaignId! : (c.sId ?? ''),
                                        campaignTitle: c.title,
                                        onSuccess: () => controller.fetchMyCampaigns(forceRefresh: true),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.star_outline,
                                      size: 16,
                                      color: AppTheme.primaryDeepBlue,
                                    ),
                                    label: Text(
                                      "Review",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.primaryDeepBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }

                        // In Active tab: show View Details + Edit, and Activate/Deactivate button
                        Widget buildActivateDeactivateBtn() {
                          return Obx(() {
                            final isUpdating = controller.isTogglingStatus[c.sId] == true;
                            final isActive = c.isCampaignActive;

                            return OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isActive ? Colors.red.shade400 : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                backgroundColor: isActive
                                    ? Colors.red.shade50.withValues(alpha: 0.3)
                                    : Colors.grey.shade100.withValues(alpha: 0.5),
                                disabledForegroundColor: Colors.grey.shade400,
                              ),
                              onPressed: (isUpdating || !isActive)
                                  ? null
                                  : () => _showStopCampaignDialog(context, c),
                              icon: isUpdating
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.red.shade700,
                                      ),
                                    )
                                  : Icon(
                                      Icons.pause_circle_outline,
                                      size: 16,
                                      color: isActive ? Colors.red.shade700 : Colors.grey.shade400,
                                    ),
                              label: Text(
                                "Stop Campaign",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isActive ? Colors.red.shade700 : Colors.grey.shade400,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          });
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                // View Details button
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppTheme.primaryDeepBlue),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Get.toNamed(MyRouters.campaignDetailsScreen, arguments: c.sId);
                                      },
                                      child: Text(
                                        AppString.viewDetails.tr,
                                        style: TextStyle(
                                          color: AppTheme.primaryDeepBlue,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Edit button
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryDeepBlue,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Get.toNamed(
                                          MyRouters.raiseCampaignWizardScreen,
                                          arguments: {
                                            'isEdit': true,
                                            'campaignId': c.sId,
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: showReview
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: AppTheme.primaryDeepBlue),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              onPressed: () {
                                                showCampaignReviewBottomSheet(
                                                  context: context,
                                                  campaignId: (c.campaignId != null && c.campaignId!.isNotEmpty) ? c.campaignId! : (c.sId ?? ''),
                                                  campaignTitle: c.title,
                                                  onSuccess: () => controller.fetchMyCampaigns(forceRefresh: true),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.star_outline,
                                                size: 16,
                                                color: AppTheme.primaryDeepBlue,
                                              ),
                                              label: Text(
                                                "Review",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: AppTheme.primaryDeepBlue,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: buildActivateDeactivateBtn(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: buildActivateDeactivateBtn(),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  if (!isVerified && !(controller.selectedCampaignTab.value == 'Completed' || c.isCompleted)) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDeepBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.toNamed(
                            MyRouters.raiseCampaignWizardScreen,
                            arguments: {
                              'isEdit': true,
                              'campaignId': c.sId,
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStopCampaignDialog(BuildContext context, CampaignDetailsData c) {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Stop Campaign",
            style: AppFonts.semiBoldText.copyWith(fontSize: 16, color: Colors.black87),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reason",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Reason",
                    hintText: "Enter reason for stopping campaign",
                    hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.fieldBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.fieldBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.primaryDeepBlue),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Reason is required";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: AppTheme.textGrey400),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      AppString.cancel.tr,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        final reason = reasonController.text.trim();
                        Navigator.of(dialogContext).pop();
                        controller.toggleCampaignActiveStatus(
                          c.sId ?? '',
                          c.isCampaignActive,
                          context,
                          deactivationReason: reason,
                        );
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
