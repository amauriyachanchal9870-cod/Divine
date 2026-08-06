import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Controller/campaign_details_controller.dart';
import '../../Model/campaign_details_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CampaignDetailsScreen extends StatelessWidget {
  const CampaignDetailsScreen({super.key});

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return "Recently";
    try {
      DateTime date = DateTime.parse(dateStr).toLocal();
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);
      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hrs ago";
      } else {
        return "${difference.inDays} days ago";
      }
    } catch (e) {
      return "Recently";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String campaignId = Get.arguments as String? ?? "";
    final CampaignDetailsController controller = Get.put(
      CampaignDetailsController(campaignId: campaignId),
      tag: campaignId,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.campaignDetails.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
        // actions: [
        //   IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black54, size: 20), onPressed: () {}),
        //   IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.black54, size: 20), onPressed: () {}),
        // ],
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
                  onPressed: () => controller.fetchCampaignDetails(),
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

        final data = controller.campaignDetails.value;
        if (data == null) {
          return Center(
            child: Text(
              "No campaign data found",
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrganizerRow(data),
                  _buildHeaderImage(data),
                  _buildCampaignInfo(data),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildDescription(data),
                  const SizedBox(height: 16),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRecentDonors(data),
                ],
              ),
            ),
            _buildBottomBar(data),
          ],
        );
      }),
    );
  }

  Widget _buildOrganizerRow(CampaignDetailsData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(AppAssets.ngoLogo),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.user ?? "Organizer", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              Text("Organizer", style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(CampaignDetailsData data) {
    return data.imageUrl != null && data.imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: data.imageUrl!,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => const ShimmerWidget(height: 220, width: double.infinity),
            errorWidget: (ctx, url, err) => Image.asset(
              AppAssets.campaignImage,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            AppAssets.campaignImage,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          );
  }

  Widget _buildCampaignInfo(CampaignDetailsData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title ?? "", style: AppFonts.titleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(data.category ?? "", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${data.formattedRaised} raised", style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen)),
              Text("of ${data.goal ?? '₹0'}", style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: data.progress,
            backgroundColor: AppTheme.fieldBorderColor,
            color: AppTheme.progressGreen,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(Icons.people_outline, "${data.donorsCount ?? 0} Donors"),
              const SizedBox(width: 16),
              _buildStatChip(Icons.timelapse_rounded, "${data.daysLeft ?? 0} days left"),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDescription(CampaignDetailsData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.campaignDescription.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            data.description ?? "",
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonors(CampaignDetailsData data) {
    if (data.recentDonors == null || data.recentDonors!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(AppString.recentDonors.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.recentDonors!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final donor = data.recentDonors![index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(AppAssets.ngoLogo),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(donor.name ?? "Anonymous", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text("Donated ₹${donor.amount ?? 0}", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                        ],
                      ),
                    ),
                    Text(_formatTimeAgo(donor.date), style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CampaignDetailsData data) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDeepBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                Get.toNamed(MyRouters.donateAmountScreen, arguments: data);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(AppString.donateNow.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
