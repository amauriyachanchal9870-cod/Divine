import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Controller/campaign_details_controller.dart';
import '../../Controller/banner_controller.dart';
import '../../Widget/banner_slider_widget.dart';
import '../../Model/campaign_details_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/helper.dart';
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
    final BannerController bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController());

    bannerController.fetchBanners('campaign_details');

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
                  _buildDocuments(context, data),
                  const SizedBox(height: 16),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Obx(() {
                    final topBanners = bannerController.getTopBanners('campaign_details');
                    if (topBanners.isNotEmpty) {
                      return BannerSliderWidget(
                        banners: topBanners,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _buildRecentDonors(data),
                  Obx(() {
                    final bottomBanners = bannerController.getBottomBanners('campaign_details');
                    if (bottomBanners.isNotEmpty) {
                      return BannerSliderWidget(
                        banners: bottomBanners,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
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
          ClipOval(
            child: (data.fundraiserImage != null && data.fundraiserImage!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: data.fundraiserImage!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 36,
                      height: 36,
                      color: AppTheme.fieldBorderColor,
                      child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 36,
                      height: 36,
                      color: AppTheme.fieldBorderColor,
                      child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                    ),
                  )
                : Container(
                    width: 36,
                    height: 36,
                    color: AppTheme.fieldBorderColor,
                    child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.user ?? "Organizer", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              // Text("Organizer", style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(CampaignDetailsData data) {
    return _CampaignHeaderSlider(images: data.allImages);
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
              Text("of ${data.formattedGoal}", style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black)),
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

  Widget _buildDocuments(BuildContext context, CampaignDetailsData data) {
    final docsList = data.allDocuments;
    if (docsList.isEmpty) return const SizedBox.shrink();

    final parsedDocs = docsList
        .where((url) => url.trim().isNotEmpty)
        .map((url) => CampaignDocument.fromUrl(url))
        .toList();

    if (parsedDocs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Documents",
                style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < parsedDocs.length; i++) ...[
                    InkWell(
                      onTap: () => _openDocumentPopup(context, parsedDocs[i]),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description_outlined, size: 16, color: AppTheme.primaryDeepBlue),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                parsedDocs[i].label,
                                style: TextStyle(
                                  color: AppTheme.primaryDeepBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < parsedDocs.length - 1)
                      const Text(
                        ",",
                        style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDocumentPopup(BuildContext context, CampaignDocument doc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _DocumentPreviewDialog(document: doc),
    );
  }

  Widget _buildRecentDonors(CampaignDetailsData data) {
    if (data.recentDonors == null || data.recentDonors!.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedDonors = _groupDonors(data.recentDonors!);

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
            itemCount: groupedDonors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = groupedDonors[index];
              return _GroupedDonorCard(
                name: group.name,
                profilePhoto: group.profilePhoto,
                transactions: group.transactions,
                formatTimeAgo: _formatTimeAgo,
              );
            },
          ),
        ],
      ),
    );
  }

  List<_DonorGroup> _groupDonors(List<RecentDonor> recentDonors) {
    final Map<String, List<RecentDonor>> map = {};
    final List<String> orderedKeys = [];

    for (var donor in recentDonors) {
      final nameKey = (donor.name ?? "Anonymous").trim().toLowerCase();
      if (!map.containsKey(nameKey)) {
        map[nameKey] = [];
        orderedKeys.add(nameKey);
      }
      map[nameKey]!.add(donor);
    }

    return orderedKeys.map((key) {
      final list = map[key]!;
      final displayName = list.first.name ?? "Anonymous";
      RecentDonor? donorWithPhoto;
      for (var d in list) {
        if (d.profilePhoto != null && d.profilePhoto!.isNotEmpty) {
          donorWithPhoto = d;
          break;
        }
      }
      return _DonorGroup(
        name: displayName,
        profilePhoto: donorWithPhoto?.profilePhoto,
        transactions: list,
      );
    }).toList();
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

class _DonorGroup {
  final String name;
  final String? profilePhoto;
  final List<RecentDonor> transactions;

  _DonorGroup({required this.name, this.profilePhoto, required this.transactions});
}

class _GroupedDonorCard extends StatefulWidget {
  final String name;
  final String? profilePhoto;
  final List<RecentDonor> transactions;
  final String Function(String?) formatTimeAgo;

  const _GroupedDonorCard({
    required this.name,
    this.profilePhoto,
    required this.transactions,
    required this.formatTimeAgo,
  });

  @override
  State<_GroupedDonorCard> createState() => _GroupedDonorCardState();
}

class _GroupedDonorCardState extends State<_GroupedDonorCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final latestTransaction = widget.transactions.first;
    final hasMultiple = widget.transactions.length > 1;

    return Container(
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
      child: Column(
        children: [
          InkWell(
            onTap: hasMultiple
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipOval(
                    child: (widget.profilePhoto != null && widget.profilePhoto!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: widget.profilePhoto!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person, size: 24, color: Colors.grey),
                            ),
                            errorWidget: (c, u, e) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person, size: 24, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, size: 24, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.name.isNotEmpty ? widget.name : "N/A",
                                style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasMultiple) ...[
                              const SizedBox(width: 4),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 20,
                                color: AppTheme.primaryDeepBlue,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Donated ₹${formatPrice(latestTransaction.amount ?? 0)}",
                          style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.formatTimeAgo(latestTransaction.date),
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
                  ),
                ],
              ),
            ),
          ),
          if (hasMultiple && _isExpanded) ...[
            const Divider(height: 1, indent: 12, endIndent: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "All Transactions (${widget.transactions.length})",
                      style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.transactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tx = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 14, color: AppTheme.textGrey400),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${index + 1}: Donated ₹${formatPrice(tx.amount ?? 0)}",
                              style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          Text(
                            widget.formatTimeAgo(tx.date),
                            style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CampaignHeaderSlider extends StatefulWidget {
  final List<String> images;

  const _CampaignHeaderSlider({required this.images});

  @override
  State<_CampaignHeaderSlider> createState() => _CampaignHeaderSliderState();
}

class _CampaignHeaderSliderState extends State<_CampaignHeaderSlider> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Image.asset(
        AppAssets.appLogo,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imgUrl = widget.images[index];
              return CachedNetworkImage(
                imageUrl: imgUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => const ShimmerWidget(height: 220, width: double.infinity),
                errorWidget: (ctx, url, err) => Image.asset(
                  AppAssets.appLogo,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_currentIndex + 1}/${widget.images.length}",
                style: AppFonts.mediumText.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CampaignDocument {
  final String rawUrl;
  final String fileUrl;
  final String? type;
  final String? name;

  CampaignDocument({
    required this.rawUrl,
    required this.fileUrl,
    this.type,
    this.name,
  });

  factory CampaignDocument.fromUrl(String raw) {
    final trimmed = raw.trim();
    String fileUrl = trimmed;
    String? type;
    String? name;

    try {
      final uri = Uri.parse(trimmed);

      final Map<String, String> params = {};
      if (uri.hasFragment && uri.fragment.isNotEmpty) {
        try {
          params.addAll(Uri.splitQueryString(uri.fragment));
        } catch (_) {}
      }

      if (uri.queryParameters.isNotEmpty) {
        params.addAll(uri.queryParameters);
      }

      type = params['type'];
      name = params['name'];

      if (trimmed.contains('#')) {
        fileUrl = trimmed.split('#').first.trim();
      }
    } catch (_) {
      if (trimmed.contains('#')) {
        final parts = trimmed.split('#');
        fileUrl = parts[0].trim();
        final frag = parts[1].trim();
        final pairs = frag.split('&');
        for (var p in pairs) {
          final kv = p.split('=');
          if (kv.length == 2) {
            final key = kv[0].toLowerCase().trim();
            final val = Uri.decodeComponent(kv[1].trim());
            if (key == 'type') type = val;
            if (key == 'name') name = val;
          }
        }
      }
    }

    if (name == null || name.isEmpty) {
      try {
        final segments = Uri.parse(fileUrl).pathSegments;
        if (segments.isNotEmpty && segments.last.isNotEmpty) {
          name = segments.last;
        }
      } catch (_) {}
    }

    return CampaignDocument(
      rawUrl: trimmed,
      fileUrl: fileUrl,
      type: type,
      name: name,
    );
  }

  String get formattedType {
    if (type == null || type!.trim().isEmpty) return '';
    final t = type!.trim();
    return t[0].toUpperCase() + t.substring(1);
  }

  String get label {
    final t = formattedType;
    if (t.isNotEmpty && name != null && name!.isNotEmpty) {
      return "$t ($name)";
    } else if (t.isNotEmpty) {
      return "$t Document";
    } else if (name != null && name!.isNotEmpty) {
      return name!;
    }
    return "Document";
  }

  String get fileName {
    String n = (name != null && name!.trim().isNotEmpty) ? name!.trim() : '';
    if (n.isEmpty) {
      try {
        final segments = Uri.parse(fileUrl).pathSegments;
        if (segments.isNotEmpty && segments.last.isNotEmpty) {
          n = segments.last;
        }
      } catch (_) {}
    }
    if (n.isEmpty) {
      n = "document_${DateTime.now().millisecondsSinceEpoch}.jpg";
    }

    if (!n.contains('.')) {
      String ext = '';
      try {
        final path = Uri.parse(fileUrl).path;
        if (path.contains('.')) {
          ext = ".${path.split('.').last.split('?').first}";
        }
      } catch (_) {}
      if (ext.isEmpty) ext = '.jpg';
      n = "$n$ext";
    }

    return n;
  }

  bool get isImage {
    final lowerName = fileName.toLowerCase();
    final lowerUrl = fileUrl.toLowerCase();
    return lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.bmp') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        !lowerName.contains('.');
  }
}

class _DocumentPreviewDialog extends StatefulWidget {
  final CampaignDocument document;

  const _DocumentPreviewDialog({required this.document});

  @override
  State<_DocumentPreviewDialog> createState() => _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends State<_DocumentPreviewDialog> {
  bool _isDownloading = false;

  Future<void> _downloadFile(BuildContext context) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final cleanUrl = widget.document.fileUrl;
      final uri = Uri.tryParse(cleanUrl);
      if (uri == null || !uri.hasScheme) {
        showSnackBar("Invalid document URL", false);
        return;
      }

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        showSnackBar("Failed to download file (HTTP ${response.statusCode})", false);
        return;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        showSnackBar("Downloaded file is empty", false);
        return;
      }

      final fileName = widget.document.fileName;
      String savedFilePath = '';

      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          final file = File('${downloadDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          savedFilePath = file.path;
        } catch (_) {}
      }

      if (savedFilePath.isEmpty) {
        try {
          final dir = await getDownloadsDirectory();
          if (dir != null) {
            final file = File('${dir.path}/$fileName');
            await file.writeAsBytes(bytes);
            savedFilePath = file.path;
          }
        } catch (_) {}
      }

      if (savedFilePath.isEmpty) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes);
          savedFilePath = file.path;
        } catch (_) {}
      }

      if (savedFilePath.isNotEmpty) {
        showSnackBar("Downloaded successfully: $fileName", true);
        try {
          await OpenFilex.open(savedFilePath);
        } catch (_) {}
      } else {
        showSnackBar("Could not save file to device storage", false);
      }
    } catch (e) {
      showSnackBar("Error downloading document: ${e.toString()}", false);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxDialogWidth = screenSize.width > 500 ? 480.0 : screenSize.width * 0.92;
    final maxDialogHeight = screenSize.height * 0.82;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppTheme.greyBg100, width: 1.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.blueLightBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.description_outlined, color: AppTheme.primaryDeepBlue, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.document.label,
                          style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.document.formattedType.isNotEmpty)
                          Text(
                            "${widget.document.formattedType} Document",
                            style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Content preview
            Flexible(
              child: Container(
                color: const Color(0xFFF8FAFC),
                width: double.infinity,
                child: widget.document.isImage
                    ? InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.document.fileUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: LoadingAnimationWidget.threeRotatingDots(
                                  color: AppTheme.primaryDeepBlue,
                                  size: 40,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_outlined, color: Colors.red.shade300, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Failed to load document preview",
                                    style: AppFonts.mediumText.copyWith(fontSize: 13, color: Colors.red.shade400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 56),
                            const SizedBox(height: 12),
                            Text(
                              widget.document.fileName,
                              style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Download to view this document on your device.",
                              style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Footer with Download Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.greyBg100, width: 1.5)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isDownloading ? null : () => _downloadFile(context),
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloading ? "Downloading..." : "Download Document",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
