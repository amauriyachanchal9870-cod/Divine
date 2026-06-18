import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  // Demo state for reviews
  final List<Map<String, dynamic>> reviews = [
    {
      "id": 1,
      "author": "Avalon",
      "time": "Yesterday",
      "title": "Hydrating Coconut Infusion Shampoo",
      "content": "This shampoo delivers intense moisture, leaving hair soft and manageable. Enriched with natural coconut extract, it nourishes and revitalizes dry strands while providing a tropical aroma that invigorates the senses!",
      "isPinned": false,
      "helpfulCount": 4,
    },
    {
      "id": 2,
      "author": "Avalon",
      "time": "Yesterday",
      "title": "Hydrating Coconut Infusion Shampoo",
      "content": "This shampoo delivers intense moisture, leaving hair soft and manageable. Enriched with natural coconut extract, it nourishes and revitalizes dry strands while providing a tropical aroma that invigorates the senses!",
      "isPinned": true,
      "helpfulCount": 2,
    },
    {
      "id": 3,
      "author": "Avalon",
      "time": "Yesterday",
      "title": "Hydrating Coconut Infusion Shampoo",
      "content": "This shampoo delivers intense moisture, leaving hair soft and manageable. Enriched with natural coconut extract, it nourishes and revitalizes dry strands while providing a tropical aroma that invigorates the senses!",
      "isPinned": false,
      "helpfulCount": 0,
    },
  ];

  void _showMenuBottomSheet(BuildContext context, Map<String, dynamic> review) {
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
        final bool isPinned = review['isPinned'];
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
                    review['isPinned'] = !isPinned;
                  });
                  Navigator.pop(context);
                  Get.snackbar(
                    AppString.success.tr, 
                    isPinned ? AppString.reviewUnpinned.tr : AppString.reviewPinnedSuccess.tr,
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
      body: SingleChildScrollView(
        child: Column(
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
                            "4.4", 
                            style: AppFonts.titleStyle.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black87)
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, color: AppTheme.amberStars, size: 24),
                        ],
                      ),
                      Text(AppString.ratingsCount.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBarRow("5", 0.8),
                        _buildRatingBarRow("4", 0.65),
                        _buildRatingBarRow("3", 0.2),
                        _buildRatingBarRow("2", 0.05),
                        _buildRatingBarRow("1", 0.08),
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
                  Text(
                    AppString.reviewsCount.tr, 
                    style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDropdownPill(AppString.byUsers.tr),
                      const SizedBox(width: 8),
                      _buildDropdownPill(AppString.sortBy.tr),
                      const SizedBox(width: 8),
                      _buildDropdownPill(AppString.rating.tr),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // List of Review Cards
            ListView.separated(
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
                value: value,
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

  Widget _buildDropdownPill(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title, 
            style: AppFonts.mediumText.copyWith(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final bool isPinned = review['isPinned'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 5 Gold Stars
        Row(
          children: List.generate(5, (index) {
            return Icon(Icons.star, color: AppTheme.amberStars, size: 14);
          }),
        ),
        const SizedBox(height: 8),
        // Author row with Pin indicator and Menu button
        Row(
          children: [
            Text(
              "${review['author']} • ${review['time'] == 'Yesterday' ? AppString.yesterday.tr : review['time']}", 
              style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
            ),
            const SizedBox(width: 8),
            if (isPinned)
              const Icon(Icons.push_pin, size: 12, color: Colors.black54),
            const Spacer(),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
              onPressed: () => _showMenuBottomSheet(context, review),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bold Title
        Text(
          review['title'],
          style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        // Content
        Text(
          review['content'],
          style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500, height: 1.5),
        ),
        const SizedBox(height: 12),
        // Helpful button
        InkWell(
          onTap: () {
            setState(() {
              review['helpfulCount'] += 1;
            });
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  "${AppString.helpful.tr} (${review['helpfulCount']})",
                  style: AppFonts.mediumText.copyWith(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: AppTheme.borderGreyLighter),
      ],
    );
  }
}
