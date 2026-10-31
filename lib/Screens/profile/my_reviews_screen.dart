import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Widget/review_video_widget.dart';
import '../../Controller/my_reviews_controller.dart';
import '../../Model/review_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final MyReviewsController controller = Get.put(MyReviewsController());

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      String month = months[dt.month - 1];
      return "$month ${dt.day}, ${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _showFilterOptionsBottomSheet(
    BuildContext context,
    String title,
    List<String> options,
    RxString selectedValue,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  bool isSelected = selectedValue.value == option;
                  return InkWell(
                    onTap: () {
                      selectedValue.value = option;
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: AppFonts.mediumText.copyWith(
                              fontSize: 15,
                              color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: AppTheme.primaryDeepBlue, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  void _showMenuBottomSheet(BuildContext context, ReviewItem review) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        final bool isPinned = review.isPinned;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyBg300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Colors.black87,
                ),
                title: Text(
                  isPinned ? AppString.unpin.tr : AppString.pinReview.tr,
                  style: AppFonts.mediumText.copyWith(fontSize: 15, color: Colors.black87),
                ),
                onTap: () {
                  setState(() {
                    review.isPinned = !isPinned;
                  });
                  Navigator.pop(context);
                  Get.snackbar(
                    AppString.success.tr, 
                    isPinned ? AppString.reviewPinnedSuccess.tr : AppString.reviewUnpinned.tr,
                    backgroundColor: Colors.black87,
                    colorText: AppTheme.whiteColor,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppString.ratingsAndReviewsUpper.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18, color: Colors.black87),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchReviews(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(() {
            if (controller.isLoading.value && controller.reviewsList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 100.0),
                child: Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                    color: AppTheme.primaryDeepBlue,
                    size: 40,
                  ),
                ),
              );
            }

            final double avgRating = controller.averageRating;
            final int totalRatingsCount = controller.reviewsList.length;
            final reviews = controller.filteredReviews;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ratings Summary Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: AppFonts.titleStyle.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black87),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.star, color: AppTheme.amberStars, size: 24),
                            ],
                          ),
                          Text(
                            "$totalRatingsCount ${totalRatingsCount == 1 || totalRatingsCount == 0 ? 'Review' : 'Reviews'}",
                            style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBarRow("5", controller.getRatingRatio(5)),
                            _buildRatingBarRow("4", controller.getRatingRatio(4)),
                            _buildRatingBarRow("3", controller.getRatingRatio(3)),
                            _buildRatingBarRow("2", controller.getRatingRatio(2)),
                            _buildRatingBarRow("1", controller.getRatingRatio(1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Divider(color: AppTheme.borderGreyLighter, thickness: 1, height: 32),
                
                // Reviews count and filter dropdowns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "${reviews.length} Reviews",
                      //   style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                      // ),
                      // const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showFilterOptionsBottomSheet(
                                context,
                                "Filter By User Role",
                                ['All', 'Donor', 'NGO'],
                                controller.selectedUserFilter,
                              ),
                              child: _buildDropdownPill(
                                controller.selectedUserFilter.value == 'All'
                                    ? AppString.byUsers.tr
                                    : controller.selectedUserFilter.value,
                                isSelected: controller.selectedUserFilter.value != 'All',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showFilterOptionsBottomSheet(
                                context,
                                "Sort Reviews",
                                ['Newest', 'Oldest', 'Highest Rating', 'Lowest Rating'],
                                controller.selectedSortFilter,
                              ),
                              child: _buildDropdownPill(
                                controller.selectedSortFilter.value == 'Newest'
                                    ? AppString.sortBy.tr
                                    : controller.selectedSortFilter.value,
                                isSelected: controller.selectedSortFilter.value != 'Newest',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showFilterOptionsBottomSheet(
                                context,
                                "Filter By Rating",
                                ['All', '5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star'],
                                controller.selectedRatingFilter,
                              ),
                              child: _buildDropdownPill(
                                controller.selectedRatingFilter.value == 'All'
                                    ? AppString.rating.tr
                                    : controller.selectedRatingFilter.value,
                                isSelected: controller.selectedRatingFilter.value != 'All',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // List of Review Cards
                reviews.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.rate_review_outlined, color: AppTheme.textGrey400, size: 40),
                              const SizedBox(height: 12),
                              Text("No review available", style: AppFonts.semiBoldText.copyWith(color: AppTheme.textGrey500)),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildReviewCard(reviews[index]);
                        },
                      ),
                const SizedBox(height: 40),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRatingBarRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: AppFonts.mediumText.copyWith(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: AppTheme.borderGreyLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPill(String title, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryDeepBlue.withValues(alpha: 0.1) : AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title, 
            style: AppFonts.mediumText.copyWith(
              fontSize: 12,
              color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: isSelected ? AppTheme.primaryDeepBlue : Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewItem review) {
    final bool isPinned = review.isPinned;
    final int ratingCount = (review.rating ?? 0).round();
    final String authorName = review.userName ?? 'Anonymous';
    final String targetName = review.targetName ?? '';
    final String roleType = [
      // if (review.userRole != null && review.userRole!.isNotEmpty) review.userRole,
      if (review.type != null && review.type!.isNotEmpty) review.type,
    ].join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Star Rating
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              color: index < ratingCount ? AppTheme.amberStars : AppTheme.borderGreyLighter,
              size: 16,
            );
          }),
        ),
        const SizedBox(height: 8),
        // Author row with Pin indicator and Menu button
        Row(
          children: [
            Expanded(
              child: Text(
                "$authorName ${roleType.isNotEmpty ? "($roleType)" : ""} • ${formatDate(review.createdAt)}", 
                style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // if (isPinned) ...[
            //   const SizedBox(width: 6),
            //   const Icon(Icons.push_pin, size: 12, color: Colors.black54),
            // ],
            // IconButton(
            //   padding: EdgeInsets.zero,
            //   constraints: const BoxConstraints(),
            //   icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            //   onPressed: () => _showMenuBottomSheet(context, review),
            // ),
          ],
        ),
        if (targetName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            targetName,
            style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue),
          ),
        ],
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            review.comment!,
            style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87, height: 1.5),
          ),
        ],
        if (review.hasVideo) ...[
          const SizedBox(height: 8),
          ReviewVideoWidget(
            videoUrl: review.effectiveVideoUrl,
            height: 160,
            width: double.infinity,
          ),
        ],
        const SizedBox(height: 12),
        // Helpful button
        // InkWell(
        //   onTap: () {
        //     setState(() {
        //       review.helpfulCount += 1;
        //     });
        //   },
        //   borderRadius: BorderRadius.circular(4),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.black54),
        //         const SizedBox(width: 6),
        //         Text(
        //           "${AppString.helpful.tr} (${review.helpfulCount})",
        //           style: AppFonts.mediumText.copyWith(fontSize: 12, color: Colors.black54),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 12),
        Divider(color: AppTheme.borderGreyLighter),
      ],
    );
  }
}
