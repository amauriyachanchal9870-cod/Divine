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
                  onPressed: () => controller.fetchActiveCampaigns(),
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
            _buildCategories(controller),
            const SizedBox(height: 16),
            Expanded(
              child: campaigns.isEmpty
                  ? Center(
                      child: Text(
                        "No active campaigns found",
                        style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.fetchActiveCampaigns(),
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
    final categories = [
      {'key': 'All', 'name': AppString.all.tr, 'icon': Icons.grid_view},
      {'key': 'Medical', 'name': AppString.medical.tr, 'icon': Icons.medical_services_outlined},
      {'key': 'Education', 'name': AppString.education.tr, 'icon': AppAssets.books},
      {'key': 'Emergency', 'name': AppString.emergency.tr, 'icon': Icons.warning_amber_rounded},
      {'key': 'Animal Welfare', 'name': AppString.animalWelfare.tr, 'icon': AppAssets.gau},
      {'key': 'Religious', 'name': "Religious".tr, 'icon': Icons.temple_hindu_outlined},
      {'key': 'NGO Welfare', 'name': "NGO Welfare".tr, 'icon': Icons.volunteer_activism_outlined},
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
          return Obx(() {
            final isSelected = controller.selectedCategory.value == catKey;
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
                    categories[index]['icon'] is IconData
                        ? Icon(
                            categories[index]['icon'] as IconData,
                            size: 14,
                            color: isSelected ? Colors.white : Colors.black54,
                          )
                        : Image.asset(
                            categories[index]['icon'] as String,
                            width: 14,
                            height: 14,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.category,
                              size: 14,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                    const SizedBox(width: 6),
                    Text(
                      categories[index]['name'] as String,
                      style: AppFonts.semiBoldText.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
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
                      errorWidget: (ctx, url, err) => Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
                    )
                  : Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey, size: 40),
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryDeepBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.toNamed(MyRouters.campaignDetailsScreen, arguments: campaign.sId);
                      },
                      child: Text(AppString.viewDetails.tr, style: TextStyle(color: AppTheme.primaryDeepBlue, fontSize: 14, fontWeight: FontWeight.bold)),
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
