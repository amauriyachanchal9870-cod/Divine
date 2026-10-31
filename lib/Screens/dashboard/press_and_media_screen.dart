import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../Controller/home_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_theme.dart';
import '../../Widget/shimmer_widget.dart';

class PressAndMediaScreen extends StatelessWidget {
  const PressAndMediaScreen({super.key});

  static String formatPressDateTime(HomePressMedia item) {
    final rawDate = (item.publishedDate ?? item.date ?? item.createdAt)?.trim() ?? '';
    final rawTime = item.time?.trim() ?? '';

    if (rawDate.isEmpty && rawTime.isEmpty) return '';

    DateTime? parsedDate;
    bool hasTimeInDateString = false;

    if (rawDate.isNotEmpty) {
      final intMs = int.tryParse(rawDate);
      if (intMs != null) {
        final ms = intMs < 10000000000 ? intMs * 1000 : intMs;
        parsedDate = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
        hasTimeInDateString = true;
      } else {
        final dt = DateTime.tryParse(rawDate);
        if (dt != null) {
          parsedDate = dt.toLocal();
          hasTimeInDateString = rawDate.contains('T') || rawDate.contains(':');
        }
      }
    }

    String datePart = '';
    if (parsedDate != null) {
      datePart = DateFormat('dd-MM-yyyy').format(parsedDate);
    } else if (rawDate.isNotEmpty) {
      datePart = rawDate;
    }

    String timePart = '';
    if (rawTime.isNotEmpty) {
      try {
        final cleaned = rawTime.toUpperCase();
        if (cleaned.contains('AM') || cleaned.contains('PM')) {
          timePart = rawTime;
        } else {
          final parts = rawTime.split(':');
          if (parts.length >= 2) {
            final h = int.parse(parts[0].trim());
            final m = int.parse(parts[1].trim());
            final dummy = DateTime(2026, 1, 1, h, m);
            timePart = DateFormat('hh:mm a').format(dummy);
          } else {
            timePart = rawTime;
          }
        }
      } catch (_) {
        timePart = rawTime;
      }
    } else if (hasTimeInDateString && parsedDate != null) {
      timePart = DateFormat('hh:mm a').format(parsedDate);
    }

    if (datePart.isNotEmpty && timePart.isNotEmpty) {
      return "$datePart • $timePart";
    } else if (datePart.isNotEmpty) {
      return datePart;
    } else {
      return timePart;
    }
  }

  static void showDetailsSheet(BuildContext context, HomePressMedia item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
        final dateStr = formatPressDateTime(item);
        final hasDate = dateStr.isNotEmpty;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      AppString.pressAndMedia.tr,
                      style: AppFonts.semiBoldText.copyWith(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl!.trim(),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const ShimmerWidget(height: 200, width: double.infinity),
                            errorWidget: (_, __, ___) => Container(
                              height: 160,
                              width: double.infinity,
                              color: const Color(0xFFF5F7FA),
                              alignment: Alignment.center,
                              child: Image.asset(AppAssets.appLogo, height: 70, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        children: [
                          if (item.source != null && item.source!.trim().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryDeepBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.source!.trim(),
                                style: AppFonts.semiBoldText.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.primaryDeepBlue,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (hasDate)
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textGrey500),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: AppFonts.regularText.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.textGrey500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title ?? '',
                        style: AppFonts.titleStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      if (item.content != null && item.content!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          item.content!.trim(),
                          style: AppFonts.regularText.copyWith(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

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
          AppString.pressAndMedia.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        List<HomePressMedia> pressList = homeController.pressAndMedia;
        if (pressList.isEmpty && Get.arguments is List<HomePressMedia>) {
          pressList = Get.arguments as List<HomePressMedia>;
        }

        if (homeController.isLoading.value && pressList.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          );
        }

        if (pressList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.newspaper_outlined, size: 64, color: AppTheme.textGrey400),
                const SizedBox(height: 12),
                Text(
                  AppString.noPressMediaAvailable.tr,
                  style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await homeController.fetchHomeData();
          },
          color: AppTheme.primaryDeepBlue,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: pressList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = pressList[index];
              return _buildPressCard(context, item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPressCard(BuildContext context, HomePressMedia item) {
    final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
    final hasSource = item.source != null && item.source!.trim().isNotEmpty;
    final dateStr = formatPressDateTime(item);
    final hasDate = dateStr.isNotEmpty;
    final hasContent = item.content != null && item.content!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => PressAndMediaScreen.showDetailsSheet(context, item),
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
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!.trim(),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => const ShimmerWidget(height: 160, width: double.infinity),
                      errorWidget: (ctx, url, err) => Container(
                        height: 160,
                        width: double.infinity,
                        color: const Color(0xFFF5F7FA),
                        alignment: Alignment.center,
                        child: Image.asset(AppAssets.appLogo, height: 70, fit: BoxFit.contain),
                      ),
                    )
                  : Container(
                      height: 160,
                      width: double.infinity,
                      color: const Color(0xFFF5F7FA),
                      alignment: Alignment.center,
                      child: Image.asset(AppAssets.appLogo, height: 70, fit: BoxFit.contain),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasSource || hasDate) ...[
                    Row(
                      children: [
                        if (hasSource)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDeepBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.source!.trim(),
                              style: AppFonts.semiBoldText.copyWith(
                                fontSize: 11,
                                color: AppTheme.primaryDeepBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const Spacer(),
                        if (hasDate)
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textGrey500),
                              const SizedBox(width: 4),
                              Text(
                                dateStr,
                                style: AppFonts.regularText.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.textGrey500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    item.title ?? '',
                    style: AppFonts.semiBoldText.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasContent) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.content!.trim(),
                      style: AppFonts.regularText.copyWith(
                        fontSize: 12,
                        color: AppTheme.textGrey500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}
