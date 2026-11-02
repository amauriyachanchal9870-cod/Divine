import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Controller/ngo_dashboard_controller.dart';
import '../../Model/ngo_dashboard_model.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/helper.dart';
import '../../Widget/shimmer_widget.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  final NgoDashboardController controller = Get.put(NgoDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "NGO Dashboard",
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.dashboardData.value == null) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty && controller.dashboardData.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: AppFonts.regularText.copyWith(color: Colors.red.shade400, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchNgoDashboard(forceRefresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.dashboardData.value;
        final ngo = data?.ngo;
        final summary = data?.summary;
        final recentDonations = data?.recentDonations ?? [];

        return RefreshIndicator(
          onRefresh: () => controller.fetchNgoDashboard(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top NGO Basic Info
                // _buildNgoBasicInfo(ngo),
                // const SizedBox(height: 20),

                // 2. Summary Section
                _buildSummarySection(summary),
                const SizedBox(height: 24),

                // 3. Recent Donations List
                _buildRecentDonationsSection(recentDonations),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNgoBasicInfo(NgoProfileInfo? ngo) {
    final name = ngo?.organizationName ?? ngo?.name ?? "NGO";
    final isVerified = (ngo?.status ?? "").toLowerCase() == "verified";
    final rating = ngo?.rating ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.6)),
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
          Row(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(30),
              //   child: ngo?.logo != null && ngo!.logo!.isNotEmpty
              //       ? CachedNetworkImage(
              //           imageUrl: ngo.logo!,
              //           width: 58,
              //           height: 58,
              //           fit: BoxFit.cover,
              //           placeholder: (ctx, url) => const ShimmerWidget(height: 58, width: 58),
              //           errorWidget: (ctx, url, err) => Image.asset(
              //             AppAssets.ngoLogo,
              //             width: 58,
              //             height: 58,
              //             fit: BoxFit.cover,
              //           ),
              //         )
              //       : Image.asset(
              //           AppAssets.ngoLogo,
              //           width: 58,
              //           height: 58,
              //           fit: BoxFit.cover,
              //         ),
              // ),
              // const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppFonts.semiBoldText.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 12, color: Color(0xFF16A34A)),
                                const SizedBox(width: 3),
                                Text(
                                  "Verified",
                                  style: AppFonts.semiBoldText.copyWith(
                                    fontSize: 10,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : "No rating",
                          style: AppFonts.mediumText.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (ngo?.status != null && !isVerified) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ngo!.status!,
                              style: AppFonts.mediumText.copyWith(
                                fontSize: 10,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((ngo?.email != null && ngo!.email!.isNotEmpty) ||
              (ngo?.phone != null && ngo!.phone!.isNotEmpty)) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.6),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (ngo.email != null && ngo.email!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email_outlined, size: 14, color: AppTheme.textGrey400),
                      const SizedBox(width: 6),
                      Text(
                        ngo.email!,
                        style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                      ),
                    ],
                  ),
                if (ngo.phone != null && ngo.phone!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: AppTheme.textGrey400),
                      const SizedBox(width: 6),
                      Text(
                        formatPhoneWithCountryCode(ngo.phone!),
                        style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection(NgoSummary? summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Summary",
          style: AppFonts.titleStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        // Primary Highlight Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryDeepBlue,
                const Color(0xFF1E3A8A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDeepBlue.withValues(alpha: 0.25),
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
                  Text(
                    "Total Donations Received",
                    style: AppFonts.mediumText.copyWith(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                summary?.formattedTotalDonations ?? "₹0",
                style: AppFonts.titleStyle.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "${summary?.totalDonorsCount ?? 0} Donors",
                      style: AppFonts.mediumText.copyWith(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 12, color: Colors.white30),
                    const SizedBox(width: 12),
                    const Icon(Icons.receipt_long, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "${summary?.totalDonationCount ?? 0} Donations",
                      style: AppFonts.mediumText.copyWith(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4 Grid KPI Cards
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: "Campaign Total",
                value: "₹${formatPrice(summary?.campaignDonationsTotal ?? 0)}",
                icon: Icons.campaign_rounded,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: "Active Campaigns",
                value: "${summary?.activeCampaignsCount ?? 0}",
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: "Dan Total",
                value: "₹${formatPrice(summary?.danDonationsTotal ?? 0)}",
                icon: Icons.volunteer_activism_rounded,
                iconColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: "Total Campaigns",
                value: "${summary?.totalCampaignsCount ?? 0}",
                icon: Icons.layers_rounded,
                iconColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFEDE9FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppFonts.regularText.copyWith(
                  fontSize: 11,
                  color: AppTheme.textGrey500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppFonts.semiBoldText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonationsSection(List<NgoRecentDonation> recentDonations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Donations",
              style: AppFonts.titleStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            if (recentDonations.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDeepBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${recentDonations.length} total",
                  style: AppFonts.semiBoldText.copyWith(
                    fontSize: 11,
                    color: AppTheme.primaryDeepBlue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentDonations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textGrey400),
                const SizedBox(height: 10),
                Text(
                  "No recent donations found",
                  style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentDonations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = recentDonations[index];
              return _buildDonationItem(item);
            },
          ),
      ],
    );
  }

  Widget _buildDonationItem(NgoRecentDonation item) {
    final donorName = item.donorName ?? "Anonymous Donor";
    final target = item.campaignTitle ?? item.item ?? "Donation";
    final isSuccess = (item.status ?? "").toLowerCase() == "success";

    String formattedDate = item.date ?? item.createdAt ?? "";
    if (formattedDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(formattedDate);
        formattedDate = DateFormat("dd MMM yyyy, hh:mm a").format(parsed.toLocal());
      } catch (_) {
        if (formattedDate.length > 10) {
          formattedDate = formattedDate.substring(0, 10);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.fieldBorderColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.volunteer_activism_rounded, color: Color(0xFF16A34A), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        donorName,
                        style: AppFonts.semiBoldText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+${item.formattedAmount ?? '₹${formatPrice(item.amount ?? 0)}'}",
                      style: AppFonts.semiBoldText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  target,
                  style: AppFonts.regularText.copyWith(
                    fontSize: 12,
                    color: AppTheme.textGrey500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (item.donationId != null && item.donationId!.isNotEmpty) ...[
                      Text(
                        item.donationId!,
                        style: AppFonts.mediumText.copyWith(
                          fontSize: 10,
                          color: AppTheme.primaryDeepBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: AppTheme.textGrey400, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: AppFonts.regularText.copyWith(
                          fontSize: 10,
                          color: AppTheme.textGrey400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.status != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status!,
                          style: AppFonts.semiBoldText.copyWith(
                            fontSize: 9,
                            color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
